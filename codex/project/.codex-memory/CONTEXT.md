# CONTEXT

## 프로젝트 요약

이 프로젝트는 Codex 기반 AI 운영 시스템을 다른 프로젝트에 적용하기 위한 템플릿 저장소다.

## 참고 문서

- 사용자 첨부 파일: `C:\Users\msk23\.codex\attachments\79b8578e-7716-4660-badb-2c6710fabe1a\pasted-text.txt`
- 루트 안내: `README.md`
- 전역 작업 템플릿: `docs/GLOBAL_WORK_TEMPLATE.md`
- 프로젝트 작업 템플릿: `docs/PROJECT_WORK_TEMPLATE.md`

## 결정 사항과 이유

| 결정 | 이유 |
| --- | --- |
| 실제 전역 설정을 수정하지 않고 루트 `global`에 둔다 | 전역 템플릿은 Codex 자체 전역 기능에 적용되는 자료라 프로젝트 템플릿과 분리해 최상위 폴더에서 관리하기 위함이다. |
| 프로젝트 템플릿은 `templates/project`에 둔다 | 대상 프로젝트에 그대로 복사하기 쉽다. |
| 루트 `.codex-memory`는 이 템플릿 프로젝트 자체의 작업 기록으로 둔다 | AGENTS 지침의 작업 기억 규칙을 현재 작업에도 적용하기 위함이다. |
| hooks 스크립트는 보수적인 예시로 둔다 | 실제 Codex hook payload 구조는 환경에 따라 확인이 필요하다. |

## 제약 조건

- 모든 문서는 한글 중심으로 작성한다.
- 파일 변경은 사용자 요청과 직접 연결된 템플릿 생성에 한정한다.
- Windows PowerShell 기준의 hook 예시를 사용한다.

## 반복해서 주의할 점

- 루트 `global` 템플릿을 실제 전역 설정으로 착각하지 않는다.
- hooks는 적용 후 작은 작업으로 반드시 검증한다.
- Stop hook은 처음부터 과하게 차단하지 않도록 점진적으로 강화한다.

## 2026-06-14 최신 Codex 규약 반영 결정

| 결정 | 이유 |
| --- | --- |
| custom agent의 `instructions`를 `developer_instructions`로 교체한다 | 최신 Codex custom agent 스키마에서 `developer_instructions`가 필수이며 기존 키는 지침으로 인식되지 않을 수 있다. |
| 범용 템플릿에서 `PermissionRequest` hook을 제거한다 | 자동 승인·거부 정책 없이 `PreToolUse` 출력 형식을 재사용하면 이벤트별 출력 스키마가 일치하지 않는다. |
| 프로젝트 Stop hook은 추가 작업이 필요할 때만 `decision: block`을 반환한다 | Stop의 block은 종료 거부가 아니라 새 continuation prompt 생성 의미이며, 통과 시에는 `continue: true`가 공식 형식에 맞다. |
| 전역 Stop hook을 제거한다 | 지원되지 않는 Stop `additionalContext`를 반환했고 모든 프로젝트에 불필요한 continuation을 유발할 위험이 있다. |
| hook 명령은 Git 루트를 기준으로 실행한다 | Codex를 저장소 하위 디렉터리에서 시작해도 `.codex/hooks` 경로를 안정적으로 찾기 위해서다. |
| hook stdin은 이벤트별 JSON 필드만 사용한다 | 전체 payload 문자열 검색의 오탐과 민감 정보 기록 위험을 줄이기 위해서다. |
| JSON 파싱 전에 stdin 선행 BOM을 제거한다 | Windows PowerShell 5.1의 `ConvertFrom-Json`은 선행 UTF-8 BOM 문자를 유효한 JSON 공백으로 처리하지 못하기 때문이다. |
| `hooks`와 `multi_agent` 설정은 선택적 명시 고정값으로 설명한다 | 최신 Codex에서 두 기능은 기본 활성화되어 필수 설정이 아니다. |
