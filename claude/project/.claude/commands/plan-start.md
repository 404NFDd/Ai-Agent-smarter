---
description: 승인된 계획을 PLAN / CONTEXT / CHECKLIST 로 저장한다. 구현은 하지 않는다.
argument-hint: [작업 이름]
allowed-tools: Read, Write, Edit
---

계획이 방금 승인됐다. 구현으로 바로 넘어가지 마라.

작업 이름: $1

다음을 순서대로 한다.

1. `.claude-memory/PLAN.md` 를 갱신한다. 목표, 범위, 비범위, 가정, 진행 단계, 검증 기준, 승인 상태를 채운다.
2. `.claude-memory/CONTEXT.md` 를 갱신한다. 이 결정을 왜 했는지, 관련 파일이 어디인지, 제약이 무엇인지 적는다.
3. `.claude-memory/CHECKLIST.md` 를 갱신한다. 진행 단계를 `- [ ] 항목` 으로 쪼갠다. 한 항목은 한 번에 검증 가능한 크기로 만든다.
4. 세 파일 저장이 끝나면 저장한 내용을 3줄로 요약하고 멈춘다.

구현은 다음 지시부터 시작한다. 지금은 문서화만 한다.
