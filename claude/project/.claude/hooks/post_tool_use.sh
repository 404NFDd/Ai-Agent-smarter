#!/usr/bin/env bash
# PostToolUse hook: 수정 파일 기록(CCTV) + 셀프체크 리마인더.
# 리마인더는 컨텍스트에 누적되므로 매 편집마다 넣지 않고 REMIND_EVERY 건마다 한 번만 넣는다.
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

# 셀프체크 리마인더 주입 주기(수정 건수 기준). 1 이면 매번.
REMIND_EVERY=3

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
      # Windows 경로(백슬래시)도 다루기 위해 슬래시로 정규화한 뒤 프로젝트 루트를 자른다.
      NORM="$(printf '%s' "$FILE_PATH" | tr '\\' '/')"
      ROOT_NORM="$(printf '%s' "$PROJECT_ROOT" | tr '\\' '/')"
      REL="${NORM#$ROOT_NORM/}"
      # 루트를 못 자른 경우(드라이브 표기 차이 등)에는 파일명만 남긴다.
      case "$REL" in
        "$NORM") REL="${NORM##*/}" ;;
      esac
      BASE="${REL##*/}"
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

TOTAL="$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$MODIFIED" 2>/dev/null | head -1)"
[ -z "$TOTAL" ] && TOTAL=0

# 보안 관련 파일이면 건수와 무관하게 즉시 알린다. 그 외에는 REMIND_EVERY 건마다 한 번만.
# 매칭은 경로 전체가 아니라 파일명으로 한다. 상위 경로 단어에 의한 오탐을 막는다.
IS_SEC=0
printf '%s' "$BASE" | grep -qiE 'auth|login|token|password|secret|credential|permission|인증|권한|비밀|토큰' && IS_SEC=1

if [ "$IS_SEC" -eq 0 ] && [ "$((TOTAL % REMIND_EVERY))" -ne 0 ]; then
  exit 0
fi

if [ "$IS_SEC" -eq 1 ]; then
  MSG="[셀프체크] $REL (누적 $TOTAL 건)
- 인증/권한/입력 검증/secret 노출을 점검한다. security-reviewer 보고는 QA.md 의 \`## security-reviewer 보고\` 헤더 아래에 남긴다."
else
  MSG="[셀프체크] $REL (누적 $TOTAL 건)
- 오류 처리, 예외 경로, 입력 검증 누락을 확인한다."
fi

ESCAPED="$(printf '%s' "$MSG" | json_escape)"
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$ESCAPED"
exit 0
