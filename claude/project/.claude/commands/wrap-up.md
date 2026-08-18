---
description: 최종 답변 전 검증, QA 기록, 남은 위험을 점검한다.
allowed-tools: Read, Edit, Bash, Task
---

최종 답변 전 다음을 확인한다. 확인하지 않은 항목을 확인한 것처럼 쓰지 않는다.

1. `.claude-memory/MODIFIED_FILES.md` 로 이번 세션 수정 파일을 확인한다.
2. `.claude/verify.toml` 의 검증 명령을 실행한다. 명령이 비어 있으면 프로젝트 실제 명령을 찾아 실행하고, 채워 넣을 값을 제안한다.
3. 실행한 검증과 결과를 `.claude-memory/QA.md` 의 `## 실행한 검증` 표에 기록한다.
4. 실패한 검증은 `## 실패한 검증` 에, 검증하지 못한 항목은 `## 남은 위험` 에 기록한다.
5. `.claude-memory/CHECKLIST.md` 에 미완료 항목이 남았는지 확인한다.
6. 인증/권한/비밀정보 관련 파일을 수정했다면 security-reviewer 서브에이전트를 실행하고 보고를 `## security-reviewer 보고` 아래에 남긴다.
7. 수정 파일이 5건 이상이면 reviewer 서브에이전트로 코드 검토를 받는다.

마지막으로 `수정한 것 / 검증한 것 / 남은 위험` 세 항목으로 보고한다.
