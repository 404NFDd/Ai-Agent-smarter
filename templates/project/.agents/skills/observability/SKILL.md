---
name: observability
description: log, metric, trace, tracing, Sentry, monitoring, observability, 로그, 메트릭, 트레이싱, 관측성, 운영 조사 작업에 사용한다.
---

# Observability Skill

## 목표

운영 중 문제를 추적할 수 있게 로그, 메트릭, 트레이스를 적절한 위치에 남긴다.

## 함께 적용하는 스킬

- API 오류, rate limit, request id는 `../backend-api/SKILL.md`를 함께 적용한다.
- 민감 정보 로그 노출은 `../security/SKILL.md`를 함께 적용한다.
- timeout, retry, circuit breaker 관측은 `../resilience/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- 기존 logging, metrics, tracing, error reporting 도구와 필드 규칙을 확인한다.
- 어떤 질문에 답하기 위한 관측인지 정한다.
- 개인정보, secret, token이 로그에 들어갈 위험을 확인한다.

## 구현 기준

- 로그는 원인 분석에 필요한 event, id, 상태, 실패 이유를 포함한다.
- request id, user id 같은 식별자는 정책에 맞게 마스킹하거나 제한한다.
- metric은 카디널리티가 과도하게 커지지 않게 설계한다.
- tracing span은 외부 호출, DB query, 긴 작업처럼 경계가 분명한 곳에 둔다.
- 알림은 사용자가 조치할 수 있는 조건에 연결한다.

## 금지

- secret, token, password, 원문 개인정보를 로그에 남기지 않는다.
- 너무 많은 debug 로그로 운영 비용과 노이즈를 키우지 않는다.
- metric label에 무제한 값이 들어가게 하지 않는다.

## 완료 전

- 실패 상황에서 필요한 정보가 남는지 확인한다.
- 민감 정보 노출 위험을 `QA.md`에 기록한다.
