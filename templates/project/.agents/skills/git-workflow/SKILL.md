---
name: git-workflow
description: git, branch, commit, PR, push, dirty worktree, 변경 파일 보호, 브랜치, 커밋, 푸시 요청이나 삭제/되돌리기 전 확인에 사용한다.
---

# Git Workflow Skill

## 목표

사용자 변경을 보호하면서 필요한 git 작업만 수행한다.

## 함께 적용하는 스킬

- 커밋 전 검증은 `../testing-qa/SKILL.md`를 함께 적용한다.
- 릴리즈 브랜치, tag, push는 `../release-deploy/SKILL.md`를 함께 적용한다.
- 변경 리뷰가 필요하면 `../review/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- `git status --short`로 현재 변경 상태를 확인한다.
- 내 변경과 사용자 변경을 구분한다.
- 같은 파일에 기존 변경이 있으면 diff를 읽고 함께 작업한다.

## 브랜치 기준

- 새 브랜치가 필요하면 기본 prefix는 `codex/`를 사용한다.
- 사용자가 지정한 브랜치명이나 전략이 있으면 그것을 따른다.
- 브랜치 변경 전 uncommitted 변경이 충돌할 가능성을 확인한다.

## 커밋 기준

- 사용자가 요청했을 때만 stage/commit/push를 수행한다.
- 관련 파일만 stage한다.
- 커밋 메시지는 변경의 목적과 범위를 짧게 설명한다.

## 금지

- 명시 요청 없이 `git reset --hard`, `git checkout --`, 강제 push를 하지 않는다.
- 사용자 변경으로 보이는 파일을 되돌리지 않는다.
- unrelated 변경을 커밋에 섞지 않는다.

## 완료 전

- `git diff` 또는 `git status`로 의도한 변경만 남았는지 확인한다.
