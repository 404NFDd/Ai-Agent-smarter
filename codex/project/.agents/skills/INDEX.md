# Skill 목차(INDEX)

이 파일은 skill 이름과 한줄 요약만 담은 목차다. 실제 라우팅은 hook 이 한다.
`user_prompt_submit` 은 프롬프트 키워드로, `pre_tool_use` 는 `MAP.toml` 의 경로/파일내용 조건으로
skill 을 고르고 그 `SKILL.md` 본문을 주입한다. 이 파일은 자동 매칭이 빗나갔을 때 사람이 직접
skill 을 지목하기 위한 용도로만 쓴다.

- 이 목차를 근거로 판단하지 않는다. 대상 skill 을 고른 뒤 그 `SKILL.md` 본문을 읽고 그쪽 기준을 따른다.
- 여러 skill 을 통째로 읽지 않는다. 한두 개만 고른다.
- 상세 내용은 `<skill>/chapters/*.md` 에 있고 필요한 챕터만 읽는다.

| skill | 한줄 요약 |
| --- | --- |
| codebase-onboarding | 코드베이스 처음 파악 |
| implementation-planning | 기능 구현과 큰 작업 계획 |
| bugfix-debugging | 버그 원인 분석과 수정 |
| testing-qa | 테스트, 검증, lint, build |
| backend-api | API, 서버, route, service |
| frontend-ui | UI, 컴포넌트, 접근성 |
| html-css-rules | HTML/CSS 작성 규칙 |
| database-migration | DB, 마이그레이션, 스키마, 쿼리 |
| security | 인증, 권한, 입력 검증, secret |
| resilience | timeout, retry, 멱등성, 장애 대응 |
| i18n-time-currency | 다국어, 시간대, 통화, 포맷 |
| code-style | 스타일, 네이밍, 주석, 추상화 |
| git-workflow | git 브랜치, 커밋, PR, 되돌리기 |
| dependency-management | 패키지와 의존성 관리 |
| release-deploy | 배포, 릴리즈, 버전, 롤백 |
| observability | 로그, 메트릭, 트레이싱 |
| performance | 성능, 캐시, 병목, 번들 |
| refactoring | 리팩터링, 정리, 중복 제거 |
| documentation | 문서, README, 가이드 갱신 |
| review | 코드 리뷰와 위험 분석 |
| ai-agent-collaboration | 에이전트 협업, 인계, 작업 기억 운영 |
