---
name: backend-api
description: API, 서버, route, controller, endpoint, service, middleware, auth, permission, rate limit, resource consumption, 오류 응답 작업에 사용한다.
---

# Backend API Skill

## 목표

기존 API 계약을 지키면서 입력 검증, 인증, 권한, 오류 응답을 빠뜨리지 않는다.

## 함께 적용하는 스킬

- 인증, 권한, 입력 검증, 객체 단위 권한, secret/token 비노출의 상세 기준은 `../security/SKILL.md`를 단일 기준으로 함께 적용한다.
- timeout, retry, idempotency, rate limit처럼 장애와 자원 보호가 걸린 API는 `../resilience/SKILL.md`를 함께 적용한다.
- schema, query, migration이 바뀌면 `../database-migration/SKILL.md`를 함께 적용한다.
- API 계약이 바뀌면 `../testing-qa/SKILL.md`로 성공/실패 케이스를 검증한다.

## 작업 전 확인

- 관련 route, controller, service, middleware, schema, test를 함께 확인한다.
- endpoint가 인증, 권한, rate limit, audit log 대상인지 확인한다.
- 요청/응답 DTO, validation schema, 에러 응답 형식의 기존 패턴을 찾는다.
- API 변경이 frontend, SDK, 문서, DB migration에 영향을 주는지 확인한다.
- 요청 크기, pagination, 파일 업로드, 검색, bulk 작업, 외부 API 호출처럼 리소스 소비가 큰 경로인지 확인한다.

## 구현 기준

- 사용자 입력 검증과 객체 단위 권한은 `security` 기준을 따른다.
- 응답 필드는 기존 계약과 최소 변경을 우선한다.
- 오류 응답은 기존 형식을 따른다. 기존 형식이 없으면 RFC 9457 Problem Details를 참고한다.
- RFC 9457 표준 멤버는 `type`, `title`, `status`, `detail`, `instance` 다섯 개로 본다.
- 오류 응답에는 최소한 `type`, `title`, `status`를 채운다.
- `detail`과 `instance`는 stack trace, secret, token, 내부 경로, 개인정보 노출 위험을 검토한 뒤 선택적으로 둔다.
- 서비스 고유 오류 코드는 표준 멤버가 아니므로 필요하면 `code`, `error_code` 같은 extension member로 분리한다.
- 내부 구현 detail, stack trace, secret, token은 응답에 노출하지 않는다.

## 리소스 제한

- 목록 API에는 기본 limit, 최대 limit, 정렬/필터 제한을 둔다.
- 파일 업로드, bulk 작업, 검색, report 생성에는 크기와 시간 제한을 둔다.
- 비싼 작업에는 rate limit, quota, async 처리, cache 가능성을 검토한다.
- GraphQL이나 batch API처럼 한 요청에 여러 작업을 담을 수 있으면 operation 단위 제한도 확인한다.

## 금지

- 요청받지 않은 응답 필드나 endpoint를 추가하지 않는다.
- 권한 체크를 controller 바깥 어딘가에 있다고 추측하고 생략하지 않는다.
- 공통 middleware를 넓게 바꾸지 않는다.
- 내부 오류, stack trace, secret, token이 오류 응답에 노출되게 두지 않는다.

## 완료 전

- 성공, validation 실패, 인증 실패, 권한 실패, rate limit 또는 리소스 제한 케이스를 검증한다.
- API 계약 변경과 남은 위험을 `QA.md`에 기록한다.

## 참고 기준

- OWASP API Security Top 10 2023은 객체 단위 권한, 인증, 객체 속성 단위 권한을 주요 API 위험으로 본다.
- RFC 9457은 HTTP API 오류를 기계가 읽기 쉬운 problem detail 형식으로 표현하는 기준을 제공한다.
- OWASP API4:2023은 payload 크기, 반환 레코드 수, 호출 빈도, 리소스 사용량 제한을 API 자원 보호 기준으로 본다.
