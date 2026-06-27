#!/usr/bin/env bash
# global_user_prompt_submit.ps1 의 bash 미러. jq 필요.
ctx="[전역 요청 시작 지침]
응답 첫 줄에 \`[HOOK: UserPromptSubmit 읽음]\`을 표시하세요.
- 반드시 필요할 때를 제외하고 한글로 답하세요.
- 프로젝트 루트에 AGENTS.md가 있으면 먼저 확인하세요.
- 프로젝트 hook 또는 skill이 있으면 더 구체적인 프로젝트 지침으로 취급하세요."
printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:.}}'