# Claude Code 운영 시스템 템플릿

이 폴더는 다른 Claude Code 프로젝트에 복사해 사용할 운영 시스템 템플릿이다. 같은 저장소의 `codex/` 와 같은 설계(`설계근거.md` 의 4대 시스템)를 Claude Code 규격으로 옮긴 것이다.

두 범위로 나뉜다.

- 전역 작업: `~/.claude` 에 병합할 공통 `CLAUDE.md`, `settings.json`
- 프로젝트 작업: 각 프로젝트 루트에 복사할 `CLAUDE.md`, `.claude/`, `.claude-memory/`

이 폴더는 실제 전역 설정을 직접 수정하지 않는다. `global/` 내용을 확인한 뒤 필요한 위치에 복사하거나 병합한다.

## 폴더 구조

```text
docs/
  APPLY_GUIDE.md
  GLOBAL_WORK_TEMPLATE.md
  PROJECT_WORK_TEMPLATE.md
  CODEX_VS_CLAUDE.md

global/
  CLAUDE.md
  settings.json

project/
  CLAUDE.md
  .claude/
    settings.json
    verify.toml
    hooks/        session_start.sh, post_tool_use.sh, stop_guard.sh
    agents/       planner, reviewer, tester, security-reviewer
    commands/     plan-start, checkpoint, wrap-up
    skills/       INDEX.md + 21개 skill
  .claude-memory/
    PLAN.md, CONTEXT.md, CHECKLIST.md, QA.md,
    DECISIONS.md, METRICS.md, MODIFIED_FILES.md
```

## 4대 시스템이 어디에 있는가

| 시스템 | 구현 위치 | 방식 |
| --- | --- | --- |
| 1. 자동 매뉴얼 | `.claude/skills/*/SKILL.md` | Claude Code 네이티브 skill 자동 매칭 (hook 주입 없음) |
| 2. 작업 기억 | `CLAUDE.md` 의 `@import` + `.claude-memory/` + `/plan-start` `/checkpoint` | 네이티브 import 와 slash command |
| 3. 자동 품질 검사 | `.claude/hooks/post_tool_use.sh`, `stop_guard.sh` | PostToolUse / Stop hook (네이티브 대체 수단 없음) |
| 4. 전문 에이전트 | `.claude/agents/*.md` | Claude Code 네이티브 서브에이전트 자동 위임 |

codex 판과 달리 skill 라우팅용 hook(`user_prompt_submit`, `pre_tool_use`)과 `MAP.toml` 이 없다. Claude Code 가 그 역할을 기본 제공하기 때문이다. 자세한 대응은 `docs/CODEX_VS_CLAUDE.md` 를 본다.

## 사용 순서

1. `docs/GLOBAL_WORK_TEMPLATE.md` 를 보고 전역 설정 적용 여부를 결정한다.
2. `global/` 파일을 기존 전역 설정과 비교해 병합한다.
3. `docs/PROJECT_WORK_TEMPLATE.md` 를 보고 대상 프로젝트에 적용할 범위를 결정한다.
4. `project/` 내용을 대상 프로젝트 루트에 복사한다.
5. `.claude/verify.toml` 을 그 프로젝트 실제 명령으로 채운다.
6. 작은 작업으로 hook, memory, QA 흐름을 리허설한다.

## 운영 원칙

- 전역 템플릿에는 모든 프로젝트에 공통으로 맞는 규칙만 둔다. 강제 게이트는 두지 않는다.
- 프로젝트 템플릿에는 그 프로젝트의 작업 기억, 검증, 역할 분리 규칙을 둔다.
- 긴 매뉴얼은 `CLAUDE.md` 에 몰아넣지 않고 skill 로 분리한다.
- 네이티브 기능으로 되는 것은 hook 으로 만들지 않는다. hook 은 네이티브가 못 하는 완료 후 검수에만 쓴다.
- hook 이 불안정하면 `CLAUDE.md`, `.claude-memory`, skill, slash command 만으로 낮춰 운영한다.

## 설계 근거

4대 시스템의 원래 출처와 설계 의도는 저장소 루트의 `설계근거.md` 에 있다. 적용 전에 한 번 읽으면 각 hook 과 skill 이 왜 이 구조인지 이해할 수 있다.
