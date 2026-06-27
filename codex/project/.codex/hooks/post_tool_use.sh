#!/usr/bin/env bash
# post_tool_use.ps1 의 bash 미러(비Windows 환경용). jq 필요.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEM="$ROOT/.codex-memory"
SKILLS="$ROOT/.agents/skills"
mkdir -p "$MEM"
NOW=$(date '+%Y-%m-%d %H:%m')

[ -f "$MEM/MODIFIED_FILES.md" ] || printf '# MODIFIED FILES\n\n| 일시 | 파일 | 작업 | 메모 |\n| --- | --- | --- | --- |\n' > "$MEM/MODIFIED_FILES.md"
[ -f "$MEM/QA.md" ] || printf '# QA\n\n## 실행한 검증\n\n| 명령 | 결과 | 일시 | 메모 |\n| --- | --- | --- | --- |\n' > "$MEM/QA.md"

RAW=$(cat)
TOOL_NAME=$(printf '%s' "$RAW" | jq -r '.tool_name // empty' 2>/dev/null || echo '')
TOOL_COMMAND=$(printf '%s' "$RAW" | jq -r '.tool_input.command // empty' 2>/dev/null || echo '')
PATCH_TEXT=$(printf '%s' "$RAW" | jq -r '.tool_input.input // empty' 2>/dev/null || echo '')
TOOL_RESPONSE=$(printf '%s' "$RAW" | jq -r '.tool_response // empty' 2>/dev/null || echo '')

modified=()
if [ "$TOOL_NAME" = "apply_patch" ]; then
  while IFS= read -r p; do
    [ -n "$p" ] && modified+=("$p") && printf '| %s | %s | 도구 사용 | apply_patch 실행 |\n' "$NOW" "$p" >> "$MEM/MODIFIED_FILES.md"
  done < <(printf '%s' "$PATCH_TEXT" | grep -oE '^\*\*\*\s+(Update|Add|Delete)\s+File:\s*.+$' 2>/dev/null | sed -E 's/^\*\*\*\s+(Update|Add|Delete)\s+File:\s*//' || true)
fi

# 모델이 실행한 검증 명령 기록.
if [ "$TOOL_NAME" = "Bash" ] && printf '%s' "$TOOL_COMMAND" | grep -qiE 'test|lint|build|typecheck|pytest|verify|검증|테스트'; then
  result="성공"
  printf '%s' "$TOOL_RESPONSE" | grep -qiE 'fail|failed|error|exit code.*[1-9]|실패' && result="실패"
  printf '| hook 감지 검증 명령 | %s | %s | Bash 검증 명령 실행 |\n' "$result" "$NOW" >> "$MEM/QA.md"
fi

[ -f "$MEM/METRICS.md" ] && printf '| %s | post_tool_use tool=%s files=%s |\n' "$NOW" "$TOOL_NAME" "${#modified[@]}" >> "$MEM/METRICS.md"

# 셀프체크 리마인더(3항).
ctx="[PostToolUse] 수정 또는 검증 흔적을 memory 파일에 기록했습니다."
if [ "${#modified[@]}" -gt 0 ]; then
  joined=$(IFS=, ; printf '%s' "${modified[*]}")
  hassec=0
  for f in "${modified[@]}"; do
    printf '%s' "$f" | grep -qiE 'auth|login|token|password|secret|credential|인증|권한|비밀|토큰' && hassec=1
  done
  ctx="$ctx"$'\n'"[셀프체크 리마인더]"
  ctx="$ctx"$'\n'"- 수정 파일 ${#modified[@]}건: $joined"
  ctx="$ctx"$'\n'"- 에러 처리/예외 경로를 추가했나요? 빠진 오류 처리가 없는지 확인하세요."
  if [ "$hassec" = "1" ]; then
    ctx="$ctx"$'\n'"- 보안상 위험한 부분은 없나요? 인증/권한/입력검증/secret 노출 점검 후 security-reviewer 서브에이전트 검토를 권장합니다."
  else
    ctx="$ctx"$'\n'"- 보안상 위험한 부분은 없나요? 입력 검증과 secret 노출 여부를 확인하세요."
  fi
  ctx="$ctx"$'\n'"- 수정 파일이 ${#modified[@]}개 있음: reviewer 서브에이전트로 코드 검토를 권장합니다."
fi

printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:.}}'