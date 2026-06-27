#!/usr/bin/env bash
# global_stop_check.ps1 의 bash 미러. jq 필요.
ctx="[전역 종료 전 확인]
- 최종 답변 전 검증 결과, 실행하지 못한 검증, 남은 위험을 확인하세요."
printf '%s' "$ctx" | jq -Rsc '{decision:"allow",reason:"전역 종료 전 확인",hookSpecificOutput:{hookEventName:"Stop",additionalContext:.}}'