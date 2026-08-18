#!/usr/bin/env bash
# SessionStart hook: 작업 기억 복구 + 세션 상태 초기화.
# stdout 은 Claude 의 세션 컨텍스트에 그대로 추가된다. JSON 을 만들 필요가 없다.
# 의존성: bash, coreutils (jq 불필요)
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEM="$PROJECT_ROOT/.claude-memory"

cat > /dev/null   # stdin(JSON) 은 쓰지 않는다. 파이프만 비운다.

[ -d "$MEM" ] || exit 0

MODIFIED="$MEM/MODIFIED_FILES.md"
STAMP="$(date '+%Y%m%d-%H%M%S')"

# MODIFIED_FILES.md 누적 방지: 이전 내용을 날짜 아카이브로 옮기고 헤더만 남긴다.
if [ -f "$MODIFIED" ]; then
  mv -f "$MODIFIED" "$MEM/MODIFIED_FILES.$STAMP.md" 2>/dev/null || true
fi
{
  printf '# MODIFIED FILES\n\n'
  printf '| 일시 | 파일 | 작업 | 메모 |\n'
  printf '| --- | --- | --- | --- |\n'
} > "$MODIFIED"

# 게이트 카운터 초기화(이전 세션 잔류 제거).
rm -f "$MEM/.stop_guard_state" "$MEM/.session_blocks" 2>/dev/null || true

echo "[작업 기억 복구]"

FOUND=0
for f in PLAN.md CONTEXT.md CHECKLIST.md DECISIONS.md QA.md; do
  if [ -f "$MEM/$f" ]; then
    if [ "$FOUND" -eq 0 ]; then
      echo "다음 파일이 현재 작업 상태다."
      FOUND=1
    fi
    echo "- .claude-memory/$f"
  fi
done
if [ "$FOUND" -eq 0 ]; then
  echo ".claude-memory 파일이 없다. 큰 작업 전 PLAN/CONTEXT/CHECKLIST 를 먼저 작성한다."
fi

# CHECKLIST 미완료 항목을 남은 작업으로 주입.
CHECKLIST="$MEM/CHECKLIST.md"
if [ -f "$CHECKLIST" ]; then
  OPEN="$(grep -nE '^[[:space:]]*-[[:space:]]*\[[[:space:]]\]' "$CHECKLIST" 2>/dev/null | sed 's/^[0-9]*://' || true)"
  if [ -n "$OPEN" ]; then
    echo ""
    echo "[현재 남은 작업]"
    printf '%s\n' "$OPEN"
    echo "이 항목부터 이어서 진행한다. 새로 시작하지 않는다."
  fi
fi

exit 0
