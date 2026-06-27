# 적용 가이드

이 가이드는 템플릿을 실제 프로젝트에 적용할 때의 최소 절차다.

## 전역 적용

1. 기존 전역 파일을 읽는다.
2. 백업 파일을 만든다.
3. `global` 파일을 그대로 덮어쓰지 말고 기존 설정에 병합한다.
4. Codex를 재시작한다.
5. `/hooks`에서 새 hook 정의를 검토하고 신뢰 처리한다.
6. 짧은 요청으로 hook 주입 여부를 확인한다.

최신 Codex에서 `hooks`와 `multi_agent`는 기본 활성화된다. `codex/global/config.features.toml`은 기능을 켜기 위한 필수 파일이 아니라 조직 또는 개인 정책으로 활성 상태를 명시적으로 고정할 때만 사용한다.

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

1. 대상 프로젝트 루트에 `codex/project` 내용을 복사한다.
2. `.codex/verify.toml`의 lint, test, typecheck, build 각 `command`를 대상 프로젝트 실제 명령으로 채운다. 빈 문자열 항목은 건너뛴다.
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

## 전역/프로젝트 hook 우선순위와 중복 회피

- 전역 hook(`codex/global/hooks/*.ps1`, `.sh`)은 범용 안내(한글 응답, memory 확인, 종료 전 위험 확인)만 담당한다. 강제 게이트(block)는 두지 않는다.
- 강제 게이트(계획 게이트, verify 검사 block, 에이전트 보고 마커 게이트)는 프로젝트 hook(`.codex/hooks/*`)에만 둔다.
- 같은 이벤트에 전역/프로젝트 hook이 둘 다 달리면 안내가 중복될 수 있다. 프로젝트 hook 이 더 구체적이면 프로젝트 hook 을 우선한다. 중복 안내가 거슬리면 전역 hook 의 해당 항목을 제거한다.
- 전역 hook 을 켜면 모든 프로젝트에 영향이 가므로, 강제 게이트는 프로젝트 단위로만 도입한다.

## 크로스플랫폼(Windows / Linux·mac)

- hook 은 PowerShell(`.ps1`)과 bash(`.sh`) 양쪽을 제공한다. `hooks.json` 의 `command`(비Windows) 는 `bash *.sh`, `commandWindows` 는 `powershell.exe *.ps1` 이다.
- bash 미러(`.sh`)는 `jq` 가 필요하다. Linux/mac 에서 `jq` 를 설치해야 한다(`apt install jq`, `brew install jq`).
- Windows 에서는 PowerShell 경로만 사용한다. Git Bash 환경은 `jq` 가 보통 없으므로 bash 미러는 Windows 에서 검증하지 않는다.
- bash 미러는 Linux/mac + `jq` 환경에서 리허설이 필요하다(아래 남은 위험 참조).

## 설계 근거

- 이 템플릿의 4대 시스템(자동 매뉴얼 / 작업 기억 / 자동 품질 검사 / 전문 에이전트)의 원래 출처와 설계 의도는 `codex/docs/설계근거.md` 에 있다. 적용 전 한 번 읽으면 각 hook/skill/agent 가 왜 이 구조인지 이해할 수 있다.
