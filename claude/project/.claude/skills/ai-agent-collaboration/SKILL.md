---
name: ai-agent-collaboration
description: 사용자와 Claude Code가 같은 작업 상태를 공유하도록 협업 방식과 작업 기억 운영을 정리한다. 사용 조건: Claude Code, subagent, collaboration, handoff, 중간 보고, 질문, 협업 방식, 작업 인계, memory 운영 요청에 사용한다.
---

# AI Agent Collaboration Skill

## 목표

사용자와 Claude Code가 같은 작업 상태를 공유하고, 질문이 필요한 순간과 바로 실행할 순간을 구분한다.

## 함께 적용하는 스킬

- 계획이 필요한 작업은 `../implementation-planning/SKILL.md`를 함께 적용한다.
- 완료 전 검증과 보고는 `../testing-qa/SKILL.md`를 함께 적용한다.
- 리뷰 요청은 `../review/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- 사용자 요청이 구현, 조사, 리뷰, 계획, 질문 중 무엇인지 판단한다.
- 불확실하지만 안전한 가정이 가능한지 확인한다.
- 큰 작업이면 `.claude-memory` 파일을 먼저 확인한다.

## 협업 기준

- 가정은 짧게 명시한다.
- 해석이 여러 개면 후보를 제시한다.
- 위험하거나 되돌리기 어려운 선택은 질문한다.
- 명확한 구현 요청이면 제안에서 멈추지 않고 실행한다.
- 작업 중에는 30초 안팎으로 짧은 진행 상황을 공유한다.

## memory 운영

- `PLAN.md`에는 목표, 범위, 단계, 검증 기준을 둔다.
- `CONTEXT.md`에는 결정 이유, 관련 파일, 제약을 둔다.
- `CHECKLIST.md`에는 완료/남은 작업을 둔다.
- `QA.md`에는 검증 명령, 결과, 남은 위험을 둔다.
- `MODIFIED_FILES.md`에는 수정 파일과 작업 내용을 둔다.

## 완료 전

- 최신 사용자 요청을 다시 확인한다.
- 수정한 것, 검증한 것, 남은 위험을 최종 보고에 포함한다.
