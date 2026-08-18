---
name: performance
description: 추측 대신 측정으로 병목을 찾고 필요한 만큼만 최적화하게 한다. 사용 조건: performance, perf, slow, cache, bottleneck, bundle, 성능, 느림, 캐시, 병목, 번들 크기, 최적화 작업에 사용한다.
---

# Performance Skill

## 목표

측정 없이 추측으로 최적화하지 않고, 사용자 체감 또는 시스템 병목에 직접 연결된 문제를 줄인다.

## 함께 적용하는 스킬

- API 처리량, pagination, upload, expensive query는 `../backend-api/SKILL.md`를 함께 적용한다.
- timeout, retry, queue, rate limit, quota는 `../resilience/SKILL.md`를 함께 적용한다.
- query plan, index, transaction 병목은 `../database-migration/SKILL.md`를 함께 적용한다.
- 전후 측정과 회귀 검증은 `../testing-qa/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- 느린 경로, 입력 크기, 데이터 양, 사용자 환경, 재현 조건을 확인한다.
- 기존 metric, log, profiler, benchmark, bundle analyzer가 있는지 확인한다.
- 성능 문제인지 안정성, 네트워크, DB lock, 렌더링 문제인지 분리한다.

## 구현 기준

- 먼저 측정 기준을 정한다.
- 작은 변경으로 병목을 줄인다.
- cache는 invalidation, TTL, 권한별 데이터 분리, 메모리 사용량을 함께 고려한다.
- DB query 최적화는 index, query plan, N+1, transaction 범위를 확인한다.
- frontend 성능은 bundle size, 불필요한 rerender, 이미지 크기, lazy loading을 확인한다.

## 금지

- 성능 근거 없이 복잡한 캐시나 병렬화를 추가하지 않는다.
- correctness를 희생하는 최적화를 하지 않는다.
- 운영 위험이 큰 설정 변경을 검증 없이 적용하지 않는다.

## 완료 전

- 전후 측정 또는 최소한 재현 조건의 개선 여부를 기록한다.
- 측정하지 못한 경우 `QA.md`에 이유와 남은 위험을 남긴다.
