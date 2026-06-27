# 프로젝트 작업 템플릿

이 문서는 각 프로젝트 루트에 적용할 Codex 운영 시스템 템플릿이다.

대상 프로젝트에 `codex/project` 내용을 복사한 뒤, 프로젝트 특성에 맞게 검증 명령과 skill 내용을 줄여서 조정한다.

## 1. 프로젝트 AGENTS.md

목적:

- 프로젝트 작업 전 확인 파일을 고정한다.
- 작업 중 체크리스트 갱신과 완료 전 QA 기록을 강제한다.

템플릿:

```text
codex/project/AGENTS.md
```

체크리스트:

- [ ] 프로젝트 검증 명령을 실제 명령으로 바꿨다.
- [ ] 프로젝트별 금지 사항을 필요한 만큼만 추가했다.
- [ ] 긴 세부 규칙은 skill로 분리했다.

## 2. 작업 기억 파일

목적:

- 계획, 맥락, 체크리스트, QA, 결정사항, 수정 파일 기록을 남긴다.

템플릿:

```text
codex/project/.codex-memory/PLAN.md
codex/project/.codex-memory/CONTEXT.md
codex/project/.codex-memory/CHECKLIST.md
codex/project/.codex-memory/QA.md
codex/project/.codex-memory/DECISIONS.md
codex/project/.codex-memory/MODIFIED_FILES.md
```

체크리스트:

- [ ] 큰 작업 전 `PLAN.md`에 목표와 검증 기준을 적었다.
- [ ] 중요한 결정은 `CONTEXT.md` 또는 `DECISIONS.md`에 적었다.
- [ ] 진행 상태는 `CHECKLIST.md`에 갱신했다.
- [ ] 검증 결과와 남은 위험은 `QA.md`에 적었다.

## 3. Skills

목적:

- 작업별 긴 매뉴얼을 `AGENTS.md`에서 분리한다.

템플릿:

```text
codex/project/.agents/skills/codebase-onboarding/SKILL.md
codex/project/.agents/skills/implementation-planning/SKILL.md
codex/project/.agents/skills/bugfix-debugging/SKILL.md
codex/project/.agents/skills/testing-qa/SKILL.md
codex/project/.agents/skills/code-style/SKILL.md
codex/project/.agents/skills/git-workflow/SKILL.md
codex/project/.agents/skills/documentation/SKILL.md
codex/project/.agents/skills/review/SKILL.md
codex/project/.agents/skills/frontend-ui/SKILL.md
codex/project/.agents/skills/backend-api/SKILL.md
codex/project/.agents/skills/database-migration/SKILL.md
codex/project/.agents/skills/security/SKILL.md
codex/project/.agents/skills/performance/SKILL.md
codex/project/.agents/skills/resilience/SKILL.md
codex/project/.agents/skills/i18n-time-currency/SKILL.md
codex/project/.agents/skills/dependency-management/SKILL.md
codex/project/.agents/skills/release-deploy/SKILL.md
codex/project/.agents/skills/observability/SKILL.md
codex/project/.agents/skills/refactoring/SKILL.md
codex/project/.agents/skills/ai-agent-collaboration/SKILL.md
```

체크리스트:

- [ ] 실제 프로젝트에 필요한 skill만 남겼다.
- [ ] 각 `SKILL.md` 내용을 프로젝트 특성에 맞게 채웠다.
- [ ] 관련 skill은 `함께 적용하는 스킬` 섹션으로 서로 연결했다.
- [ ] 완료 전 확인 항목이 검증 가능하다.

## 4. 프로젝트 hooks

목적:

- 요청 시작 시 관련 memory와 skill을 상기한다.
- 세션 시작 시 작업 기억을 복구한다.
- 도구 사용 후 수정 파일과 검증 흔적을 기록한다.
- 최종 답변 전 QA와 체크리스트 누락을 막는다.
- 한글 출력이 깨지지 않도록 `.ps1`을 UTF-8 with BOM으로 저장한다.

템플릿:

```text
codex/project/.codex/hooks.json
codex/project/.codex/hooks/user_prompt_submit.ps1
codex/project/.codex/hooks/session_start.ps1
codex/project/.codex/hooks/pre_tool_use.ps1
codex/project/.codex/hooks/post_tool_use.ps1
codex/project/.codex/hooks/stop_guard.ps1
```

체크리스트:

- [ ] hook 명령이 `powershell.exe`를 사용한다.
- [ ] 모든 `.ps1` 파일이 UTF-8 with BOM이다.
- [ ] `UserPromptSubmit`이 요청 유형에 맞는 skill을 제안한다.
- [ ] `SessionStart`가 `.codex-memory` 확인을 상기한다.
- [ ] `PreToolUse`가 위험 작업 전 관련 skill을 제안하되 승인 결정을 대신하지 않는다.
- [ ] `PostToolUse`가 수정 또는 검증 흔적을 기록한다.
- [ ] `Stop`이 QA 누락 시 추가 작업을 요청하고 반복 실행을 피한다.
- [ ] 프로젝트를 trusted project로 등록하고 `/hooks`에서 hook 정의를 신뢰 처리했다.
- [ ] 저장소 하위 디렉터리에서도 Git 루트 기준 hook 경로가 동작한다.

## 5. Subagents

목적:

- 계획, 리뷰, 테스트, 보안 검토를 역할별로 분리한다.

템플릿:

```text
codex/project/.codex/agents/planner.toml
codex/project/.codex/agents/reviewer.toml
codex/project/.codex/agents/tester.toml
codex/project/.codex/agents/security-reviewer.toml
```

체크리스트:

- [ ] 큰 변경 전 planner 사용 기준을 정했다.
- [ ] 큰 변경 후 reviewer 사용 기준을 정했다.
- [ ] 테스트 실패 작업에서 tester 사용 기준을 정했다.
- [ ] 인증, 권한, 입력 검증 변경에서 security-reviewer 사용 기준을 정했다.

## 6. 리허설

작은 작업으로 전체 흐름을 검증한다.

예시 요청:

```text
작은 문서 문구 하나를 수정하고, CHECKLIST와 QA까지 갱신해줘.
```

완료 기준:

- [ ] 작업 전 memory 확인이 수행됐다.
- [ ] 관련 skill이 제안됐다.
- [ ] 수정 파일이 기록됐다.
- [ ] QA가 갱신됐다.
- [ ] 최종 보고에 수정 내용, 검증, 남은 위험이 포함됐다.
