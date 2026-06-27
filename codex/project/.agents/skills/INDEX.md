# Skill 목차(INDEX)

이 파일은 전체 skill 의 목차다. hook(user_prompt_submit / pre_tool_use)가 요청이나 작업 위치/파일 내용 으로 매칭한 skill 을 판단할 때 기준으로 삼는다.
각 skill 의 상세 본문은 `<skill>/SKILL.md`, 더 깊은 내용은 `<skill>/chapters/*.md` 에 있다. hook 은 매칭된 skill 의 SKILL.md 본문을 context 에 주입하고, 챕터는 필요 시 lazy 로드한다.

## 사용 조건 요약

| skill | 한줄 요약 | 사용 조건(키워드/의도) |
| --- | --- | --- |
| codebase-onboarding | 코드베이스 처음 파악 | 처음, 구조, 온보딩, README, overview, explore |
| implementation-planning | 기능 구현/큰 작업 계획 | 기능 추가, 구현, 큰 작업, 구조 변경, 계획, PLAN.md |
| bugfix-debugging | 버그/오류 원인 분석 및 수정 | bug, error, fail, fix, debug, 재현, 고쳐 |
| testing-qa | 테스트/검증/lint/build/coverage | test, lint, typecheck, build, verify, QA, fixture |
| backend-api | API/서버/route/endpoint/service | api, server, route, controller, endpoint, rate limit |
| frontend-ui | UI/컴포넌트/접근성/대비 | ui, 화면, 컴포넌트, 버튼, modal, form, css, 접근성 |
| database-migration | DB/마이그레이션/스키마/쿼리 | db, database, migration, schema, table, query, transaction |
| security | 인증/권한/입력검증/secret/주입 | security, token, secret, password, injection, XSS, CSRF, auth |
| resilience | timeout/retry/idempotency/장애 | timeout, retry, backoff, idempotency, rate limit, circuit breaker |
| i18n-time-currency | 다국어/시간대/통화/포맷 | i18n, locale, timezone, date, currency, number format |
| code-style | 스타일/네이밍/주석/추상화 | style, naming, comment, abstraction, convention |
| git-workflow | git/브랜치/커밋/PR/되돌리기 | git, branch, commit, PR, push, rollback, 삭제 전 확인 |
| dependency-management | 패키지/의존성/설치/업그레이드 | dependency, package, install, lockfile, npm, pip, cargo |
| release-deploy | 배포/릴리즈/버전/태그/롤백 | release, deploy, version, tag, publish, rollback |
| observability | 로그/메트릭/트레이싱/관측 | log, metric, trace, Sentry, monitoring, observability |
| performance | 성능/캐시/병목/번들 | performance, slow, cache, bottleneck, bundle, 최적화 |
| refactoring | 리팩터링/정리/중복 제거 | refactor, cleanup, rework, 리팩터링, 정리, 구조 개선 |
| documentation | 문서/README/가이드/갱신 | doc, docs, README, changelog, 가이드, 사용법 |
| review | 코드 리뷰/검토/위험 분석 | review, 검토, 리뷰, 변경사항 점검, 누락 테스트 |
| ai-agent-collaboration | 에이전트 협업/인계/중간 보고 | codex, agent, collaboration, handoff, 협업, 작업 인계, memory 운영 |

## 함께 적용 관계(자주 같이 쓰이는 조합)

- backend-api ↔ security ↔ resilience ↔ database-migration ↔ testing-qa
- frontend-ui ↔ security(XSS) ↔ testing-qa(Playwright) ↔ i18n-time-currency
- implementation-planning ↔ codebase-onboarding ↔ ai-agent-collaboration(계획 인계)
- bugfix-debugging ↔ testing-qa(재현) ↔ observability(원인) ↔ review