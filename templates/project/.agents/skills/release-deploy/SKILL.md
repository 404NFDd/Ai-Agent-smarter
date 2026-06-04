---
name: release-deploy
description: release, deploy, version, tag, publish, rollback, 배포, 릴리즈, 버전, 태그, 롤백 작업에 사용한다.
---

# Release Deploy Skill

## 목표

릴리즈와 배포 변경이 검증, migration, 설정, rollback 관점에서 빠짐없이 준비되게 한다.

## 작업 전 확인

- 배포 대상 환경, 브랜치, 버전 정책, CI/CD 흐름을 확인한다.
- migration, feature flag, 환경 변수, secret 변경이 포함되는지 확인한다.
- backward compatibility와 rollback 가능성을 확인한다.

## 릴리즈 전 체크

- 테스트, lint, typecheck, build 상태를 확인한다.
- 변경 로그나 릴리즈 노트가 필요한지 확인한다.
- DB migration은 배포 순서와 실패 시 조치를 확인한다.
- 새 환경 변수나 secret은 문서화하되 값을 기록하지 않는다.

## 금지

- 검증 실패를 숨기고 배포 완료로 보고하지 않는다.
- rollback 경로가 없는 destructive 변경을 가볍게 진행하지 않는다.
- 사용자 승인 없이 publish, push, tag 생성 같은 외부 상태 변경을 하지 않는다.

## 완료 전

- 실행한 배포/릴리즈 명령과 결과를 `QA.md`에 기록한다.
- 남은 수동 확인과 rollback 위험을 최종 보고에 포함한다.
