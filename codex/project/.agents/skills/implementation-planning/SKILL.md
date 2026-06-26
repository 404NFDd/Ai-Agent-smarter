---
name: implementation-planning
description: 기능 추가, 구현, 큰 작업, 구조 변경, 계획 수립, 작업 분해, PLAN.md, CHECKLIST.md 갱신이 필요한 요청에 사용한다.
---

# Implementation Planning Skill

## 목표

요청을 검증 가능한 작업 단위로 바꾸고, 구현 전에 범위와 완료 조건을 분명히 한다.

## 함께 적용하는 스킬

- 버그 수정 계획은 `../bugfix-debugging/SKILL.md`를 함께 적용한다.
- 검증 범위를 정할 때는 `../testing-qa/SKILL.md`를 함께 적용한다.
- 큰 구조 변경이나 정리는 `../refactoring/SKILL.md`를 함께 적용한다.
- 사용자와 작업 방식 조율이 필요하면 `../ai-agent-collaboration/SKILL.md`를 함께 적용한다.

## 계획 기준

- 가정, 범위, 비범위를 먼저 정리한다.
- 기존 구조를 바꾸기보다 가장 작은 변경으로 목표를 달성하는 방법을 우선한다.
- 해석이 여러 개면 후보를 짧게 제시하고, 위험한 선택은 사용자에게 질문한다.
- 큰 작업은 편집 전 `.codex-memory/PLAN.md`, `CONTEXT.md`, `CHECKLIST.md`를 갱신한다.

## 계획 형식

```text
1. [단계] -> 검증: [확인 방법]
2. [단계] -> 검증: [확인 방법]
3. [단계] -> 검증: [확인 방법]
```

## 구현 중

- 계획이 바뀌면 이유를 `CONTEXT.md`나 `DECISIONS.md`에 남긴다.
- 완료한 항목은 `CHECKLIST.md`에 바로 반영한다.
- 요청 범위 밖의 리팩터링이나 기능 추가는 분리한다.

## 완료 전

- 계획의 각 검증 기준이 실행됐는지 확인한다.
- 실행하지 못한 검증은 `QA.md`와 최종 보고에 남긴다.
