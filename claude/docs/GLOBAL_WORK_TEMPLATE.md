# 전역 작업 템플릿

이 문서는 `~/.claude` 전역 설정에 적용할 작업 순서 템플릿이다. Windows 경로는 `C:\Users\<사용자>\.claude` 다.

전역 작업은 여러 프로젝트에 영향을 주므로 실제 적용 전 반드시 백업과 병합 계획을 먼저 세운다.

## 0. 현재 상태 확인과 백업

대상:

```text
~/.claude/CLAUDE.md
~/.claude/settings.json
~/.claude/agents/
~/.claude/skills/
```

체크리스트:

- [ ] `CLAUDE.md` 존재 여부와 내용을 확인했다.
- [ ] `settings.json` 존재 여부와 기존 `hooks`, `permissions` 키를 확인했다.
- [ ] 개인 `agents`, `skills` 폴더에 이름이 겹치는 항목이 없는지 확인했다.
- [ ] 수정 전 백업 파일을 만들었다.

검증:

```bash
cat ~/.claude/CLAUDE.md
cat ~/.claude/settings.json
ls ~/.claude/agents ~/.claude/skills 2>/dev/null
```

## 1. 전역 CLAUDE.md 적용

목적:

- 한글 중심 응답 규칙을 둔다.
- 단순함, 외과적 변경, 검증 중심 원칙을 전역에 둔다.
- 프로젝트별 명령은 넣지 않는다.

템플릿:

```text
claude/global/CLAUDE.md
```

체크리스트:

- [ ] 기존 전역 `CLAUDE.md` 와 충돌하는 규칙을 확인했다.
- [ ] 프로젝트별 테스트 명령이 전역 파일에 들어가지 않았다.
- [ ] Plan Mode 와 서브에이전트 사용 원칙이 포함됐다.
- [ ] skill 사용 원칙(목차 먼저, 필요한 챕터만)이 포함됐다.

## 2. 전역 settings.json 병합

목적:

- 되돌리기 어려운 명령에 확인 절차를 둔다.
- 전역 세션 지침을 한 줄 주입한다.

템플릿:

```text
claude/global/settings.json
```

체크리스트:

- [ ] JSON 이 유효하다. (`python3 -m json.tool ~/.claude/settings.json`)
- [ ] 기존 `hooks` 키를 덮어쓰지 않고 이벤트 단위로 병합했다.
- [ ] 기존 `permissions.allow` / `deny` 항목이 삭제되지 않았다.
- [ ] `$comment` 키는 남겨도 되고 지워도 된다. Claude Code 는 무시한다.

## 3. 전역 SessionStart hook 확인

목적:

- 새 세션과 resume 이후 프로젝트 규칙 확인을 상기시킨다.

체크리스트:

- [ ] Claude Code 재시작 후 `/hooks` 에 SessionStart 항목이 보인다.
- [ ] 새 세션에서 전역 지침이 반영된다.
- [ ] 프로젝트 hook 과 안내가 중복되지 않는다.

## 4. 전역/프로젝트 우선순위

- 전역은 범용 안내만 담당한다. 강제 게이트(`decision: block`, `permissionDecision: deny`)를 두지 않는다.
- 강제 게이트는 프로젝트 `.claude/settings.json` 에만 둔다.
- 같은 이벤트에 전역/프로젝트 hook 이 둘 다 달리면 둘 다 실행된다. 안내가 중복되면 전역 쪽 항목을 지운다.
- 전역 `agents/`, `skills/` 와 프로젝트 쪽 이름이 겹치면 프로젝트 쪽이 우선한다.

## 5. 실패 시 fallback

전역 hook 이 불안정하면 다음만 유지한다.

```text
전역 CLAUDE.md
프로젝트 CLAUDE.md
프로젝트 .claude-memory/*
프로젝트 .claude/skills/*
작업 시작 프롬프트 템플릿
작업 종료 프롬프트 템플릿
```

fallback 기준:

- [ ] hook 실행 오류가 반복된다.
- [ ] 전역 안내가 모든 프로젝트에서 소음이 된다.
- [ ] hook payload 구조를 안정적으로 파악하지 못했다.
