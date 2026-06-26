# 적용 가이드

이 가이드는 템플릿을 실제 프로젝트에 적용할 때의 최소 절차다.

## 전역 적용

1. 기존 전역 파일을 읽는다.
2. 백업 파일을 만든다.
3. `global` 파일을 그대로 덮어쓰지 말고 기존 설정에 병합한다.
4. Codex를 재시작한다.
5. `/hooks`에서 새 hook 정의를 검토하고 신뢰 처리한다.
6. 짧은 요청으로 hook 주입 여부를 확인한다.

최신 Codex에서 `hooks`와 `multi_agent`는 기본 활성화된다. `global/config.features.toml`은 기능을 켜기 위한 필수 파일이 아니라 조직 또는 개인 정책으로 활성 상태를 명시적으로 고정할 때만 사용한다.

PowerShell hook 주의:

- `.ps1` 파일은 UTF-8 with BOM으로 저장한다.
- hook 명령은 Windows 기본 호환성을 위해 `powershell.exe`를 사용한다.
- 각 `.ps1` 상단의 UTF-8 콘솔 설정을 유지한다.

권장 순서:

```text
1. 전역 AGENTS.md 병합
2. config.toml features 확인
3. UserPromptSubmit hook 테스트
4. SessionStart hook 추가
```

## 프로젝트 적용

1. 대상 프로젝트 루트에 `templates/project` 내용을 복사한다.
2. `templates/project/AGENTS.md`의 검증 명령 예시를 실제 명령으로 바꾼다.
3. 필요 없는 skill은 삭제하지 말고 처음에는 비활성 메모를 남긴다.
4. hooks payload 구조가 다르면 `post_tool_use.ps1`을 debug 모드로 낮춰 조정한다.
5. 대상 프로젝트를 trusted project로 등록한다.
6. `/hooks`에서 프로젝트 hook 정의를 검토하고 신뢰 처리한다.
7. 작은 문서 수정으로 리허설한다.

프로젝트 hook의 `.ps1` 파일도 UTF-8 with BOM으로 저장한다. Windows PowerShell 5.1은 BOM 없는 UTF-8 파일의 한글을 ANSI로 오해할 수 있다.
프로젝트 hook은 Git 저장소 루트를 기준으로 실행되므로 대상 프로젝트는 Git 저장소여야 한다.

## 작업 시작 프롬프트 템플릿

hooks가 동작하지 않을 때 사용할 수동 프롬프트다.

```text
이 작업은 Codex 운영 시스템 방식으로 진행해.

1. AGENTS.md를 확인해.
2. 관련 skill을 확인해.
3. .codex-memory/PLAN.md, CONTEXT.md, CHECKLIST.md를 확인해.
4. 큰 작업이면 먼저 계획만 작성하고 구현하지 마.
5. 내가 승인하면 CHECKLIST 단위로 구현해.
```

## 작업 종료 프롬프트 템플릿

```text
최종 답변 전에 다음을 확인해.

1. 수정 파일 목록
2. CHECKLIST.md 갱신 여부
3. QA.md 갱신 여부
4. 테스트/검증 실행 결과
5. 남은 위험
6. reviewer 검토 필요 여부
```

## 주의

- 전역 설정은 모든 프로젝트에 영향을 준다.
- 프로젝트 Stop hook의 `decision: block`은 종료 거부가 아니라 Codex에 추가 작업을 계속 요청한다.
- 전역 Stop hook은 모든 프로젝트의 종료를 반복시킬 수 있으므로 기본 템플릿에서 제공하지 않는다.
- hook 실패가 반복되면 hooks보다 memory, skill, 수동 프롬프트를 우선한다.
