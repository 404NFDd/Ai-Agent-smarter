# 전역 작업 템플릿

이 문서는 `C:\Users\<사용자>\.codex` 전역 설정에 적용할 작업 순서 템플릿이다.

전역 작업은 여러 프로젝트에 영향을 주므로 실제 적용 전 반드시 백업과 병합 계획을 먼저 세운다.

## 0. 현재 상태 확인과 백업

대상:

```text
C:\Users\<사용자>\.codex\config.toml
C:\Users\<사용자>\.codex\AGENTS.md
C:\Users\<사용자>\.codex\hooks.json
C:\Users\<사용자>\.codex\hooks\
```

체크리스트:

- [ ] `config.toml` 존재 여부와 `[features]` 섹션을 확인했다.
- [ ] `AGENTS.md` 내용을 확인했다.
- [ ] `hooks.json` 존재 여부를 확인했다.
- [ ] `hooks` 폴더 존재 여부를 확인했다.
- [ ] 수정 전 백업 파일을 만들었다.

검증:

```powershell
Get-Content -LiteralPath "C:\Users\<사용자>\.codex\config.toml" -Encoding UTF8 -Raw
Get-Content -LiteralPath "C:\Users\<사용자>\.codex\AGENTS.md" -Encoding UTF8 -Raw
Test-Path -LiteralPath "C:\Users\<사용자>\.codex\hooks.json"
Test-Path -LiteralPath "C:\Users\<사용자>\.codex\hooks"
```

## 1. 전역 AGENTS.md 적용

목적:

- 한글 중심 응답 규칙을 둔다.
- 단순함, 외과적 변경, 검증 중심 원칙을 전역에 둔다.
- 프로젝트별 세부 명령은 넣지 않는다.

템플릿:

```text
codex/global/AGENTS.md
```

체크리스트:

- [ ] 기존 전역 `AGENTS.md`와 충돌하는 규칙을 확인했다.
- [ ] 프로젝트별 테스트 명령이 전역 파일에 들어가지 않았다.
- [ ] memory와 QA 확인 규칙이 포함됐다.

## 2. config.toml feature 확인

목적:

- 기본 활성화된 hooks와 multi-agent 기능을 정책상 명시적으로 고정할지 결정한다.
- 기존 plugin, MCP, desktop, project 설정을 건드리지 않는다.

템플릿:

```text
codex/global/config.features.toml
```

체크리스트:

- [ ] `[features]` 섹션이 중복되지 않았다.
- [ ] 기본 활성값을 그대로 사용할지, `hooks = true`와 `multi_agent = true`를 명시적으로 고정할지 결정했다.
- [ ] 기존 설정이 삭제되지 않았다.

## 3. 전역 UserPromptSubmit hook 테스트

목적:

- Windows 환경에서 hook 주입이 실제로 동작하는지 확인한다.
- 한글 출력이 깨지지 않도록 `.ps1`을 UTF-8 with BOM으로 저장한다.

템플릿:

```text
codex/global/hooks.json
codex/global/hooks/global_user_prompt_submit.ps1
codex/global/hooks/global_post_tool_use.ps1
```

체크리스트:

- [ ] `hooks.json`이 유효한 JSON이다.
- [ ] hook 명령이 `powershell.exe`를 사용한다.
- [ ] `.ps1` 파일이 UTF-8 with BOM이다.
- [ ] PowerShell 실행 정책 오류가 없다.
- [ ] 새 요청에서 전역 운영 컨텍스트가 주입된다.

## 4. 전역 SessionStart hook 추가

목적:

- 새 세션, resume, compact 이후 프로젝트 memory 확인을 상기시킨다.

템플릿:

```text
codex/global/hooks/global_session_start.ps1
codex/global/hooks/global_post_tool_use.ps1
```

체크리스트:

- [ ] `SessionStart` 설정이 `UserPromptSubmit` 설정을 덮어쓰지 않았다.
- [ ] 새 세션에서 memory 확인 알림이 나온다.
- [ ] `/hooks`에서 새 hook 정의를 검토하고 신뢰 처리했다.

## 5. 실패 시 fallback

hooks가 안정적으로 동작하지 않으면 다음 구조만 유지한다.

```text
전역 AGENTS.md
프로젝트 AGENTS.md
프로젝트 .codex-memory/*
프로젝트 .agents/skills/*
작업 시작 프롬프트 템플릿
작업 종료 프롬프트 템플릿
```

fallback 기준:

- [ ] hooks 실행 오류가 반복된다.
- [ ] 프로젝트 Stop hook이 과도한 추가 작업을 반복 요청한다.
- [ ] payload 구조를 안정적으로 파악하지 못했다.
