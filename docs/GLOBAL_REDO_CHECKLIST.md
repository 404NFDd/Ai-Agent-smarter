# 전역 작업 재설정 체크리스트

이 체크리스트는 `C:\Users\msk23\.codex` 전역 설정을 다시 구성할 때 사용한다.
실제 전역 파일은 이 프로젝트에서 자동으로 수정하지 않는다.

## 0. 작업 원칙

- [ ] 전역 설정은 모든 Codex 프로젝트에 영향을 준다는 점을 확인했다.
- [ ] 실제 파일을 덮어쓰기 전에 기존 파일을 백업한다.
- [ ] 템플릿 파일을 그대로 덮어쓰기보다 기존 설정과 병합한다.
- [ ] 한 번에 모든 기능을 켜지 않고 `AGENTS.md`부터 적용한다.
- [ ] hook은 작은 요청으로 동작을 확인한 뒤 점진적으로 추가한다.

## 1. 현재 전역 상태 확인

대상 폴더:

```text
C:\Users\msk23\.codex
```

확인할 파일과 폴더:

- [ ] `C:\Users\msk23\.codex\AGENTS.md` 존재 여부 확인
- [ ] `C:\Users\msk23\.codex\config.toml` 존재 여부 확인
- [ ] `C:\Users\msk23\.codex\hooks.json` 존재 여부 확인
- [ ] `C:\Users\msk23\.codex\hooks\` 존재 여부 확인

확인 명령:

```powershell
Get-ChildItem -Force -LiteralPath "C:\Users\msk23\.codex"
Test-Path -LiteralPath "C:\Users\msk23\.codex\AGENTS.md"
Test-Path -LiteralPath "C:\Users\msk23\.codex\config.toml"
Test-Path -LiteralPath "C:\Users\msk23\.codex\hooks.json"
Test-Path -LiteralPath "C:\Users\msk23\.codex\hooks"
```

## 2. 백업 만들기

- [ ] 날짜가 들어간 백업 폴더를 만든다.
- [ ] 기존 `AGENTS.md`를 백업한다.
- [ ] 기존 `config.toml`을 백업한다.
- [ ] 기존 `hooks.json`이 있으면 백업한다.
- [ ] 기존 `hooks` 폴더가 있으면 통째로 백업한다.

예시:

```powershell
$backup = "C:\Users\msk23\.codex\backup-global-redo-$(Get-Date -Format yyyyMMdd-HHmmss)"
New-Item -ItemType Directory -Force -Path $backup
Copy-Item "C:\Users\msk23\.codex\AGENTS.md" $backup -ErrorAction SilentlyContinue
Copy-Item "C:\Users\msk23\.codex\config.toml" $backup -ErrorAction SilentlyContinue
Copy-Item "C:\Users\msk23\.codex\hooks.json" $backup -ErrorAction SilentlyContinue
Copy-Item "C:\Users\msk23\.codex\hooks" $backup -Recurse -ErrorAction SilentlyContinue
```

## 3. 전역 AGENTS.md 병합

템플릿:

```text
global/AGENTS.md
```

작업:

- [ ] 기존 전역 `AGENTS.md`를 연다.
- [ ] 템플릿의 한글 중심 응답 규칙을 반영한다.
- [ ] 단순함 우선, 외과적 변경, 검증 중심 원칙을 반영한다.
- [ ] 프로젝트별 테스트 명령이나 특정 프로젝트 규칙은 넣지 않는다.
- [ ] 기존에 꼭 유지해야 하는 개인 규칙이 있으면 삭제하지 않고 합친다.

검증:

- [ ] 새 전역 `AGENTS.md`가 한글로 읽히는지 확인했다.
- [ ] 프로젝트별 세부 규칙이 전역 파일에 섞이지 않았다.

## 4. config.toml features 병합

템플릿:

```text
global/config.features.toml
```

작업:

- [ ] 기존 `config.toml`의 `[features]` 섹션을 찾는다.
- [ ] `[features]` 섹션이 없으면 새로 추가한다.
- [ ] 기존 feature 값을 삭제하지 않는다.
- [ ] 아래 항목을 추가한다.

```toml
[features]
hooks = true
multi_agent = true
```

주의:

- [ ] 이미 `[features]`가 있다면 섹션을 중복 생성하지 않는다.
- [ ] 기존 `js_repl`, plugin, MCP, project 설정은 건드리지 않는다.

## 5. 전역 hooks 파일 적용

템플릿:

```text
global/hooks.json
global/hooks/global_user_prompt_submit.ps1
global/hooks/global_session_start.ps1
```

작업:

- [ ] `C:\Users\msk23\.codex\hooks\` 폴더를 만든다.
- [ ] `global_user_prompt_submit.ps1`을 hooks 폴더에 복사한다.
- [ ] `global_session_start.ps1`을 hooks 폴더에 복사한다.
- [ ] `hooks.json`을 전역 폴더에 병합하거나 복사한다.
- [ ] hook 명령이 `powershell.exe`를 사용하는지 확인한다.
- [ ] `.ps1` 파일이 UTF-8 with BOM인지 확인한다.

검증:

```powershell
Get-Content "C:\Users\msk23\.codex\hooks.json" -Encoding UTF8 -Raw | ConvertFrom-Json
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\msk23\.codex\hooks\global_user_prompt_submit.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\msk23\.codex\hooks\global_session_start.ps1"
```

## 6. Codex 재시작 후 확인

- [ ] Codex를 재시작한다.
- [ ] 새 대화에서 짧은 요청을 보낸다.
- [ ] 전역 `AGENTS.md` 규칙이 반영되는지 확인한다.
- [ ] `UserPromptSubmit` hook의 추가 컨텍스트가 들어오는지 확인한다.
- [ ] 새 세션 또는 resume에서 `SessionStart` hook 안내가 나오는지 확인한다.

테스트 요청 예시:

```text
이 프로젝트에서 AGENTS.md와 memory 파일 확인하고 현재 상태만 요약해줘.
```

## 7. 실패 시 되돌리기

- [ ] hook 오류가 나면 먼저 `hooks.json`을 백업본으로 되돌린다.
- [ ] PowerShell 인코딩 오류가 나면 `.ps1`을 UTF-8 with BOM으로 다시 저장한다.
- [ ] Codex가 시작 단계에서 불안정하면 hooks 기능을 끄고 `AGENTS.md`만 유지한다.
- [ ] 문제가 계속되면 백업 폴더의 `AGENTS.md`, `config.toml`, `hooks.json`, `hooks`를 복원한다.

## 8. 완료 기록

- [ ] 적용한 파일 목록을 기록했다.
- [ ] 실행한 검증 명령과 결과를 기록했다.
- [ ] 실패한 항목과 되돌린 항목을 기록했다.
- [ ] 남은 위험을 기록했다.
