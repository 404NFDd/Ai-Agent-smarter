#!/usr/bin/env bash
# global_session_start.ps1 의 bash 미러. jq 필요.
ctx="[전역 세션 시작 알림]
응답 첫 줄에 \`[HOOK: SessionStart 읽음]\`을 표시하세요.
프로젝트 루트에 다음 memory 파일이 있으면 먼저 확인하세요.
- AGENTS.md
- .codex-memory/PLAN.md
- .codex-memory/CONTEXT.md
- .codex-memory/CHECKLIST.md
- .codex-memory/DECISIONS.md
- .codex-memory/QA.md"
printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:.}}'