---
name: backend-api
description: API, 서버, route, controller, endpoint, service, middleware, auth, permission, 인증, 권한 작업에 사용한다.
---

# Backend API Skill

## 목표

기존 API 계약을 지키면서 입력 검증, 인증, 권한, 오류 응답을 빠뜨리지 않는다.

## 작업 전 확인

- 관련 route, controller, service, middleware, schema, test를 함께 확인한다.
- endpoint가 인증, 권한, rate limit, audit log 대상인지 확인한다.
- 요청/응답 DTO, validation schema, 에러 응답 형식의 기존 패턴을 찾는다.
- API 변경이 frontend, SDK, 문서, DB migration에 영향을 주는지 확인한다.

## 구현 기준

- 사용자 입력은 서버에서 검증한다.
- 객체 ID를 받는 endpoint는 객체 단위 권한을 확인한다.
- 응답 필드는 기존 계약과 최소 변경을 우선한다.
- 오류 응답은 기존 형식을 따른다. 기존 형식이 없으면 `status`, `title`, `detail`, 안정적인 error code 같은 Problem Details 계열 구조를 참고한다.
- 내부 구현 detail, stack trace, secret, token은 응답에 노출하지 않는다.

## 금지

- 요청받지 않은 응답 필드나 endpoint를 추가하지 않는다.
- 권한 체크를 controller 바깥 어딘가에 있다고 추측하고 생략하지 않는다.
- 공통 middleware를 넓게 바꾸지 않는다.

## 완료 전

- 성공, validation 실패, 인증 실패, 권한 실패 케이스를 검증한다.
- API 계약 변경과 남은 위험을 `QA.md`에 기록한다.

## 참고 기준

- OWASP API Security Top 10 2023은 객체 단위 권한, 인증, 객체 속성 단위 권한을 주요 API 위험으로 본다.
- RFC 9457은 HTTP API 오류를 기계가 읽기 쉬운 problem detail 형식으로 표현하는 기준을 제공한다.
