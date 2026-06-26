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
| 2026-06-04 | `global/hooks/global_user_prompt_submit.ps1` | 수정 | 전역 운영 지침 문구 추가 |
| 2026-06-04 | `global/hooks/global_session_start.ps1` | 수정 | 전역/프로젝트 hook 역할 분리 안내 추가 |
| 2026-06-04 | `.codex-memory/CHECKLIST.md` | 수정 | 전역 hook 운영 지침 추가 완료 반영 |
| 2026-06-04 | `.codex-memory/QA.md` | 수정 | 전역 hook 운영 지침 검증 항목 추가 |
| 2026-06-04 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 이번 수정 파일 목록 반영 |
| 2026-06-04 | `global/hooks/global_user_prompt_submit.ps1` | 수정 | 설명용 표현을 제거하고 중립 표현으로 정리 |
| 2026-06-04 | `global/hooks.json` | 수정 | 전역 hook을 UserPromptSubmit, SessionStart, PostToolUse, Stop으로 분리 |
| 2026-06-04 | `global/hooks/global_user_prompt_submit.ps1` | 수정 | 요청 시작 지침만 남기도록 축소 |
| 2026-06-04 | `global/hooks/global_session_start.ps1` | 수정 | 세션 시작 memory 확인만 남기도록 축소 |
| 2026-06-04 | `global/hooks/global_post_tool_use.ps1` | 생성 | 도구 사용 후 기록 확인 hook 추가 |
| 2026-06-04 | `global/hooks/global_stop_check.ps1` | 생성 | 종료 전 검증/위험 확인 hook 추가 |
| 2026-06-04 | `.codex-memory/CHECKLIST.md` | 수정 | 이벤트별 hook 분리 완료 반영 |
| 2026-06-04 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 이벤트별 hook 분리 수정 파일 목록 반영 |
| 2026-06-04 | `docs/GLOBAL_WORK_TEMPLATE.md` | 수정 | 새 전역 hook 스크립트 목록 반영 |
| 2026-06-04 | `docs/GLOBAL_REDO_CHECKLIST.md` | 수정 | 새 전역 hook 복사/검증 항목 반영 |
| 2026-06-04 | `.codex-memory/QA.md` | 수정 | 이벤트별 전역 hook 분리 검증 결과 반영 |
| 2026-06-04 | `templates/project/.agents/skills/*/SKILL.md` | 생성/정리 | 필수/추가 skill 목록 기준으로 빈 SKILL.md 구성 |
| 2026-06-04 | `templates/project/.codex/hooks.json` | 수정 | PreToolUse, PermissionRequest 추가 및 matcher 조정 |
| 2026-06-04 | `templates/project/.codex/hooks/user_prompt_submit.ps1` | 수정 | 새 skill 목록 기준 라우팅으로 갱신 |
| 2026-06-04 | `templates/project/.codex/hooks/pre_tool_use.ps1` | 생성 | 위험 작업 전 관련 skill 확인 hook 추가 |
| 2026-06-04 | `docs/PROJECT_WORK_TEMPLATE.md` | 수정 | 새 skill 목록과 pre_tool_use hook 반영 |
| 2026-06-04 | `.codex-memory/CHECKLIST.md` | 수정 | 프로젝트 skill/hook 갱신 완료 반영 |
| 2026-06-04 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 프로젝트 skill/hook 갱신 파일 목록 반영 |
| 2026-06-04 | `.codex-memory/QA.md` | 수정 | 프로젝트 skill/hook 갱신 검증 결과 반영 |
| 2026-06-04 | `templates/project/.agents/skills/*/SKILL.md` | 수정 | 18개 skill에 frontmatter와 절차형 실행 매뉴얼 본문 추가 |
| 2026-06-04 | `.codex-memory/CHECKLIST.md` | 수정 | 프로젝트 skill 본문 추가 완료 반영 |
| 2026-06-04 | `.codex-memory/MODIFIED_FILES.md` | 수정 | 프로젝트 skill 본문 추가 파일 목록 반영 |
| 2026-06-04 | `.codex-memory/QA.md` | 수정 | 프로젝트 skill 본문 추가 검증 결과 반영 |
| 2026-06-04 | `templates/project/.agents/skills/backend-api/SKILL.md` | 수정 | RFC 9457 표준 멤버, extension member, 리소스 제한, security 위임 기준 반영 |
| 2026-06-04 | `templates/project/.agents/skills/frontend-ui/SKILL.md` | 수정 | WCAG 2.2 색상 대비와 W3C APG modal pattern 기준 보강 |
| 2026-06-04 | `templates/project/.agents/skills/testing-qa/SKILL.md` | 수정 | 테스트 피라미드 출처 일반화, fixture/secret 분리 기준 추가 |
| 2026-06-04 | `templates/project/.agents/skills/security/SKILL.md` | 수정 | 입력 검증, 객체 단위 권한, secret 비노출 단일 기준과 testing 연계 추가 |
| 2026-06-04 | `templates/project/.agents/skills/*/SKILL.md` | 수정 | 모든 skill에 `함께 적용하는 스킬` 연계 섹션 추가 또는 보강 |
| 2026-06-04 | `templates/project/.agents/skills/resilience/SKILL.md` | 생성 | timeout, retry, idempotency, rate limit, quota 매뉴얼 추가 |
| 2026-06-04 | `templates/project/.agents/skills/i18n-time-currency/SKILL.md` | 생성 | i18n, timezone, date, currency 매뉴얼 추가 |
| 2026-06-04 | `templates/project/.codex/hooks/user_prompt_submit.ps1` | 수정 | resilience, i18n-time-currency, contrast, fixture, resource consumption 라우팅 추가 |
| 2026-06-04 | `templates/project/.codex/hooks/pre_tool_use.ps1` | 수정 | resilience, i18n-time-currency 위험 작업 전 skill 후보 추가 |
| 2026-06-04 | `docs/PROJECT_WORK_TEMPLATE.md` | 수정 | 새 skill 2개와 skill 연계 체크리스트 반영 |
| 2026-06-04 | `.codex-memory/*` | 수정 | 이번 피드백 반영의 결정, 체크리스트, 수정 파일, QA 기록 추가 |
| 2026-06-14 | `templates/project/.codex/agents/*.toml` | 수정 | 최신 custom agent 필수 키 `developer_instructions` 반영 |
| 2026-06-14 | `templates/project/.codex/hooks.json` | 수정 | PermissionRequest 제거 및 Git 루트 기준 hook 명령 반영 |
| 2026-06-14 | `templates/project/.codex/hooks/*.ps1` | 수정 | 구조화된 입력 처리와 이벤트별 공식 출력 형식 반영 |
| 2026-06-14 | `global/hooks.json`, `global/hooks/global_stop_check.ps1` | 수정/삭제 | 지원되지 않는 전역 Stop hook 제거 |
| 2026-06-14 | `global/config.features.toml`, `docs/*.md` | 수정 | 기본 활성 feature, hook trust, 경로 및 Stop 의미 안내 반영 |
| 2026-06-14 | `.codex-memory/*` | 수정 | 변경 이유, 완료 항목, 수정 파일과 QA 결과 기록 |
