---
name: resilience
description: timeout, retry, backoff, idempotency, rate limit, quota, circuit breaker, 장애 대응, 재시도, 멱등성, 타임아웃 작업에 사용한다.
---

# Resilience Skill

## 목표

외부 호출, 긴 작업, 중복 요청, 부분 실패에서 예측 가능한 실패 동작을 만들고 무제한 자원 사용을 막는다.

## 함께 적용하는 스킬

- API endpoint, 외부 호출, rate limit은 `../backend-api/SKILL.md`를 함께 적용한다.
- 인증, 권한, resource consumption 제한은 `../security/SKILL.md`를 함께 적용한다.
- transaction, lock, 재시도 가능한 DB 작업은 `../database-migration/SKILL.md`를 함께 적용한다.
- timeout, retry, idempotency는 `../testing-qa/SKILL.md`로 실패/중복 케이스를 검증한다.

## 작업 전 확인

- 실패 모드가 timeout, 네트워크 오류, 중복 요청, partial failure, rate limit 중 무엇인지 확인한다.
- 작업이 읽기인지 쓰기인지, 멱등성이 필요한지 확인한다.
- 외부 API, queue, DB transaction, 파일 업로드처럼 오래 걸리거나 실패 가능한 경계를 찾는다.

## 구현 기준

- 모든 외부 호출과 긴 작업에는 명시적인 timeout을 둔다.
- retry는 재시도 가능한 오류에만 적용하고, backoff와 최대 횟수를 둔다.
- 쓰기 작업 retry는 idempotency key, unique constraint, request id 같은 중복 방지 장치를 먼저 확인한다.
- rate limit과 quota는 사용자, 조직, IP, token 등 실제 남용 단위에 맞춰 설계한다.
- 실패 후 사용자가 같은 작업을 다시 시도할 수 있는지, 이미 처리됐는지 알 수 있게 한다.

## 금지

- 무제한 retry나 timeout 없는 외부 호출을 추가하지 않는다.
- 멱등성 없는 쓰기 작업을 자동 재시도하지 않는다.
- 관리자 또는 내부 endpoint라는 이유만으로 리소스 제한을 생략하지 않는다.

## 완료 전

- timeout, retry 한도, 중복 요청, rate limit 또는 quota 초과 케이스를 검증한다.
- 검증하지 못한 장애 모드는 `QA.md`에 남긴다.
