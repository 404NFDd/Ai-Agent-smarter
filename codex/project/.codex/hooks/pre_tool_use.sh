#!/usr/bin/env bash
# pre_tool_use.ps1 의 bash 미러(비Windows 환경용). jq 필요.
# 주의: 이 스크립트는 Windows Git Bash 환경에서는 jq 미지원으로 검증되지 않았다.
# Linux/mac 에서 jq 설치 후 리허설 필요.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS="$ROOT/.agents/skills"
MEM="$ROOT/.codex-memory"
MAP="$SKILLS/MAP.toml"

RAW=$(cat)
TOOL_NAME=$(printf '%s' "$RAW" | jq -r '.tool_name // empty' 2>/dev/null || echo '')
TOOL_COMMAND=$(printf '%s' "$RAW" | jq -r '.tool_input.command // empty' 2>/dev/null || echo '')
PATCH_TEXT=$(printf '%s' "$RAW" | jq -r '.tool_input.input // empty' 2>/dev/null || echo '')
TOOL_TEXT="$TOOL_NAME $TOOL_COMMAND"

skills=()
addskill() {
  for s in "${skills[@]:-}"; do [ "$s" = "$1" ] && return; done
  [ "${#skills[@]}" -lt 3 ] && skills+=("$1")
}

# 계획 게이트(C): apply_patch 시 .plan_required 존재 + PLAN.md 없으면 block.
if [ "$TOOL_NAME" = "apply_patch" ] && [ -f "$MEM/.plan_required" ]; then
  gate_block=1
  if [ -f "$MEM/PLAN.md" ]; then
    planmt=$(date -r "$MEM/PLAN.md" +%s 2>/dev/null || stat -c %Y "$MEM/PLAN.md" 2>/dev/null || echo 0)
    reqmt=$(date -d "$(cat "$MEM/.plan_required")" +%s 2>/dev/null || echo 0)
    if [ "$planmt" != "0" ] && [ "$reqmt" != "0" ] && [ "$planmt" -ge "$reqmt" ]; then gate_block=0; fi
  fi
  if [ "$gate_block" = "1" ]; then
    reason="큰 작업이 감지되었습니다. 구현(apply_patch) 전에 planner 서브에이전트로 계획을 세우고 .codex-memory/PLAN.md 를 먼저 저장하세요. PLAN.md 저장 후에는 자동으로 게이트가 해제됩니다."
    GATE_LIMIT=2; SESSION_CAP=8
    SB="$MEM/.session_blocks"; sb=0; [ -f "$SB" ] && sb=$(cat "$SB" 2>/dev/null | grep -oE '[0-9]+' || echo 0)
    # B: 세션 전역 캡 초과 → advisory.
    if [ "$sb" -ge "$SESSION_CAP" ]; then
      rm -f "$MEM/.plan_required" "$MEM/.plan_gate_state"
      printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"세션 차단 한도(%s)에 도달해 계획 게이트를 advisory 로 전환합니다. 수동으로 PLAN.md 를 확인하고 위험을 답변에 명시하세요."}}\n' "$SESSION_CAP"
      exit 0
    fi
    count=0; lastr=""; asked=""
    if [ -f "$MEM/.plan_gate_state" ]; then
      count=$(grep -oE '^count=[0-9]+' "$MEM/.plan_gate_state" | cut -d= -f2)
      lastr=$(grep -oE '^reason=.*' "$MEM/.plan_gate_state" | cut -d= -f2-)
      asked=$(grep -oE '^asked=.*' "$MEM/.plan_gate_state" | cut -d= -f2-)
    fi
    [ "$reason" = "$lastr" ] && count=$((count+1)) || { count=1; asked=""; }
    # C: 같은 사유로 이미 사용자 확인 요청했으면 → 통과(게이트 해제).
    if [ "$count" -ge "$GATE_LIMIT" ] && [ "$asked" = "$reason" ]; then
      rm -f "$MEM/.plan_required" "$MEM/.plan_gate_state"
      printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"계획 게이트: 사용자가 진행을 승인해 게이트를 해제합니다."}}\n'
      exit 0
    fi
    echo $((sb+1)) > "$SB"
    if [ "$count" -ge "$GATE_LIMIT" ]; then
      printf 'count=%s\nreason=%s\nasked=%s\n' "$count" "$reason" "$reason" > "$MEM/.plan_gate_state"
      askmsg="계획 게이트가 2회 차단했습니다. 사용자에게 진행 여부를 확인하세요. 사유: $reason 사용자가 승인하면 PLAN.md 없이 진행, 거부하면 계획 작성으로 돌아가세요. (자동 해제 대신 사용자 확인으로 전환 - 토큰 낭비 방지)"
      printf '{"decision":"block","reason":%s}\n' "$(printf '%s' "$askmsg" | jq -Rs .)"
    else
      printf 'count=%s\nreason=%s\nasked=\n' "$count" "$reason" > "$MEM/.plan_gate_state"
      printf '{"decision":"block","reason":%s}\n' "$(printf '%s' "$reason" | jq -Rs .)"
    fi
    exit 0
  else
    rm -f "$MEM/.plan_required" "$MEM/.plan_gate_state"
  fi
fi

# Bash 위험 작업 키워드 라우팅.
printf '%s' "$TOOL_TEXT" | grep -qiE '\brm\b|remove-item|del\b|erase\b|삭제|제거' && addskill git-workflow
printf '%s' "$TOOL_TEXT" | grep -qiE 'migration|migrate|schema|db|database|마이그레이션|스키마' && addskill database-migration
printf '%s' "$TOOL_TEXT" | grep -qiE 'install|add package|npm|pnpm|yarn|pip|cargo|lockfile|패키지|의존성|설치' && addskill dependency-management
printf '%s' "$TOOL_TEXT" | grep -qiE 'deploy|release|publish|rollback|배포|릴리즈|롤백' && addskill release-deploy
printf '%s' "$TOOL_TEXT" | grep -qiE 'secret|token|password|auth|permission|보안|시크릿|인증|권한' && addskill security
printf '%s' "$TOOL_TEXT" | grep -qiE 'timeout|retry|rate limit|quota|idempotency|타임아웃|재시도|멱등|장애' && addskill resilience
printf '%s' "$TOOL_TEXT" | grep -qiE 'i18n|locale|timezone|currency|date format|다국어|로케일|시간대|통화' && addskill i18n-time-currency

# MAP.toml path/content 매칭(subshell 변수 손실 방지: 임시 파일로 수집).
if [ "$TOOL_NAME" = "apply_patch" ] && [ -f "$MAP" ]; then
  matched=$(mktemp)
  # path 섹션: glob 매칭.
  targets=$(printf '%s' "$PATCH_TEXT" | grep -oE '^\*\*\*\s+(Update|Add|Delete)\s+File:\s*.+$' 2>/dev/null | sed -E 's/^\*\*\*\s+(Update|Add|Delete)\s+File:\s*//' || true)
  awk '/^\[\[path/{s=1;next}/^\[\[/&&!/path/{s=0}/^pattern/{gsub(/^pattern[[:space:]]*=[[:space:]]*"|"$/,"");p=$0}/^skill/&&s{gsub(/^skill[[:space:]]*=[[:space:]]*"|"$/,"");print p"\t"$0}' "$MAP" > "$matched.path" 2>/dev/null
  while IFS=$'\t' read -r pat skill; do
    [ -z "$pat" ] && continue
    glob_re=$(printf '%s' "$pat" | sed 's/\*\*/§§/g; s/\*/§/g; s/§§/.*/g; s/§/[^\\/]*/g')
    printf '%s\n' "$targets" | grep -qE "^${glob_re}$" && addskill "$skill"
  done < "$matched.path"
  # content 섹션: 파일 본문 패턴.
  awk '/^\[\[content/{s=1;next}/^\[\[/&&!/content/{s=0}/^pattern/{gsub(/^pattern[[:space:]]*=[[:space:]]*"|"$/,"");p=$0}/^skill/&&s{gsub(/^skill[[:space:]]*=[[:space:]]*"|"$/,"");print p"\t"$0}' "$MAP" > "$matched.content" 2>/dev/null
  while IFS=$'\t' read -r pat skill; do
    [ -z "$pat" ] && continue
    printf '%s' "$PATCH_TEXT" | grep -qE "$pat" 2>/dev/null && addskill "$skill"
  done < "$matched.content"
  rm -f "$matched.path" "$matched.content"
fi

# skill 본문 주입.
ctx="[도구 사용 전 확인]"
injected=0
budget=4000
used=0
for s in "${skills[@]:-}"; do
  [ -z "$s" ] && continue
  remaining=$((budget - used)); [ "$remaining" -le 200 ] && break
  f="$SKILLS/$s/SKILL.md"; [ -f "$f" ] || continue
  content=$(head -c "$remaining" "$f")
  ctx="$ctx"$'\n'$'\n'"[skill 매뉴얼: $s]"$'\n'"$content"
  used=$((used + ${#content})); injected=1
done
[ "$injected" = "0" ] && ctx="$ctx"$'\n'"위험 작업이면 관련 skill(.agents/skills/INDEX.md)과 사용자 승인 필요 여부를 확인하세요."

printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:.}}'