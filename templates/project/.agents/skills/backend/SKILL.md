---
name: backend
description: API, 서버, route, controller, endpoint, service, auth, 인증, 권한 작업 전에 사용한다.
---

# Backend Skill

## 작업 전 확인

- 관련 route, controller, service, middleware를 함께 확인한다.
- 인증과 권한이 필요한 endpoint인지 확인한다.
- 입력 검증과 오류 응답 형식을 기존 코드와 맞춘다.

## 금지

- 요청받지 않은 API 응답 필드를 추가하지 않는다.
- 기존 권한 흐름을 추측으로 바꾸지 않는다.
- 공통 middleware를 불필요하게 수정하지 않는다.

## 완료 전

- API 변경에 맞는 테스트 또는 수동 검증을 수행한다.
- 변경된 응답 형식과 실패 케이스를 `QA.md`에 기록한다.
