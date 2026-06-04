---
name: security
description: 보안, token, secret, password, 권한, auth, injection, XSS, CSRF 작업 전에 사용한다.
---

# Security Skill

## 작업 전 확인

- 인증, 권한, 세션, 토큰, 비밀정보 흐름을 확인한다.
- 사용자 입력이 저장, 출력, 쿼리, 외부 요청에 쓰이는지 확인한다.
- 민감 정보가 로그나 클라이언트 응답에 노출되는지 확인한다.

## 금지

- secret, token, password를 코드나 문서에 평문으로 남기지 않는다.
- 권한 체크를 편의상 우회하지 않는다.
- 입력 검증 없이 쿼리나 HTML 출력에 연결하지 않는다.

## 완료 전

- 보안 관련 변경은 security-reviewer 검토 필요 여부를 판단한다.
- 남은 보안 위험은 `QA.md`에 기록한다.
