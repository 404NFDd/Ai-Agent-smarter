#!/usr/bin/env bash
# post_tool_use.ps1 의 bash 미러(비Windows 환경용). jq 필요.
# 리마인더는 컨텍스트에 누적되므로 수정이 없으면 아무것도 출력하지 않고,
# 수정이 있어도 REMIND_EVERY 건마다 한 번만 출력한다.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEM="$ROOT/.codex-memory"
SKILLS="$ROOT/.agents/skills"
mkdir -p "$MEM"
NOW=$(date '+%Y-%m-%d %H:%m')

# 셀프체크 리마인더 주입 주기(누적 수정 건수 기준). 1 이면 매번.
REMIND_EVERY=3

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

# 셀프체크 리마인더. 수정이 없으면 컨텍스트를 늘리지 않는다.
[ "${#modified[@]}" -gt 0 ] || exit 0

joined=$(IFS=, ; printf '%s' "${modified[*]}")

# 보안 키워드는 전체 경로가 아니라 파일명으로 본다. 상위 폴더명에 의한 오탐을 막는다.
hassec=0
for f in "${modified[@]}"; do
  base="${f##*/}"
  printf '%s' "$base" | grep -qiE 'auth|login|token|password|secret|credential|permission|인증|권한|비밀|토큰' && hassec=1
done

# 보안 관련이면 즉시, 그 외에는 누적 REMIND_EVERY 건마다 한 번만.
total=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$MEM/MODIFIED_FILES.md" 2>/dev/null || echo 0)
if [ "$hassec" = "0" ] && [ "$((total % REMIND_EVERY))" -ne 0 ]; then
  exit 0
fi

ctx="[셀프체크] $joined (누적 $total 건)"
if [ "$hassec" = "1" ]; then
  ctx="$ctx"$'\n'"- 인증/권한/입력 검증/secret 노출을 점검하세요. security-reviewer 보고는 QA.md 의 ## security-reviewer 보고 헤더 아래에 남깁니다."
else
  ctx="$ctx"$'\n'"- 오류 처리, 예외 경로, 입력 검증 누락을 확인하세요."
fi

printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:.}}'