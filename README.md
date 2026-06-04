# Codex 운영 시스템 템플릿

이 프로젝트는 다른 Codex 프로젝트에 복사해 사용할 운영 시스템 템플릿이다.

붙여넣은 문서의 핵심을 다음 두 범위로 나누었다.

- 전역 작업: `C:\Users\<사용자>\.codex`에 적용할 공통 AGENTS, config, hooks 템플릿
- 프로젝트 작업: 각 프로젝트 루트에 적용할 memory, skills, hooks, subagents 템플릿

이 저장소는 실제 전역 설정을 직접 수정하지 않는다. 전역 파일은 루트의 `global` 내용을 확인한 뒤 필요한 위치에 복사하거나 병합한다.

## 폴더 구조

```text
docs/
  GLOBAL_WORK_TEMPLATE.md
  PROJECT_WORK_TEMPLATE.md
  APPLY_GUIDE.md

global/
  AGENTS.md
  config.features.toml
  hooks.json
  hooks/

templates/
  project/
    AGENTS.md
    .codex-memory/
    .agents/skills/
    .codex/hooks/
    .codex/agents/

.codex-memory/
  PLAN.md
  CONTEXT.md
  CHECKLIST.md
  QA.md
  DECISIONS.md
  MODIFIED_FILES.md
```

## 사용 순서

1. `docs/GLOBAL_WORK_TEMPLATE.md`를 보고 전역 설정 적용 여부를 결정한다.
2. `global` 파일을 기존 전역 설정과 비교해 병합한다.
3. `docs/PROJECT_WORK_TEMPLATE.md`를 보고 대상 프로젝트에 적용할 범위를 결정한다.
4. `templates/project` 내용을 대상 프로젝트 루트에 복사한다.
5. 대상 프로젝트에서 작은 작업으로 hooks, memory, QA 흐름을 검증한다.

## 운영 원칙

- 전역 템플릿에는 모든 프로젝트에 공통으로 맞는 규칙만 둔다.
- 프로젝트 템플릿에는 해당 프로젝트의 작업 기억, 검증, 역할 분리 규칙을 둔다.
- 긴 매뉴얼은 `AGENTS.md`에 몰아넣지 않고 skill로 분리한다.
- hooks가 불안정하면 `AGENTS.md`, `.codex-memory`, skills, 수동 시작/종료 프롬프트로 낮춰 운영한다.
