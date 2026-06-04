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
