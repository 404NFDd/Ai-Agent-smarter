---
name: database-migration
description: DB, database, migration, schema, table, index, query, transaction, seed, rollback, 마이그레이션, 스키마 작업에 사용한다.
---

# Database Migration Skill

## 목표

데이터를 보존하고 배포 중 호환성을 유지하면서 schema와 query를 변경한다.

## 함께 적용하는 스킬

- API 계약이나 query 호출부가 바뀌면 `../backend-api/SKILL.md`를 함께 적용한다.
- seed, fixture, 권한별 데이터 접근이 걸리면 `../security/SKILL.md`를 함께 적용한다.
- migration과 query 변경은 `../testing-qa/SKILL.md`로 검증한다.
- timeout, retry, idempotency, transaction 재시도가 걸리면 `../resilience/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- schema, migration, model, query 호출부, seed, 테스트 데이터를 함께 확인한다.
- 운영 데이터 크기, null 허용 여부, 기본값, constraint, index 필요성을 확인한다.
- 배포 순서가 필요한 변경인지 판단한다.
- rollback 가능성과 데이터 복구 전략을 확인한다.

## 구현 기준

- 가능한 경우 expand-contract 흐름을 사용한다.
- 기존 코드와 새 코드가 동시에 동작해야 하는 배포 구간을 고려한다.
- 큰 테이블의 backfill은 batch, timeout, lock 영향을 고려한다.
- index 추가는 query 패턴과 explain 또는 유사 근거가 있을 때 한다.
- PostgreSQL 운영 테이블의 index 추가는 `CREATE INDEX CONCURRENTLY` 가능 여부와 migration tool의 transaction 설정을 확인한다.

## 금지

- 사용자 승인 없이 destructive migration을 작성하지 않는다.
- 컬럼 의미를 문서 없이 바꾸지 않는다.
- 데이터 변환을 검증 없이 마친 것으로 처리하지 않는다.

## 완료 전

- migration 적용/rollback 또는 관련 테스트를 실행한다.
- lock, 데이터 손실, rollback 필요 여부를 `QA.md`에 기록한다.

## 참고 기준

- PostgreSQL 문서는 일반 `CREATE INDEX`가 write를 막을 수 있고, `CONCURRENTLY`는 write를 막지 않는 대신 더 오래 걸리고 transaction block 안에서 실행할 수 없다고 설명한다.
