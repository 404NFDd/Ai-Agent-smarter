#!/usr/bin/env bash
# global_post_tool_use.ps1 의 bash 미러. jq 필요.
ctx="[전역 도구 사용 후 확인]
- 파일을 수정했거나 검증을 실행했다면 관련 기록 파일에 반영하세요."
printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:.}}'