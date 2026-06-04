---
name: testing-qa
description: test, lint, typecheck, build, verify, QA, coverage, fixture, test data, 테스트 데이터, 테스트 fixture, 검증, 빌드, 타입체크, 실패 확인 요청에 사용한다.
---

# Testing QA Skill

## 목표

변경 범위에 맞는 가장 신뢰도 높은 검증을 실행하고, 결과와 남은 위험을 명확히 남긴다.

## 함께 적용하는 스킬

- API 성공/실패 계약 검증은 `../backend-api/SKILL.md`를 함께 적용한다.
- 보안 변경, secret, token, fixture 민감 정보는 `../security/SKILL.md`를 함께 적용한다.
- UI 동작과 접근성 검증은 `../frontend-ui/SKILL.md`를 함께 적용한다.
- migration, seed, query 검증은 `../database-migration/SKILL.md`를 함께 적용한다.
- timeout, retry, idempotency 검증은 `../resilience/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- 프로젝트 표준 명령을 `README`, package/script 파일, CI 설정에서 확인한다.
- 변경 범위와 가장 가까운 테스트부터 찾는다.
- 버그 수정이면 가능하면 실패를 먼저 재현한다.
- 테스트 데이터와 fixture에 실제 secret, token, password, 개인정보가 들어가지 않았는지 확인한다.

## 검증 우선순위

- 작은 변경은 관련 unit test, lint, typecheck처럼 빠른 검증을 우선한다.
- 여러 모듈 계약을 건드리면 integration test를 추가로 본다.
- 사용자 흐름이나 라우팅을 건드리면 e2e 또는 수동 브라우저 확인을 고려한다.
- UI 테스트는 구현 내부보다 사용자가 보는 DOM과 행동을 기준으로 작성한다.
- e2e 테스트는 적게 유지하고 핵심 흐름에 집중한다.
- 널리 통용되는 테스트 피라미드 기준에 따라 작은 단위 테스트를 우선하고, integration/e2e는 핵심 계약과 사용자 흐름에 집중한다.

## 테스트 데이터 기준

- 실제 운영 secret이나 사용자 개인정보를 fixture에 복사하지 않는다.
- token, password, API key는 명확한 dummy 값이나 생성 fixture를 사용한다.
- snapshot에 민감 정보, 운영 URL, 로컬 절대 경로가 들어가지 않게 한다.
- 시간, timezone, locale, currency가 걸린 테스트는 고정 clock이나 명시 locale을 사용한다.

## QA.md 기록 형식

```md
| 명령 | 결과 | 일시 | 메모 |
| --- | --- | --- | --- |
| npm test | 통과 | 2026-06-04 10:00 | 관련 테스트 통과 |
```

## 실패 처리

- 실패가 기존 문제인지 이번 변경 문제인지 근거를 확인한다.
- flaky 가능성이 있으면 재실행 여부와 관찰 내용을 기록한다.
- 실행하지 못한 검증은 이유를 `QA.md`와 최종 보고에 남긴다.

## 참고 기준

- Testing Library는 사용자가 소프트웨어를 쓰는 방식과 닮은 테스트를 권장한다.
- 테스트 피라미드는 널리 통용되는 경험칙으로, 빠르고 작은 테스트를 충분히 두고 느린 end-to-end 테스트는 핵심 흐름에 집중하는 균형을 제안한다.
