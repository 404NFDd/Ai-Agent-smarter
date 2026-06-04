---
name: database
description: DB, database, migration, schema, table, index, query, transaction 작업 전에 사용한다.
---

# Database Skill

## 작업 전 확인

- schema, migration, seed, query 호출부를 함께 확인한다.
- 데이터 호환성과 rollback 가능성을 확인한다.
- index나 transaction이 필요한 변경인지 확인한다.

## 금지

- 데이터 삭제나 destructive migration을 추측으로 작성하지 않는다.
- 기존 컬럼 의미를 문서 없이 바꾸지 않는다.
- 성능 영향이 큰 query 변경을 검증 없이 마치지 않는다.

## 완료 전

- migration 검증 또는 관련 테스트를 실행한다.
- 데이터 위험과 rollback 필요 여부를 `QA.md`에 기록한다.
