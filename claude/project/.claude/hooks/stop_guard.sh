#!/usr/bin/env bash
# Stop hook: 완료 후 자동 품질 검사(공장 검수 라인).
#   1) .claude/verify.toml 의 검증 명령을 실행해 결과를 QA.md 에 기록한다.
#   2) 검증 실패 / 보안 변경 미검토 / CHECKLIST 미완료 / QA 실패행이 있으면 종료를 block 한다.
#   3) 루프와 토큰 낭비를 막기 위해 같은 사유 2회 차단 후에는 사용자 확인으로 전환하고,
#      세션 누적 차단이 8회를 넘으면 모든 게이트를 advisory 로 내린다.
# 의존성: bash, coreutils(timeout 있으면 사용), grep -E (jq 불필요)
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEM="$PROJECT_ROOT/.claude-memory"
QA="$MEM/QA.md"
CHECKLIST="$MEM/CHECKLIST.md"
MODIFIED="$MEM/MODIFIED_FILES.md"
METRICS="$MEM/METRICS.md"
STATE="$MEM/.stop_guard_state"
SESSION_BLOCKS="$MEM/.session_blocks"
VERIFY="$PROJECT_ROOT/.claude/verify.toml"
NOW="$(date '+%Y-%m-%d %H:%M')"

GATE_BLOCK_LIMIT=2
SESSION_BLOCK_CAP=8

RAW="$(cat)"

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' \
    | awk 'BEGIN{ORS=""} {if(NR>1) printf "\\n"; print}'
}

emit_block() {
  printf '{"decision":"block","reason":"%s"}\n' "$(printf '%s' "$1" | json_escape)"
  exit 0
}
emit_pass() {
  printf '{"continue":true}\n'
  exit 0
}

mkdir -p "$MEM"

# Claude Code 네이티브 루프 방지: 이미 Stop hook 때문에 이어서 도는 중이면 검사만 하고 통과시키지 않는다.
# (여기서는 카운터 기반 상한과 함께 쓰므로 stop_hook_active 는 참고만 한다.)
STOP_ACTIVE=0
printf '%s' "$RAW" | grep -qE '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && STOP_ACTIVE=1

if [ ! -f "$QA" ]; then
  { printf '# QA\n\n## 실행한 검증\n\n'; printf '| 명령 | 결과 | 일시 | 메모 |\n'; printf '| --- | --- | --- | --- |\n'; } > "$QA"
fi

# ---------------------------------------------------------------
# 1) verify.toml 실행
# ---------------------------------------------------------------
RUN_CHECKS=0
FAILED_CHECKS=0
SUMMARY=""

run_one() {
  # $1 name, $2 command, $3 timeout
  local name="$1" cmd="$2" tmo="$3" out code status memo
  RUN_CHECKS=$((RUN_CHECKS + 1))
  if command -v timeout >/dev/null 2>&1; then
    out="$(cd "$PROJECT_ROOT" && timeout "${tmo}s" bash -lc "$cmd" 2>&1)"
    code=$?
  else
    out="$(cd "$PROJECT_ROOT" && bash -lc "$cmd" 2>&1)"
    code=$?
  fi
  if [ "$code" -eq 0 ]; then status="통과"; else status="실패"; FAILED_CHECKS=$((FAILED_CHECKS + 1)); fi
  memo="$cmd"
  [ "$code" -eq 124 ] && memo="$memo | timeout(${tmo}s)"
  [ "$code" -ne 0 ] && memo="$memo | exit=$code"
  # 마지막 400자만, 파이프와 줄바꿈은 표를 깨지 않게 치환
  local tail_out
  tail_out="$(printf '%s' "$out" | tail -c 400 | tr '|' '/' | tr '\n' ' ')"
  [ -n "$tail_out" ] && memo="$memo | $tail_out"
  printf '| verify:%s | %s | %s | %s |\n' "$name" "$status" "$NOW" "$memo" >> "$QA"
  SUMMARY="$SUMMARY $name=$status"
}

if [ -f "$VERIFY" ]; then
  V_NAME=""; V_CMD=""; V_ENABLED="true"; V_TIMEOUT="120"
  flush_section() {
    [ -z "$V_NAME" ] && return 0
    [ "$V_ENABLED" != "true" ] && return 0
    [ -z "$V_CMD" ] && return 0
    run_one "$V_NAME" "$V_CMD" "$V_TIMEOUT"
  }
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    trimmed="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    case "$trimmed" in
      ''|'#'*) continue ;;
    esac
    if printf '%s' "$trimmed" | grep -qE '^\[[^]]+\]$'; then
      flush_section
      V_NAME="$(printf '%s' "$trimmed" | sed -e 's/^\[//' -e 's/\]$//')"
      V_CMD=""; V_ENABLED="true"; V_TIMEOUT="120"
      continue
    fi
    key="$(printf '%s' "$trimmed" | sed -E 's/^([A-Za-z_]+)[[:space:]]*=.*$/\1/')"
    val="$(printf '%s' "$trimmed" | sed -E 's/^[A-Za-z_]+[[:space:]]*=[[:space:]]*//')"
    case "$key" in
      command)  V_CMD="$(printf '%s' "$val" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")" ;;
      enabled)  case "$val" in *true*) V_ENABLED="true" ;; *) V_ENABLED="false" ;; esac ;;
      timeout)  printf '%s' "$val" | grep -qE '^[0-9]+$' && V_TIMEOUT="$val" ;;
    esac
  done < "$VERIFY"
  flush_section
fi

PASSED=$((RUN_CHECKS - FAILED_CHECKS))
[ -f "$METRICS" ] && printf '| %s | verify 실행=%s 통과=%s 실패=%s |\n' "$NOW" "$RUN_CHECKS" "$PASSED" "$FAILED_CHECKS" >> "$METRICS"

# ---------------------------------------------------------------
# 2) 게이트 판정
# ---------------------------------------------------------------
REASONS=""
add_reason() { REASONS="$REASONS$1 "; }

if [ "$FAILED_CHECKS" -gt 0 ]; then
  add_reason "verify.toml 검사 ${FAILED_CHECKS}건 실패(${SUMMARY# }). 실패한 검사를 수정하고 reviewer 또는 tester 서브에이전트를 실행한 뒤 QA.md 에 '## reviewer 보고' 또는 '## tester 보고' 를 추가한다."
fi

# 보안 관련 수정인데 security-reviewer 보고가 없는 경우
HAS_SEC_CHANGE=0
if [ -f "$MODIFIED" ] && grep -qiE '^\| [0-9]{4}-.*(auth|login|token|password|secret|credential|session|permission|인증|권한|비밀|토큰)' "$MODIFIED"; then
  HAS_SEC_CHANGE=1
fi
HAS_SEC_REPORT=0
grep -qE '^##[[:space:]]+security-reviewer[[:space:]]+보고' "$QA" 2>/dev/null && HAS_SEC_REPORT=1
if [ "$HAS_SEC_CHANGE" -eq 1 ] && [ "$HAS_SEC_REPORT" -eq 0 ]; then
  add_reason "인증/권한/비밀정보 관련 파일이 수정됐다. security-reviewer 서브에이전트를 실행하고 QA.md 에 '## security-reviewer 보고' 를 추가한다."
fi

# CHECKLIST 미완료
if [ -f "$CHECKLIST" ] && grep -qE '^[[:space:]]*-[[:space:]]*\[[[:space:]]\]' "$CHECKLIST"; then
  add_reason "CHECKLIST.md 에 미완료 항목(- [ ])이 남아 있다."
fi

# QA 실패/확인 필요 행
if [ -f "$QA" ] && grep -E '^\|' "$QA" | awk -F'|' 'NF>=5 && $4 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {print $3}' | grep -qE '실패|확인 필요'; then
  add_reason "QA.md 에 실패 또는 확인 필요 검증 행이 남아 있다. tester 서브에이전트로 검증을 보완하고 결과를 반영한다."
fi

# 비강제 권고: 수정은 있는데 verify 통과 + 보안 변경 아님
if [ -z "$REASONS" ] && [ -f "$MODIFIED" ]; then
  MOD_ROWS="$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$MODIFIED" 2>/dev/null || echo 0)"
  if [ "$MOD_ROWS" -ge 5 ]; then
    add_reason "수정 파일이 ${MOD_ROWS}건이다. 품질 강화를 위해 reviewer 서브에이전트로 코드 검토를 한 번 받는다."
  fi
fi

REASON_JOINED="$(printf '%s' "$REASONS" | sed -e 's/[[:space:]]*$//')"

if [ -z "$REASON_JOINED" ]; then
  rm -f "$STATE" 2>/dev/null || true
  emit_pass
fi

# ---------------------------------------------------------------
# 3) 루프/토큰 과사용 방지
# ---------------------------------------------------------------
SESSION_COUNT=0
[ -f "$SESSION_BLOCKS" ] && SESSION_COUNT="$(tr -cd '0-9' < "$SESSION_BLOCKS")"
[ -z "$SESSION_COUNT" ] && SESSION_COUNT=0

if [ "$SESSION_COUNT" -ge "$SESSION_BLOCK_CAP" ]; then
  rm -f "$STATE" 2>/dev/null || true
  printf '{"continue":true,"systemMessage":"세션 차단 한도(%s)에 도달해 Stop 게이트를 advisory 로 전환했다. 남은 위험을 수동으로 확인해 최종 답변에 명시한다."}\n' "$SESSION_BLOCK_CAP"
  exit 0
fi

COUNT=0; LAST_REASON=""; LAST_ASKED=""
if [ -f "$STATE" ]; then
  COUNT="$(grep -E '^count=' "$STATE" | head -1 | cut -d= -f2- | tr -cd '0-9')"
  LAST_REASON="$(grep -E '^reason=' "$STATE" | head -1 | cut -d= -f2-)"
  LAST_ASKED="$(grep -E '^asked=' "$STATE" | head -1 | cut -d= -f2-)"
  [ -z "$COUNT" ] && COUNT=0
fi

if [ "$REASON_JOINED" = "$LAST_REASON" ]; then
  COUNT=$((COUNT + 1))
else
  COUNT=1
  LAST_ASKED=""
fi

# 같은 사유로 이미 사용자 확인을 요청했으면 통과시킨다(사용자가 응답한 것으로 본다).
if [ "$COUNT" -ge "$GATE_BLOCK_LIMIT" ] && [ "$LAST_ASKED" = "$REASON_JOINED" ]; then
  rm -f "$STATE" 2>/dev/null || true
  emit_pass
fi

SESSION_COUNT=$((SESSION_COUNT + 1))
printf '%s' "$SESSION_COUNT" > "$SESSION_BLOCKS"

if [ "$COUNT" -ge "$GATE_BLOCK_LIMIT" ]; then
  printf 'count=%s\nreason=%s\nasked=%s\n' "$COUNT" "$REASON_JOINED" "$REASON_JOINED" > "$STATE"
  emit_block "게이트가 ${GATE_BLOCK_LIMIT}회 차단했다. 사용자에게 진행 여부를 확인한다. 사유: $REASON_JOINED 사용자가 승인하면 그대로 완료하고, 거부하면 해당 작업을 계속한다."
else
  printf 'count=%s\nreason=%s\nasked=\n' "$COUNT" "$REASON_JOINED" > "$STATE"
  emit_block "$REASON_JOINED"
fi
