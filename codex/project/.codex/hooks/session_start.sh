#!/usr/bin/env bash
# session_start.ps1 의 bash 미러(비Windows 환경용). jq 필요.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEM="$ROOT/.codex-memory"
mkdir -p "$MEM"

# MODIFIED_FILES.md 누적 방지: 아카이브 후 헤더만 남김.
if [ -f "$MEM/MODIFIED_FILES.md" ]; then
  stamp=$(date +%Y%m%d-%H%M%S)
  mv "$MEM/MODIFIED_FILES.md" "$MEM/MODIFIED_FILES.$stamp.md" 2>/dev/null
fi
printf '# MODIFIED FILES\n\n| 일시 | 파일 | 작업 | 메모 |\n| --- | --- | --- | --- |\n' > "$MEM/MODIFIED_FILES.md"
rm -f "$MEM/.stop_guard_state" "$MEM/.plan_required" "$MEM/.plan_gate_state" "$MEM/.session_blocks" "$MEM/.injected_skills"

ctx="[작업 기억 복구]"
files=()
for f in PLAN.md CONTEXT.md CHECKLIST.md DECISIONS.md QA.md; do
  [ -f "$MEM/$f" ] && files+=(".codex-memory/$f")
done
if [ "${#files[@]}" -gt 0 ]; then
  ctx="$ctx"$'\n'"다음 파일을 먼저 확인하세요."
  for f in "${files[@]}"; do ctx="$ctx"$'\n'"- $f"; done
  ctx="$ctx"$'\n'"현재 남은 작업은 CHECKLIST.md 기준으로 진행하세요."
else
  ctx="$ctx"$'\n'".codex-memory 파일이 없으면 큰 작업 전 PLAN/CONTEXT/CHECKLIST 를 먼저 작성하세요."
fi

# CHECKLIST 미완료 항목 주입.
if [ -f "$MEM/CHECKLIST.md" ]; then
  open=$(grep -E '^[[:space:]]*-[[:space:]]*\[[[:space:]]\]' "$MEM/CHECKLIST.md" 2>/dev/null || true)
  if [ -n "$open" ]; then
    ctx="$ctx"$'\n'$'\n'"[현재 남은 작업]"
    while IFS= read -r line; do
      [ -n "$line" ] && ctx="$ctx"$'\n'"- $(printf '%s' "$line" | sed 's/^[[:space:]]*//')"
    done <<< "$open"
  fi
fi

printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:.}}'