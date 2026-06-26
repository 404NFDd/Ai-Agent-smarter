# PLAN

## 목표

붙여넣은 Codex 운영 시스템 계획서를 바탕으로, 이 프로젝트 폴더를 다른 프로젝트에 복사해 쓸 수 있는 템플릿 프로젝트로 만든다.

## 범위

- 전역 작업 템플릿 작성
- 프로젝트별 작업 템플릿 작성
- memory, skills, hooks, subagents 템플릿 작성
- 적용 가이드 작성
- 현재 작업의 체크리스트와 QA 기록 작성

## 비범위

- 실제 `C:\Users\msk23\.codex` 전역 설정 수정
- Codex 재시작이나 실제 hook 동작 검증
- 특정 개발 프레임워크용 테스트 명령 확정

## 가정

- 이 폴더는 운영 시스템 템플릿 저장소로 사용한다.
- 전역 템플릿은 복사 전 기존 설정과 병합해야 한다.
- 프로젝트 템플릿은 대상 프로젝트의 언어와 프레임워크에 맞게 축소 또는 수정한다.

## 진행 단계

1. 붙여넣은 문서와 현재 폴더 상태 확인
2. 루트 안내 문서 작성
3. 전역 작업 템플릿 작성
4. 프로젝트 작업 템플릿 작성
5. memory, skills, hooks, subagents 템플릿 작성
6. 파일 존재 여부와 문서 구조 검증

## 검증 기준

- `docs/`에 전역/프로젝트 적용 문서가 있다.
- 루트 `global`에 전역 AGENTS, config, hooks 템플릿이 있다.
- `templates/project`에 AGENTS, memory, skills, hooks, subagents 템플릿이 있다.
- `.codex-memory/CHECKLIST.md`와 `.codex-memory/QA.md`가 현재 작업 결과를 기록한다.

## 승인 상태

사용자가 템플릿 작성 요청을 했으므로 구현을 진행한다.

## 2026-06-14 최신 Codex 규약 반영

### 목표

최신 Codex에서 custom agent와 hook 템플릿이 공식 스키마와 이벤트 의미에 맞게 동작하도록 갱신한다.

### 진행 단계

1. custom agent 필수 키와 hook 등록 구조 수정
2. hook 입력 파싱, 출력 스키마, 실행 경로 수정
3. 적용 문서와 작업 memory 갱신
4. 이벤트별 출력과 하위 디렉터리 실행 경로 검증

### 검증 기준

- 모든 custom agent에 `developer_instructions`가 있다.
- 프로젝트 hook JSON과 PowerShell 스크립트가 유효하다.
- 이벤트별 hook 출력이 최신 형식과 일치한다.
- Git 저장소 하위 디렉터리에서도 project hook을 실행할 수 있다.
- 실제 전역 설정과 Codex 설치는 수정하지 않는다.
