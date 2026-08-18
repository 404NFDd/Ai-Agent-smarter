#!/usr/bin/env bash
# PostToolUse hook: 수정 파일 기록(CCTV) + 셀프체크 리마인더.
# matcher: Edit|Write|MultiEdit|NotebookEdit|Bash
# 의존성: bash, coreutils, grep -E (jq 불필요)
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEM="$PROJECT_ROOT/.claude-memory"
mkdir -p "$MEM"

MODIFIED="$MEM/MODIFIED_FILES.md"
QA="$MEM/QA.md"
METRICS="$MEM/METRICS.md"
NOW="$(date '+%Y-%m-%d %H:%M')"

RAW="$(cat)"

# --- JSON 최소 파서(jq 없이 필요한 평문 필드만 뽑는다) ---
# tool_input.old_string 등에 같은 키 이름이 텍스트로 들어 있으면 오탐할 수 있다.
# file_path 는 tool_input 의 첫 키이므로 첫 매치만 쓴다.
json_first_string() {
  # $1: 키 이름
  printf '%s' "$RAW" \
    | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" \
    | head -1 \
    | sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"$//" \
    | sed -e 's/\\\\/\x01/g' -e 's/\\"/"/g' -e 's/\\n/ /g' -e 's/\x01/\\/g'
}

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' \
    | awk 'BEGIN{ORS=""} {if(NR>1) printf "\\n"; print}'
}

TOOL_NAME="$(json_first_string tool_name)"
FILE_PATH="$(json_first_string file_path)"

# --- 헤더 보장 ---
if [ ! -f "$MODIFIED" ]; then
  { printf '# MODIFIED FILES\n\n'; printf '| 일시 | 파일 | 작업 | 메모 |\n'; printf '| --- | --- | --- | --- |\n'; } > "$MODIFIED"
fi
if [ ! -f "$QA" ]; then
  { printf '# QA\n\n## 실행한 검증\n\n'; printf '| 명령 | 결과 | 일시 | 메모 |\n'; printf '| --- | --- | --- | --- |\n'; } > "$QA"
fi

MODIFIED_COUNT=0

case "$TOOL_NAME" in
  Edit|Write|MultiEdit|NotebookEdit)
    if [ -n "$FILE_PATH" ]; then
      REL="${FILE_PATH#$PROJECT_ROOT/}"
      printf '| %s | %s | 도구 사용 | %s |\n' "$NOW" "$REL" "$TOOL_NAME" >> "$MODIFIED"
      MODIFIED_COUNT=1
    else
      printf '| %s | 파일명 추출 실패 | 도구 사용 | %s |\n' "$NOW" "$TOOL_NAME" >> "$MODIFIED"
    fi
    ;;
  Bash)
    # 모델이 직접 돌린 검증 명령의 결과를 QA 에 남긴다.
    if printf '%s' "$RAW" | grep -qiE '(npm|pnpm|yarn|make|cargo|go|dotnet)?[[:space:]]*(test|lint|build|typecheck|tsc|pytest|vitest|jest|verify)'; then
      RESULT="성공"
      if printf '%s' "$RAW" | grep -qiE '"(is_error|isError)"[[:space:]]*:[[:space:]]*true|FAIL|failed|Error:|error TS[0-9]|exit code [1-9]'; then
        RESULT="실패"
      fi
      printf '| hook 감지 검증 명령 | %s | %s | Bash 검증 명령 실행 |\n' "$RESULT" "$NOW" >> "$QA"
    fi
    ;;
esac

[ -f "$METRICS" ] && printf '| %s | post_tool_use tool=%s files=%s |\n' "$NOW" "$TOOL_NAME" "$MODIFIED_COUNT" >> "$METRICS"

# --- 셀프체크 리마인더(강제 차단이 아니라 상기 장치) ---
if [ "$MODIFIED_COUNT" -eq 0 ]; then
  exit 0
fi

TOTAL="$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$MODIFIED" 2>/dev/null || echo 0)"

MSG="[셀프체크 리마인더]
- 방금 수정: $REL (이번 세션 누적 $TOTAL 건)
- 에러 처리와 예외 경로를 추가했는가? 빠진 오류 처리가 없는지 확인한다."

# 절대경로가 아니라 프로젝트 상대경로로 판단한다. 홈/마운트 경로에 session 같은 단어가 들어가 오탐하는 것을 막는다.
if printf '%s' "$REL" | grep -qiE 'auth|login|token|password|secret|credential|session|permission|인증|권한|비밀|토큰'; then
  MSG="$MSG
- 보안상 위험한 부분은 없는가? 인증/권한/입력 검증/secret 노출을 점검하고 security-reviewer 서브에이전트 검토를 받는다.
- 검토 보고는 QA.md 의 \`## security-reviewer 보고\` 헤더 아래에 남긴다. 이 헤더가 없으면 Stop 게이트가 종료를 막는다."
else
  MSG="$MSG
- 보안상 위험한 부분은 없는가? 입력 검증과 secret 노출 여부를 확인한다."
fi

if [ "$TOTAL" -ge 5 ]; then
  MSG="$MSG
- 수정 파일이 $TOTAL 건이다. reviewer 서브에이전트로 코드 검토를 권장한다."
fi

ESCAPED="$(printf '%s' "$MSG" | json_escape)"
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$ESCAPED"
exit 0
