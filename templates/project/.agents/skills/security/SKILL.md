---
name: security
description: security, token, secret, password, injection, XSS, CSRF, permission, auth, authz, fixture 민감 정보, 보안, 인증, 인가, 권한, 시크릿 작업에 사용한다.
---

# Security Skill

## 목표

인증, 권한, 입력, secret, 로그, 응답에서 보안 회귀를 만들지 않는다.

## 함께 적용하는 스킬

- API route, controller, 오류 응답, rate limit 변경은 `../backend-api/SKILL.md`를 함께 적용한다.
- UI 입력/출력, XSS, 민감 정보 표시 변경은 `../frontend-ui/SKILL.md`를 함께 적용한다.
- query, migration, seed, transaction 변경은 `../database-migration/SKILL.md`를 함께 적용한다.
- 테스트 fixture와 검증 데이터는 `../testing-qa/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- 변경이 인증, 인가, 세션, 토큰, secret, 개인정보, 결제, 관리자 기능에 닿는지 확인한다.
- 사용자 입력이 DB query, HTML 출력, 파일 경로, 외부 요청, 로그에 쓰이는지 확인한다.
- 클라이언트에 노출되는 데이터와 서버 내부 데이터의 경계를 확인한다.

## 구현 기준

- 입력 검증, 객체 단위 권한, secret/token/password 비노출 기준은 이 skill을 단일 기준으로 삼는다.
- 권한은 deny by default로 생각하고, 매 요청마다 필요한 권한을 검증한다.
- 사용자 제공 ID로 객체를 조회하면 객체 단위 권한을 확인한다.
- 입력 검증은 allowlist와 schema 검증을 우선한다.
- client-side validation은 UX용으로만 보고 서버 검증을 생략하지 않는다.
- secret, token, password는 코드, 문서, 로그, 테스트 fixture에 평문으로 남기지 않는다.
- 테스트 fixture에는 실제 secret 대신 dummy 값이나 생성 데이터를 사용한다.
- 보안 실패 로그는 원인 추적에 필요한 수준으로 남기되 민감 정보는 마스킹한다.

## 금지

- 권한 체크를 편의상 우회하지 않는다.
- 내부 오류, stack trace, secret 값을 사용자 응답에 노출하지 않는다.
- 인증/권한 변경을 테스트 없이 완료하지 않는다.
- 운영 데이터나 실제 credential을 테스트 데이터로 복사하지 않는다.

## 완료 전

- security-reviewer subagent가 필요할 정도의 변경인지 판단한다.
- 남은 보안 위험과 검증 내용을 `QA.md`에 기록한다.

## 참고 기준

- OWASP Authorization Cheat Sheet는 deny by default와 every request permission validation을 권장한다.
- OWASP Input Validation Cheat Sheet는 외부 입력을 가능한 이른 시점에 검증하라고 권장한다.
- OWASP Secrets Management Cheat Sheet는 secret을 코드와 로그에 평문으로 남기지 않는 것을 기본으로 둔다.
