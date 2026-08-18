# 적용 가이드

이 가이드는 템플릿을 실제 프로젝트에 적용할 때의 최소 절차다.

## 사전 조건

- Claude Code 가 설치되어 있고 `claude` 명령이 동작한다.
- hook 은 bash 로 실행된다. Windows 에서는 Claude Code 가 요구하는 Git Bash 환경이 필요하다.
- hook 스크립트는 `jq` 를 쓰지 않는다. 추가 설치가 필요 없다.
- 스크립트 파일은 LF 줄바꿈, BOM 없는 UTF-8 로 저장한다. CRLF 로 저장하면 bash 가 `\r` 때문에 실패한다.

## 전역 적용

1. 기존 `~/.claude/CLAUDE.md` 와 `~/.claude/settings.json` 을 읽는다.
2. 백업 파일을 만든다.
3. `global/` 파일을 그대로 덮어쓰지 말고 기존 설정에 병합한다. `settings.json` 은 키 단위로 병합한다.
4. Claude Code 를 재시작한다.
5. `/hooks` 로 새 hook 정의를 검토한다.
6. 짧은 요청으로 전역 지침 주입 여부를 확인한다.

전역에는 강제 게이트(`decision: block`, `permissionDecision: deny`)를 두지 않는다. 모든 프로젝트의 종료를 반복시킬 수 있다.

## 프로젝트 적용

1. 대상 프로젝트 루트에 `project/` 내용을 복사한다.

   ```text
   <프로젝트>/CLAUDE.md
   <프로젝트>/.claude/
   <프로젝트>/.claude-memory/
   ```

2. `.claude/verify.toml` 의 `lint`, `test`, `typecheck`, `build` 각 `command` 를 그 프로젝트 실제 명령으로 채운다. 빈 문자열 항목은 건너뛴다.
3. hook 스크립트에 실행 권한을 준다.

   ```bash
   chmod +x .claude/hooks/*.sh
   ```

4. 필요 없는 skill 은 바로 삭제하지 말고 처음에는 그대로 둔다. 두세 번 작업해 보고 안 걸리는 skill 만 지운다.
5. Claude Code 를 프로젝트 루트에서 실행하고 `/hooks` 로 hook 정의를 검토한다.
6. 작은 문서 수정으로 리허설한다.

`$CLAUDE_PROJECT_DIR` 는 Claude Code 가 hook 에 주입하는 프로젝트 루트 경로다. hook 스크립트 자체는 자기 위치에서 루트를 계산하므로, 하위 디렉터리에서 실행해도 동작한다.

## 검증 절차

리허설 요청:

```text
README.md 의 문구 하나를 수정하고, CHECKLIST 와 QA 까지 갱신해줘.
```

확인할 것:

- [ ] 세션 시작 시 `.claude-memory` 의 PLAN / CHECKLIST / CONTEXT 내용이 컨텍스트에 들어왔다.
- [ ] 파일 수정 후 `.claude-memory/MODIFIED_FILES.md` 에 행이 추가됐다.
- [ ] 수정 직후 셀프체크 리마인더가 응답에 반영됐다.
- [ ] `CHECKLIST.md` 에 미완료 항목을 남기면 종료가 한 번 차단된다.
- [ ] 항목을 완료하면 종료가 통과된다.

hook 단독 테스트:

```bash
echo '{"hook_event_name":"SessionStart","source":"startup"}' | bash .claude/hooks/session_start.sh
echo '{"tool_name":"Edit","tool_input":{"file_path":"/abs/path/x.ts"}}' | bash .claude/hooks/post_tool_use.sh
echo '{"hook_event_name":"Stop"}' | bash .claude/hooks/stop_guard.sh
```

`post_tool_use.sh` 와 `stop_guard.sh` 는 JSON 한 줄을 출력해야 한다. `session_start.sh` 는 평문을 출력한다.

## 작업 시작 프롬프트 템플릿

hook 이 동작하지 않을 때 쓰는 수동 프롬프트다.

```text
이 작업은 운영 시스템 방식으로 진행해.

1. CLAUDE.md 를 확인해.
2. .claude/skills/INDEX.md 에서 관련 skill 을 골라 읽어.
3. .claude-memory/PLAN.md, CONTEXT.md, CHECKLIST.md 를 확인해.
4. 큰 작업이면 Plan Mode 로 계획만 먼저 세우고 구현하지 마.
5. 내가 승인하면 /plan-start 로 저장하고 CHECKLIST 단위로 구현해.
```

## 작업 종료 프롬프트 템플릿

```text
최종 답변 전에 다음을 확인해.

1. 수정 파일 목록
2. CHECKLIST.md 갱신 여부
3. QA.md 갱신 여부
4. 검증 실행 결과
5. 남은 위험
6. reviewer 또는 security-reviewer 검토 필요 여부
```

`/wrap-up` slash command 가 같은 일을 한다.

## 주의

- 전역 설정은 모든 프로젝트에 영향을 준다.
- Stop hook 의 `decision: block` 은 종료 거부가 아니라 Claude 에게 추가 작업을 계속 요청하는 것이다.
- 같은 사유로 2회 차단하면 사용자 확인으로 전환하고, 세션 누적 8회를 넘으면 advisory 로 내려간다. 무한 루프가 나지 않는다.
- hook 실패가 반복되면 hook 보다 `CLAUDE.md`, `.claude-memory`, skill, slash command 를 우선한다.

## fallback

hook 이 안정적으로 동작하지 않으면 다음만 유지한다.

```text
전역 CLAUDE.md
프로젝트 CLAUDE.md  (@import 로 작업 기억 자동 로드)
프로젝트 .claude-memory/*
프로젝트 .claude/skills/*
프로젝트 .claude/agents/*
프로젝트 .claude/commands/*
```

이 상태에서도 4대 시스템 중 1, 2, 4 는 그대로 동작한다. 3(자동 품질 검사)만 수동 `/wrap-up` 으로 대체된다.

## 설계 근거

4대 시스템의 원래 출처와 설계 의도는 저장소 루트의 `설계근거.md` 에 있다. codex 판과의 차이는 `CODEX_VS_CLAUDE.md` 에 있다.
