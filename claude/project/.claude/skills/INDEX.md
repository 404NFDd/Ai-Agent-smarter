# Skill 목차(INDEX)

이 파일은 전체 skill 의 목차다. 작업 영역을 고를 때 이 표만 보고 필요한 skill 한두 개를 정한 뒤, 그 skill 의 `SKILL.md` 본문만 읽는다. 전체 skill 을 통째로 읽지 않는다.

Claude Code 는 각 `SKILL.md` 의 frontmatter `description` 을 보고 관련 skill 을 자동으로 불러온다. 이 표는 자동 매칭이 빗나갔을 때 사용자가 직접 지목하거나, Claude 가 인접 skill 을 함께 적용할지 판단할 때 쓰는 수동 라우팅 표다.

## 사용 조건 요약

| skill | 한줄 요약 | 사용 조건(키워드/의도) |
| --- | --- | --- |
| codebase-onboarding | 코드베이스 처음 파악 | 처음, 구조, 온보딩, README, overview, explore |
| implementation-planning | 기능 구현/큰 작업 계획 | 기능 추가, 구현, 큰 작업, 구조 변경, 계획, PLAN.md |
| bugfix-debugging | 버그/오류 원인 분석 및 수정 | bug, error, fail, fix, debug, 재현, 고쳐 |
| testing-qa | 테스트/검증/lint/build/coverage | test, lint, typecheck, build, verify, QA, fixture |
| backend-api | API/서버/route/endpoint/service | api, server, route, controller, endpoint, rate limit |
| frontend-ui | UI/컴포넌트/접근성/대비 | ui, 화면, 컴포넌트, 버튼, modal, form, css, 접근성 |
| html-css-rules | HTML/CSS 작성 규칙 | html, css, 마크업, 스타일시트, 선택자, 레이아웃, 반응형 |
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
| ai-agent-collaboration | 에이전트 협업/인계/중간 보고 | subagent, collaboration, handoff, 협업, 작업 인계, memory 운영 |

## 작업 위치로 고르기

자동 매칭이 애매할 때 수정 대상 경로로 판단한다.

| 경로 패턴 | skill |
| --- | --- |
| `**/api/**`, `**/routes/**`, `**/controllers/**`, `**/services/**`, `**/middleware/**` | backend-api |
| `**/components/**`, `**/pages/**`, `**/ui/**` | frontend-ui |
| `**/*.html`, `**/*.css` | html-css-rules |
| `**/migrations/**`, `**/schema/**`, `**/*.sql` | database-migration |
| `**/auth/**`, `**/security/**` | security |
| `**/*.test.*`, `**/*.spec.*`, `**/__tests__/**`, `**/tests/**` | testing-qa |
| `**/.github/workflows/**`, `**/Dockerfile*` | release-deploy |
| `**/*.md` | documentation |

## 함께 적용 관계(자주 같이 쓰이는 조합)

- backend-api ↔ security ↔ resilience ↔ database-migration ↔ testing-qa
- html-css-rules ↔ frontend-ui ↔ security(XSS) ↔ testing-qa(Playwright) ↔ i18n-time-currency
- implementation-planning ↔ codebase-onboarding ↔ ai-agent-collaboration(계획 인계)
- bugfix-debugging ↔ testing-qa(재현) ↔ observability(원인) ↔ review

## 상세 챕터 분리 기준

`SKILL.md` 한 파일이 300줄을 넘으면 `chapters/*.md` 로 쪼갠다. `SKILL.md` 에는 목차와 판단 기준만 두고, 긴 절차와 예시는 챕터로 내린다. Claude 는 필요한 챕터만 읽으므로 자원 소비가 줄어든다.
