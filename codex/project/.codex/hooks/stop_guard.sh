#!/usr/bin/env bash
# stop_guard.ps1 의 bash 미러(비Windows 환경용). jq 필요.
# 주의: Windows Git Bash 환경에서는 jq 미지원으로 검증되지 않았다. Linux/mac + jq 로 리허설 필요.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEM="$ROOT/.codex-memory"
VERIFY="$ROOT/.codex/verify.toml"
NOW=$(date '+%Y-%m-%d %H:%m')

[ -f "$MEM/QA.md" ] || printf '# QA\n\n## 실행한 검증\n\n| 명령 | 결과 | 일시 | 메모 |\n| --- | --- | --- | --- |\n' > "$MEM/QA.md"

# verify.toml 파서: 섹션별 command/enabled/timeout 추출.
declare -A V_CMD V_EN V_TO
section=""
while IFS= read -r line; do
  line="${line%%#*}"
  line="$(echo "$line" | sed 's/[[:space:]]*$//')"
  [ -z "$line" ] && continue
  if echo "$line" | grep -qE '^\[.+\]$'; then
    section=$(echo "$line" | sed -E 's/^\[(.+)\]$/\1/' | tr -d ' ')
  elif echo "$line" | grep -qE '^command[[:space:]]*='; then
    V_CMD[$section]=$(echo "$line" | sed -E 's/^command[[:space:]]*=[[:space:]]*//' | sed 's/^"//; s/"$//')
  elif echo "$line" | grep -qE '^enabled[[:space:]]*='; then
    V_EN[$section]=$(echo "$line" | sed -E 's/^enabled[[:space:]]*=[[:space:]]*//')
  elif echo "$line" | grep -qE '^timeout[[:space:]]*='; then
    V_TO[$section]=$(echo "$line" | sed -E 's/^timeout[[:space:]]*=[[:space:]]*//')
  fi
done < "$VERIFY" 2>/dev/null

# 검사 실행.
failed=0; run=0; summary=""
for sec in lint test typecheck build; do
  en="${V_EN[$sec]:-true}"
  cmd="${V_CMD[$sec]:-}"
  [ "$en" = "false" ] && continue
  [ -z "$cmd" ] && continue
  run=$((run+1))
  to="${V_TO[$sec]:-120}"
  status="통과"
  out=$(timeout "$to" bash -c "$cmd" 2>&1) || status="실패"
  [ "$status" = "실패" ] && failed=$((failed+1))
  memo="$cmd"
  tail=$(printf '%s' "$out" | tail -c 500 | tr '\n' ' ' | tr '|' '/')
  [ -n "$tail" ] && memo="$memo | $tail"
  printf '| verify:%s | %s | %s | %s |\n' "$sec" "$status" "$NOW" "$memo" >> "$MEM/QA.md"
  summary="$summary$sec=$status "
done

[ -f "$MEM/METRICS.md" ] && printf '| %s | verify 실행=%s 통과=%s 실패=%s |\n' "$NOW" "$run" "$((run-failed))" "$failed" >> "$MEM/METRICS.md"

# 수정 파일 + 보안 변경 감지.
modrows=0; hassec=0
if [ -f "$MEM/MODIFIED_FILES.md" ]; then
  modrows=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$MEM/MODIFIED_FILES.md" 2>/dev/null | head -1)
  [ -z "$modrows" ] && modrows=0
  grep -qiE 'auth|login|token|password|secret|credential|인증|권한|비밀|토큰' "$MEM/MODIFIED_FILES.md" && hassec=1
fi

# 보고서 마커.
hasrev=0; hassecrev=0
[ -f "$MEM/QA.md" ] && grep -qE '^##\s+reviewer\s+보고' "$MEM/QA.md" && hasrev=1
[ -f "$MEM/QA.md" ] && grep -qE '^##\s+security-reviewer\s+보고' "$MEM/QA.md" && hassecrev=1

# 실패 QA 행.
# 표의 '결과' 열만 본다. 본문 아무 곳의 '실패' 단어로 오차단되지 않게 한다.
failedqa=0
[ -f "$MEM/QA.md" ] && failedqa=$(grep -E '^\|' "$MEM/QA.md" | awk -F'|' 'NF>=5 && $4 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {print $3}' | grep -cE '실패|확인 필요' | head -1)
[ -z "$failedqa" ] && failedqa=0

# CHECKLIST 미완.
openck=0
[ -f "$MEM/CHECKLIST.md" ] && openck=$(grep -cE '^[[:space:]]*-[[:space:]]*\[[[:space:]]\]' "$MEM/CHECKLIST.md" 2>/dev/null | head -1)
[ -z "$openck" ] && openck=0

reasons=()
# advisory 는 종료를 막지 않고 additionalContext 로만 전달한다.
advisories=()
[ "$failed" -gt 0 ] && reasons+=("verify.toml 검사 $failed 건 실패($summary). 실패한 검사를 수정하고 reviewer/tester 서브에이전트 실행 후 QA.md 에 ## reviewer 보고(또는 ## tester 보고)를 추가하세요.")
[ "$hassec" = "1" ] && [ "$hassecrev" = "0" ] && reasons+=("인증/권한/비밀정보 관련 파일이 수정됐습니다. security-reviewer 서브에이전트 실행 후 QA.md 에 ## security-reviewer 보고를 추가하세요.")
# CHECKLIST 는 여러 세션에 걸쳐 소진하므로 block 하지 않는다(advisory).
[ "$openck" -gt 0 ] && advisories+=("CHECKLIST.md 에 미완료 항목(- [ ])이 남아 있습니다. 남은 항목을 최종 답변에 명시하세요.")
[ "$failedqa" -gt 0 ] && reasons+=("QA.md 에 실패/확인 필요 검증 행이 남아 있습니다. tester 서브에이전트로 검증 보완 후 결과를 반영하세요.")
# 서브에이전트 강제 실행은 토큰 소비가 크므로 block 하지 않는다(advisory).
[ "$modrows" -ge 5 ] && advisories+=("수정 파일이 $modrows 건 있습니다. 필요하면 reviewer 서브에이전트로 코드 검토를 받으세요.")

# 루프/토큰 과사용 방지(A+B+C): 게이트당 한도 2, 세션 전역 캡 8, 한도 시 사용자 확인 block.
GATE_LIMIT=1
SESSION_CAP=3
SB="$MEM/.session_blocks"
sb=0; [ -f "$SB" ] && sb=$(cat "$SB" 2>/dev/null | grep -oE '[0-9]+' || echo 0)

# B: 세션 전역 캡 초과 → 모든 게이트 advisory.
if [ "$sb" -ge "$SESSION_CAP" ]; then
  rm -f "$MEM/.stop_guard_state"
  printf '{"continue":true,"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"[Stop] 세션 차단 한도(%s)에 도달해 모든 게이트를 advisory 로 전환합니다. 더 이상 block 하지 않습니다. 남은 위험을 수동으로 확인해 최종 답변에 명시하세요."}}\n' "$SESSION_CAP"
  exit 0
fi

if [ "${#reasons[@]}" -gt 0 ]; then
  joined=$(IFS=' ' ; printf '%s' "${reasons[*]}")
  count=0; lastr=""; asked=""
  if [ -f "$MEM/.stop_guard_state" ]; then
    count=$(grep -oE '^count=[0-9]+' "$MEM/.stop_guard_state" | cut -d= -f2)
    lastr=$(grep -oE '^reason=.*' "$MEM/.stop_guard_state" | cut -d= -f2-)
    asked=$(grep -oE '^asked=.*' "$MEM/.stop_guard_state" | cut -d= -f2-)
  fi
  [ "$joined" = "$lastr" ] && count=$((count+1)) || { count=1; asked=""; }
  # C: 같은 사유로 이미 사용자 확인 요청했으면 → 통과.
  if [ "$count" -ge "$GATE_LIMIT" ] && [ "$asked" = "$joined" ]; then
    rm -f "$MEM/.stop_guard_state"
    if [ "${#advisories[@]}" -gt 0 ]; then
      adv=$(IFS=' ' ; printf '%s' "${advisories[*]}")
      printf '{"continue":true,"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":%s}}\n' "$(printf '%s' "$adv" | jq -Rs .)"
    else
      printf '{"continue":true}\n'
    fi
    exit 0
  fi
  # 세션 전역 차단 수 증가.
  echo $((sb+1)) > "$SB"
  if [ "$count" -ge "$GATE_LIMIT" ]; then
    printf 'count=%s\nreason=%s\nasked=%s\n' "$count" "$joined" "$joined" > "$MEM/.stop_guard_state"
    askmsg="게이트가 차단했습니다. 사용자에게 진행 여부를 확인하세요. 사유: $joined 사용자가 승인하면 완료, 거부하면 중단하세요. (자동 해제 대신 사용자 확인으로 전환 - 토큰 낭비 방지)"
    printf '{"decision":"block","reason":%s}\n' "$(printf '%s' "$askmsg" | jq -Rs .)"
  else
    printf 'count=%s\nreason=%s\nasked=\n' "$count" "$joined" > "$MEM/.stop_guard_state"
    printf '{"decision":"block","reason":%s}\n' "$(printf '%s' "$joined" | jq -Rs .)"
  fi
else
  rm -f "$MEM/.stop_guard_state"
  if [ "${#advisories[@]}" -gt 0 ]; then
    adv=$(IFS=' ' ; printf '%s' "${advisories[*]}")
    printf '{"continue":true,"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":%s}}\n' "$(printf '%s' "$adv" | jq -Rs .)"
  else
    printf '{"continue":true}\n'
  fi
fi