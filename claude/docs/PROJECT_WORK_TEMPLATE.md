# 프로젝트 작업 템플릿

이 문서는 각 프로젝트 루트에 적용할 Claude Code 운영 시스템 템플릿이다.

대상 프로젝트에 `claude/project` 내용을 복사한 뒤, 프로젝트 특성에 맞게 검증 명령과 skill 내용을 조정한다.

## 1. 프로젝트 CLAUDE.md

목적:

- 작업 전 확인 대상을 고정한다.
- 작업 기억 파일을 `@import` 로 자동 로드한다.
- 작업 중 체크리스트 갱신과 완료 전 QA 기록을 강제한다.

템플릿:

```text
claude/project/CLAUDE.md
```

체크리스트:

- [ ] 하단 `@.claude-memory/...` import 세 줄이 그대로 남아 있다.
- [ ] 프로젝트별 금지 사항을 필요한 만큼만 추가했다.
- [ ] 긴 세부 규칙은 skill 로 분리했다.
- [ ] 프로젝트 검증 명령은 여기가 아니라 `.claude/verify.toml` 에 넣었다.

## 2. 작업 기억 파일

목적:

- 계획, 맥락, 체크리스트, QA, 결정사항, 수정 파일 기록을 남긴다.

템플릿:

```text
claude/project/.claude-memory/PLAN.md
claude/project/.claude-memory/CONTEXT.md
claude/project/.claude-memory/CHECKLIST.md
claude/project/.claude-memory/QA.md
claude/project/.claude-memory/DECISIONS.md
claude/project/.claude-memory/METRICS.md
claude/project/.claude-memory/MODIFIED_FILES.md
```

체크리스트:

- [ ] 큰 작업 전 `PLAN.md` 에 목표와 검증 기준을 적었다.
- [ ] 중요한 결정은 `CONTEXT.md` 또는 `DECISIONS.md` 에 적었다.
- [ ] 진행 상태는 `CHECKLIST.md` 에 갱신했다.
- [ ] 검증 결과와 남은 위험은 `QA.md` 에 적었다.
- [ ] `MODIFIED_FILES.*.md` 아카이브 파일은 `.gitignore` 에 넣었다.

`.gitignore` 권장 항목:

```text
.claude-memory/MODIFIED_FILES.*.md
.claude-memory/.stop_guard_state
.claude-memory/.session_blocks
.claude/settings.local.json
```

## 3. Skills

목적:

- 작업별 긴 매뉴얼을 `CLAUDE.md` 에서 분리한다.
- Claude Code 가 `description` 을 보고 스스로 필요한 매뉴얼을 연다.

템플릿:

```text
claude/project/.claude/skills/INDEX.md
claude/project/.claude/skills/<21개>/SKILL.md
```

체크리스트:

- [ ] 각 `SKILL.md` frontmatter 의 `name` 이 폴더명과 같다.
- [ ] `description` 에 "무엇을 하는지" 와 "언제 쓰는지" 가 둘 다 있다.
- [ ] 실제 이 프로젝트에 필요한 skill 만 남겼다.
- [ ] 각 `SKILL.md` 내용을 프로젝트 특성에 맞게 채웠다.
- [ ] 관련 skill 은 `함께 적용하는 스킬` 섹션으로 서로 연결했다.
- [ ] 300줄이 넘는 skill 은 `chapters/*.md` 로 쪼갰다.
- [ ] 완료 전 확인 항목이 검증 가능하다.

## 4. 프로젝트 hooks

목적:

- 세션 시작 시 수정 기록을 초기화하고 남은 작업을 복구한다.
- 파일 수정 때마다 수정 파일을 기록하고 셀프체크를 상기한다.
- 최종 답변 전 검증을 실행하고 QA 누락을 막는다.

템플릿:

```text
claude/project/.claude/settings.json
claude/project/.claude/verify.toml
claude/project/.claude/hooks/session_start.sh
claude/project/.claude/hooks/post_tool_use.sh
claude/project/.claude/hooks/stop_guard.sh
```

체크리스트:

- [ ] `settings.json` 이 유효한 JSON 이다.
- [ ] `.sh` 파일이 LF 줄바꿈, BOM 없는 UTF-8 이다.
- [ ] `chmod +x .claude/hooks/*.sh` 를 실행했다.
- [ ] `verify.toml` 의 command 를 실제 명령으로 채웠다.
- [ ] `SessionStart` 가 남은 CHECKLIST 항목을 보여 준다.
- [ ] `PostToolUse` 가 수정 파일을 기록하고 셀프체크를 반환한다.
- [ ] `Stop` 이 QA 누락 시 추가 작업을 요청하고, 2회 후 사용자 확인으로 전환한다.
- [ ] `/hooks` 에서 hook 정의를 검토했다.

## 5. Subagents

목적:

- 계획, 리뷰, 테스트, 보안 검토를 역할별로 분리한다.

템플릿:

```text
claude/project/.claude/agents/planner.md
claude/project/.claude/agents/reviewer.md
claude/project/.claude/agents/tester.md
claude/project/.claude/agents/security-reviewer.md
```

체크리스트:

- [ ] 각 파일 frontmatter 의 `name` 이 파일명과 같다.
- [ ] `description` 에 언제 호출되어야 하는지 조건이 들어 있다.
- [ ] 보고 형식 5항목이 모두 들어 있다.
- [ ] `QA.md` 의 `## <에이전트명> 보고` 마커 규약이 `stop_guard.sh` 와 일치한다.
- [ ] `/agents` 에서 네 개가 모두 보인다.

## 6. Slash commands

목적:

- 계획 저장, 중간 체크, 마무리 절차를 사람이 매번 타이핑하지 않게 고정한다.

템플릿:

```text
claude/project/.claude/commands/plan-start.md
claude/project/.claude/commands/checkpoint.md
claude/project/.claude/commands/wrap-up.md
```

체크리스트:

- [ ] `/plan-start`, `/checkpoint`, `/wrap-up` 이 목록에 보인다.
- [ ] `/plan-start` 가 구현으로 넘어가지 않고 문서 저장에서 멈춘다.

## 7. 리허설

작은 작업으로 전체 흐름을 검증한다.

예시 요청:

```text
작은 문서 문구 하나를 수정하고, CHECKLIST 와 QA 까지 갱신해줘.
```

완료 기준:

- [ ] 세션 시작 시 작업 기억이 로드됐다.
- [ ] 관련 skill 이 자동으로 열렸다.
- [ ] 수정 파일이 `MODIFIED_FILES.md` 에 기록됐다.
- [ ] 셀프체크 리마인더가 응답에 반영됐다.
- [ ] `QA.md` 가 갱신됐다.
- [ ] 최종 보고에 수정 내용, 검증, 남은 위험이 포함됐다.
