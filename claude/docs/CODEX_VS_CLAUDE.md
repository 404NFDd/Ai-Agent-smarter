# codex 판 ↔ claude 판 대응표

같은 설계(`설계근거.md` 4대 시스템)를 두 도구로 옮겼을 때 무엇이 어디로 갔는지 정리한다.

## 파일 대응

| codex | claude | 비고 |
| --- | --- | --- |
| `global/AGENTS.md` | `global/CLAUDE.md` | 이름만 다름 |
| `global/config.features.toml` | (없음) | Claude Code 는 hooks/subagent 를 켜는 feature flag 가 없다 |
| `global/hooks.json` + `global/hooks/*.ps1` × 4 | `global/settings.json` 의 SessionStart 1개 | 전역 advisory hook 4개는 프로젝트 hook 과 중복돼 1개로 줄였다 |
| `project/AGENTS.md` | `project/CLAUDE.md` | `@import` 로 작업 기억을 자동 로드하는 점이 추가됨 |
| `project/.codex/hooks.json` | `project/.claude/settings.json` | Claude Code 는 hooks 를 settings.json 안에 둔다 |
| `project/.codex/verify.toml` | `project/.claude/verify.toml` | 동일 |
| `project/.codex/hooks/user_prompt_submit.*` | (삭제) | skill 자동 매칭이 네이티브로 대체 |
| `project/.codex/hooks/pre_tool_use.*` | (삭제) | 계획 게이트는 Plan Mode, 경로 라우팅은 skill 매칭이 대체 |
| `project/.codex/hooks/session_start.*` | `project/.claude/hooks/session_start.sh` | 축소. 기억 로드는 `@import` 가 하고, hook 은 상태 초기화만 |
| `project/.codex/hooks/post_tool_use.*` | `project/.claude/hooks/post_tool_use.sh` | 거의 동일 |
| `project/.codex/hooks/stop_guard.*` | `project/.claude/hooks/stop_guard.sh` | 거의 동일 |
| `project/.codex/agents/*.toml` | `project/.claude/agents/*.md` | Claude Code 서브에이전트는 frontmatter + markdown |
| `project/.agents/skills/*/SKILL.md` | `project/.claude/skills/*/SKILL.md` | 내용 동일, description 만 자동 트리거용으로 보강 |
| `project/.agents/skills/MAP.toml` | (삭제) | hook 라우팅표. 네이티브 매칭이 대체 |
| (없음) | `project/.claude/commands/*.md` | slash command 로 계획 저장·체크포인트·마무리를 고정 |
| `project/.codex-memory/*` | `project/.claude-memory/*` | 동일 |

## 시스템별 구현 방식 차이

### 1. 자동 매뉴얼 시스템

- codex: hook 이 프롬프트 키워드와 `apply_patch` 대상 경로를 정규식으로 매칭해 `SKILL.md` 본문을 컨텍스트에 강제 주입했다.
- claude: Claude Code 가 `SKILL.md` frontmatter 의 `description` 을 보고 스스로 skill 을 불러온다. hook 주입이 없다.

바뀐 점: 강제성이 약해졌다. 대신 매칭 품질은 정규식보다 낫고, 예산 계산이나 챕터 lazy 로드를 직접 구현할 필요가 없다.

강제성이 꼭 필요하면 `CLAUDE.md` 의 `## 작업 전` 에 "작업 전에 `.claude/skills/INDEX.md` 를 먼저 확인한다" 를 유지한다. 이미 들어 있다.

### 2. 작업 기억 시스템

- codex: SessionStart hook 이 memory 파일 목록과 미완료 체크리스트를 컨텍스트에 주입했다.
- claude: `CLAUDE.md` 하단의 `@.claude-memory/PLAN.md` 같은 import 가 세션 시작 시 파일 본문을 그대로 불러온다. hook 은 `MODIFIED_FILES.md` 아카이브와 게이트 카운터 초기화만 한다.

계획 게이트(`PLAN.md` 저장 전 편집 차단)는 옮기지 않았다. Claude Code 의 Plan Mode 가 같은 일을 하고, 사용자가 계획을 눈으로 승인한 뒤에만 편집이 시작된다. 승인 직후 `/plan-start` 로 세 파일에 저장하는 흐름이 codex 의 `.plan_required` 상태 파일을 대신한다.

### 3. 자동 품질 검사 시스템

거의 그대로 옮겼다. 이 부분만 hook 이 남은 이유는 Claude Code 에 "완료 시점에 자동 검수하고 실패면 되돌려보내기" 를 하는 네이티브 기능이 없기 때문이다.

- 수정 기록(CCTV): PostToolUse → `MODIFIED_FILES.md`
- 셀프체크 리마인더: PostToolUse 의 `additionalContext`
- 완료 후 검사: Stop → `verify.toml` 실행 → `QA.md` 기록 → 실패 시 `decision: block`
- 루프 방지: 같은 사유 2회 차단 후 사용자 확인, 세션 누적 8회 초과 시 advisory 전환

### 4. 전문 에이전트 시스템

- codex: `.codex/agents/*.toml`, hook 이 "reviewer 를 호출하세요" 라고 안내.
- claude: `.claude/agents/*.md`. `description` 에 호출 조건을 적으면 Claude 가 자동 위임한다. hook 안내는 보조로 남겼다.

보고서 형식(`발견 / 근거 / 위험도 / 수정 제안 / 판단 이유`)과 `QA.md` 의 `## <에이전트명> 보고` 마커 규약은 동일하다. `stop_guard.sh` 가 이 마커를 읽는다.

## 무엇을 잃었는가

정직하게 적는다.

- skill 강제 주입이 사라져, Claude 가 관련 skill 을 안 부르는 경우를 hook 이 막지 못한다.
- 구현 전 계획 강제(편집 차단)가 사라져, Plan Mode 를 안 쓰면 계획 없이 편집이 가능하다.
- 파일 내용 정규식 기반 skill 라우팅(`MAP.toml` 의 `[[content]]`)이 사라졌다.

이 셋을 hook 으로 되살리려면 `PreToolUse` matcher `Edit|Write|MultiEdit` 훅을 추가하고 `permissionDecision: "deny"` 로 차단하면 된다. 다만 네이티브 기능과 중복되고 오탐 시 작업이 막히므로 기본 템플릿에는 넣지 않았다.
