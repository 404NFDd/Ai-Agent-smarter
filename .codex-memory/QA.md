# QA

## 실행한 검증

| 명령 | 결과 | 일시 | 메모 |
| --- | --- | --- | --- |
| `Get-ChildItem -Force` | 통과 | 2026-06-02 | 프로젝트 폴더가 비어 있음을 확인했다. |
| `rg "^#{1,3} " pasted-text.txt` | 통과 | 2026-06-02 | 붙여넣은 문서의 주요 섹션을 확인했다. |
| `ConvertFrom-Json` on hook JSON files | 통과 | 2026-06-02 | 전역/프로젝트 `hooks.json` 형식 확인 |
| PowerShell parser on `*.ps1` | 통과 | 2026-06-02 | 모든 hook 스크립트 파싱 확인 |
| `Get-ChildItem -Recurse -File -Force` | 통과 | 2026-06-02 | 총 37개 파일 생성 확인 |
| `.ps1` BOM byte check | 통과 | 2026-06-02 | 6개 hook 스크립트 모두 UTF-8 BOM 확인 |
| PowerShell parser on Korean `*.ps1` | 통과 | 2026-06-02 | 한글 문구로 되돌린 뒤 모든 hook 스크립트 파싱 확인 |
| `ConvertFrom-Json` on updated hook JSON files | 통과 | 2026-06-02 | `powershell.exe` 명시 후 JSON 형식 확인 |
| `powershell.exe -File templates\global\hooks\global_user_prompt_submit.ps1` | 통과 | 2026-06-02 | 한글 additionalContext JSON 출력 확인 |
| `"UI 테스트 고쳐" | powershell.exe -File templates\project\.codex\hooks\user_prompt_submit.ps1` | 통과 | 2026-06-02 | 한글 additionalContext JSON 출력 확인 |
| `Get-Content -Encoding UTF8 pasted-text.txt` | 통과 | 2026-06-02 | 첨부 원문을 UTF-8로 정상 확인 |
| `rg --files --hidden` | 통과 | 2026-06-02 | 숨김 템플릿 파일을 포함한 파일 목록 확인 |
| `Get-ChildItem -Recurse -File -Force \| Measure-Object` | 통과 | 2026-06-02 | 전체 파일 38개 확인 |
| 문서 수동 검토 | 통과 | 2026-06-02 | 실제 전역 파일을 수정하지 않는 체크리스트로 작성했는지 확인 |
| 전역 백업 생성 | 통과 | 2026-06-02 | `C:\Users\msk23\.codex\backup-global-redo-20260602-205657` 생성 |
| `Get-Content ... config.toml \| Select-String` | 통과 | 2026-06-02 | `[features]`, `multi_agent = true`, `hooks = true`, 기존 `js_repl = false` 확인 |
| `powershell.exe ... global_user_prompt_submit.ps1` | 통과 | 2026-06-02 | UserPromptSubmit additionalContext JSON 출력 확인 |
| `powershell.exe ... global_session_start.ps1` | 통과 | 2026-06-02 | SessionStart additionalContext JSON 출력 확인 |
| `Get-Content ... hooks.json -Raw \| ConvertFrom-Json` | 통과 | 2026-06-02 | 전역 `hooks.json` 형식 확인 |
| 전역 `.ps1` BOM byte check | 통과 | 2026-06-02 | 전역 hook 스크립트 2개 모두 UTF-8 BOM 확인 |
| `powershell.exe -File C:\Users\msk23\.codex\hooks\global_user_prompt_submit.ps1` | 통과 | 2026-06-02 | 실제 전역 UserPromptSubmit additionalContext에 `[HOOK: UserPromptSubmit 읽음]` 포함 확인 |
| `powershell.exe -File C:\Users\msk23\.codex\hooks\global_session_start.ps1` | 통과 | 2026-06-02 | 실제 전역 SessionStart additionalContext에 `[HOOK: SessionStart 읽음]` 포함 확인 |
| `powershell.exe -File templates\global\hooks\global_user_prompt_submit.ps1` | 통과 | 2026-06-02 | 템플릿 UserPromptSubmit additionalContext에 hook 읽음 표시 포함 확인 |
| `powershell.exe -File templates\global\hooks\global_session_start.ps1` | 통과 | 2026-06-02 | 템플릿 SessionStart additionalContext에 hook 읽음 표시 포함 확인 |
| `Get-Content -Encoding UTF8 pasted-text.txt` | 통과 | 2026-06-04 | 첨부 원문을 UTF-8로 정상 확인하고 핵심 4개 시스템을 대조했다. |
| `rg --files --hidden` | 통과 | 2026-06-04 | 숨김 템플릿까지 포함해 project memory, skills, hooks, agents 파일 존재를 확인했다. |
| `ConvertFrom-Json` on template hook JSON files | 통과 | 2026-06-04 | 전역/프로젝트 hook JSON 형식 확인 |
| PowerShell parser on template `*.ps1` | 통과 | 2026-06-04 | 전역/프로젝트 hook 스크립트 6개 파싱 확인 |
| `.ps1` BOM byte check | 통과 | 2026-06-04 | 전역/프로젝트 hook 스크립트 6개 모두 UTF-8 BOM 확인 |
| `Move-Item templates\global -> global` | 통과 | 2026-06-04 | 전역 템플릿을 루트 `global` 폴더로 이동했다. |
| `Select-String templates/global references` | 통과 | 2026-06-04 | 안내 문서의 이전 전역 경로 참조가 제거됐고, 남은 참조는 과거 기록 또는 이동 기록뿐임을 확인했다. |
| `ConvertFrom-Json` on `global/hooks.json` | 통과 | 2026-06-04 | 이동 후 전역 hook JSON 형식 확인 |
| PowerShell parser on `global/hooks/*.ps1` and project hooks | 통과 | 2026-06-04 | 이동 후 전역/프로젝트 hook 스크립트 6개 파싱 확인 |
| `.ps1` BOM byte check on `global/hooks/*.ps1` and project hooks | 통과 | 2026-06-04 | 이동 후 전역/프로젝트 hook 스크립트 6개 모두 UTF-8 BOM 확인 |
| `ConvertFrom-Json` on `global/hooks.json` | 통과 | 2026-06-04 | 전역 운영 지침 추가 후 JSON 형식 재확인 |
| `powershell.exe -File global/hooks/global_user_prompt_submit.ps1` | 통과 | 2026-06-04 | 전역 UserPromptSubmit 운영 지침 additionalContext 출력 확인 |
| `powershell.exe -File global/hooks/global_session_start.ps1` | 통과 | 2026-06-04 | 전역 SessionStart 운영 지침 additionalContext 출력 확인 |
| `.ps1` BOM byte check on `global/hooks/*.ps1` | 통과 | 2026-06-04 | PowerShell 5.1 한글 안정성을 위해 BOM 유지 확인 |
| 비유 표현 검색 | 통과 | 2026-06-04 | 설명용 표현이 hook 템플릿과 기록 파일에 남지 않았음을 확인 |
| `powershell.exe -File global/hooks/global_user_prompt_submit.ps1` | 통과 | 2026-06-04 | UserPromptSubmit 출력이 중립적인 운영 지침으로 정리됐음을 확인 |
| `ConvertFrom-Json` on `global/hooks.json` | 통과 | 2026-06-04 | 전역 hook을 이벤트별 단일 목적 구조로 분리한 뒤 JSON 형식 확인 |
| `powershell.exe -File global/hooks/global_user_prompt_submit.ps1` | 통과 | 2026-06-04 | 요청 시작 지침만 출력하는지 확인 |
| `powershell.exe -File global/hooks/global_session_start.ps1` | 통과 | 2026-06-04 | 세션 시작 memory 확인만 출력하는지 확인 |
| `powershell.exe -File global/hooks/global_post_tool_use.ps1` | 통과 | 2026-06-04 | 도구 사용 후 기록 확인만 출력하는지 확인 |
| `powershell.exe -File global/hooks/global_stop_check.ps1` | 통과 | 2026-06-04 | 종료 전 검증/위험 확인과 allow decision 출력 확인 |
| `.ps1` BOM byte check on `global/hooks/*.ps1` | 통과 | 2026-06-04 | 전역 hook 스크립트 4개 모두 UTF-8 BOM 확인 |
| `ConvertFrom-Json` on `templates/project/.codex/hooks.json` | 통과 | 2026-06-04 | 프로젝트 hook에 PreToolUse, PermissionRequest 추가 후 JSON 형식 확인 |
| `powershell.exe -File templates/project/.codex/hooks/user_prompt_submit.ps1` | 통과 | 2026-06-04 | `login API auth bug fix` 요청에서 bugfix, backend-api, security skill 후보 확인 |
| `powershell.exe -File templates/project/.codex/hooks/user_prompt_submit.ps1` | 통과 | 2026-06-04 | `review docs and commit PR` 요청에서 git-workflow, documentation, review skill 후보 확인 |
| `powershell.exe -File templates/project/.codex/hooks/pre_tool_use.ps1` | 통과 | 2026-06-04 | dependency, migration 위험 작업 전 skill 후보 확인 |
| `.ps1` BOM byte check on `templates/project/.codex/hooks/*.ps1` | 통과 | 2026-06-04 | 프로젝트 hook 스크립트 5개 모두 UTF-8 BOM 확인 |
| `rg --files --hidden templates/project/.agents/skills` | 통과 | 2026-06-04 | 필수/추가 skill 18개 `SKILL.md` 파일 확인 |
| `Get-ChildItem ... SKILL.md length` | 통과 | 2026-06-04 | 모든 프로젝트 `SKILL.md`가 0바이트 빈 파일임을 확인 |
| 이전 축약 skill 경로 검색 | 통과 | 2026-06-04 | `backend/frontend/database/testing` skill 경로 참조가 남지 않았음을 확인 |
| `SKILL.md frontmatter/name/description/empty validation` | 통과 | 2026-06-04 | 18개 skill 모두 폴더명과 `name` 일치, `description` 존재, 빈 파일 없음 |
| `Hook skill references path validation` | 통과 | 2026-06-04 | `user_prompt_submit.ps1`, `pre_tool_use.ps1`가 참조하는 18개 skill 경로 존재 확인 |
| `git diff --stat` | 통과 | 2026-06-04 | 18개 `SKILL.md`에 총 665줄 추가 확인 |

## 실패한 검증

| 명령 | 실패 내용 | 조치 |
| --- | --- | --- |
| `Get-Content ... | Select-Object -Index 1..80` | PowerShell에서 `1..80`이 `-Index` 값으로 직접 바인딩되지 않음 | `Select-Object -First 100`으로 다시 확인 |
| 초기 PowerShell parser on `*.ps1` | BOM 없는 UTF-8 스크립트의 한글 문자열 파싱 오류 | hook `.ps1` 템플릿 문자열을 ASCII로 수정 후 재검증 통과 |
| 최초 전역 `hooks.json` 검증 병렬 실행 | 샌드박스 준비 단계 오류 | 동일 검증을 단독 escalated 실행으로 재시도해 통과 |
| skill 검증 병렬 실행 일부 | Windows sandbox setup refresh 오류 | 동일 frontmatter/경로 검증을 단독 escalated 실행으로 재시도해 통과 |

## 수동 확인 필요

- 실제 전역 hook 동작은 Codex 재시작 또는 다음 새 요청에서 응답 첫 줄 표시 여부로 확인해야 한다.
- 각 대상 프로젝트의 실제 테스트 명령은 프로젝트별로 채워야 한다.

## 남은 위험

- Codex hook payload 구조가 환경에 따라 다르면 `post_tool_use.ps1` 조정이 필요하다.
- 실제 전역 설정과 실제 대상 프로젝트에는 아직 적용하지 않았다.
- PowerShell 파이프 입력의 한글 인코딩은 호출 환경에 따라 달라질 수 있으므로 실제 Codex hook stdin으로 한 번 더 리허설해야 한다.
- 삭제된 `.codex` 폴더 안의 과거 대화 로그는 백업, 휴지통, 파일 복구 도구가 없으면 이 프로젝트 기록만으로는 복원할 수 없다.
- 전역 hook 스크립트 출력에는 표시 문구가 들어갔지만, 실행 중인 Codex 세션이 hook 컨텍스트를 새로 주입하는지는 새 요청 또는 재시작으로 확인해야 한다.
- 이번 전역 운영 지침 추가도 실제 전역 설정이 아니라 루트 `global` 템플릿에만 반영했다.
- 이벤트별 hook 분리도 실제 전역 설정이 아니라 루트 `global` 템플릿에만 반영했다.
- skill 본문은 범용 템플릿 기준이므로, 실제 대상 프로젝트 적용 시 프레임워크별 명령과 조직 규칙은 프로젝트별 `references/`나 문서로 보강해야 한다.
