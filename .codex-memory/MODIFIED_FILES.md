# MODIFIED FILES

| 일시 | 파일 | 작업 | 메모 |
| --- | --- | --- | --- |
| 2026-06-02 | `README.md` | 생성 | 템플릿 프로젝트 안내 |
| 2026-06-02 | `AGENTS.md` | 생성 | 템플릿 프로젝트 작업 규칙 |
| 2026-06-02 | `docs/GLOBAL_WORK_TEMPLATE.md` | 생성 | 전역 작업 템플릿 |
| 2026-06-02 | `docs/PROJECT_WORK_TEMPLATE.md` | 생성 | 프로젝트 작업 템플릿 |
| 2026-06-02 | `docs/APPLY_GUIDE.md` | 생성 | 적용 가이드 |
| 2026-06-02 | `.codex-memory/*` | 생성 | 현재 작업 기록 |
| 2026-06-02 | `templates/global/*` | 생성 | 전역 AGENTS, config, hooks 템플릿 |
| 2026-06-02 | `templates/project/*` | 생성 | 프로젝트 AGENTS, memory, skills, hooks, subagents 템플릿 |
| 2026-06-02 | `templates/**/*.ps1` | 수정 | PowerShell 파싱 안정성을 위해 실행 문자열을 ASCII로 조정 |
| 2026-06-02 | `.codex-memory/CHECKLIST.md` | 수정 | 완료 상태 반영 |
| 2026-06-02 | `.codex-memory/QA.md` | 수정 | 검증 결과 반영 |
| 2026-06-02 | `templates/**/*.ps1` | 수정 | UTF-8 with BOM 기준으로 한글 문구 복원 및 콘솔 UTF-8 설정 추가 |
| 2026-06-02 | `templates/global/hooks.json` | 수정 | hook 명령을 `powershell.exe`로 명시 |
| 2026-06-02 | `templates/project/.codex/hooks.json` | 수정 | hook 명령을 `powershell.exe`로 명시 |
| 2026-06-02 | `docs/APPLY_GUIDE.md` | 수정 | UTF-8 with BOM 적용 규칙 추가 |
| 2026-06-02 | `docs/GLOBAL_WORK_TEMPLATE.md` | 수정 | 전역 hook BOM 체크리스트 추가 |
| 2026-06-02 | `docs/PROJECT_WORK_TEMPLATE.md` | 수정 | 프로젝트 hook BOM 체크리스트 추가 |
| 2026-06-02 | `.codex-memory/CHECKLIST.md` | 수정 | `.codex` 삭제 후 복구 점검 완료 항목 추가 |
| 2026-06-02 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 복구 점검 중 수정한 기록 파일 반영 |
| 2026-06-02 | `.codex-memory/QA.md` | 수정 | 대화 삭제 후 파일 상태 확인 결과 추가 |
| 2026-06-02 | `docs/GLOBAL_REDO_CHECKLIST.md` | 생성 | 사용자가 직접 전역 작업을 다시 진행하기 위한 체크리스트 |
| 2026-06-02 | `.codex-memory/CHECKLIST.md` | 수정 | 전역 재설정 체크리스트 작성 완료 반영 |
| 2026-06-02 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 체크리스트 문서 생성 기록 |
| 2026-06-02 | `C:\Users\msk23\.codex\backup-global-redo-20260602-205657\*` | 생성 | 전역 재적용 전 백업 |
| 2026-06-02 | `C:\Users\msk23\.codex\AGENTS.md` | 수정 | 전역 AGENTS 템플릿 적용 |
| 2026-06-02 | `C:\Users\msk23\.codex\config.toml` | 수정 | `[features]`에 `hooks = true`, `multi_agent = true` 추가 |
| 2026-06-02 | `C:\Users\msk23\.codex\hooks.json` | 생성 | 전역 hook 설정 적용 |
| 2026-06-02 | `C:\Users\msk23\.codex\hooks\global_user_prompt_submit.ps1` | 생성 | 전역 UserPromptSubmit hook 적용 |
| 2026-06-02 | `C:\Users\msk23\.codex\hooks\global_session_start.ps1` | 생성 | 전역 SessionStart hook 적용 |
| 2026-06-02 | `.codex-memory/CHECKLIST.md` | 수정 | 전역 재적용 완료 반영 |
| 2026-06-02 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 전역 재적용 파일 목록 기록 |
| 2026-06-02 | `.codex-memory/QA.md` | 수정 | 전역 재적용 검증 결과 기록 |
| 2026-06-02 | `templates/global/hooks/global_user_prompt_submit.ps1` | 수정 | 응답 첫 줄에 hook 읽음 표시를 요구하는 문구 추가 |
| 2026-06-02 | `templates/global/hooks/global_session_start.ps1` | 수정 | 응답 첫 줄에 hook 읽음 표시를 요구하는 문구 추가 |
| 2026-06-02 | `C:\Users\msk23\.codex\hooks\global_user_prompt_submit.ps1` | 수정 | 실제 전역 UserPromptSubmit hook에 읽음 표시 문구 적용 |
| 2026-06-02 | `C:\Users\msk23\.codex\hooks\global_session_start.ps1` | 수정 | 실제 전역 SessionStart hook에 읽음 표시 문구 적용 |
| 2026-06-02 | `.codex-memory/CHECKLIST.md` | 수정 | hook 표시 문구 적용 완료 반영 |
| 2026-06-02 | `.codex-memory/MODIFIED_FILES.md` | 수정 | hook 표시 문구 수정 파일 목록 기록 |
| 2026-06-02 | `.codex-memory/QA.md` | 수정 | hook 표시 문구 검증 결과 기록 |
| 2026-06-04 | `.codex-memory/QA.md` | 수정 | 붙여넣은 텍스트와 템플릿 구조 대조 검증 결과 기록 |
| 2026-06-04 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 이번 대조 확인에서 수정한 기록 파일 목록 반영 |
| 2026-06-04 | `global/*` | 이동 | `templates/global` 전역 템플릿을 루트 `global` 폴더로 이동 |
| 2026-06-04 | `README.md` | 수정 | 전역 템플릿 경로를 루트 `global` 기준으로 갱신 |
| 2026-06-04 | `docs/GLOBAL_WORK_TEMPLATE.md` | 수정 | 전역 템플릿 참조 경로 갱신 |
| 2026-06-04 | `docs/APPLY_GUIDE.md` | 수정 | 전역 적용 안내 경로 갱신 |
| 2026-06-04 | `docs/GLOBAL_REDO_CHECKLIST.md` | 수정 | 전역 재설정 체크리스트 경로 갱신 |
| 2026-06-04 | `.codex-memory/*` | 수정 | 이동 결정, 체크리스트, 수정 파일 기록 반영 |
