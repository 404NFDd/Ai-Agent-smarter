---
name: dependency-management
description: 의존성 추가와 업그레이드의 영향 범위를 확인하고 lockfile을 안전하게 다루게 한다. 사용 조건: dependency, package, install, lockfile, upgrade, npm, pnpm, yarn, pip, cargo, 패키지, 의존성, 설치, 업그레이드 작업에 사용한다.
---

# Dependency Management Skill

## 목표

필요한 의존성만 추가하고, lockfile과 보안/호환성 영향을 함께 관리한다.

## 함께 적용하는 스킬

- 설치 후 검증은 `../testing-qa/SKILL.md`를 함께 적용한다.
- 보안 취약점이나 secret 관련 패키지는 `../security/SKILL.md`를 함께 적용한다.
- 빌드, 번들 크기 영향은 `../performance/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- 기존 패키지 매니저와 lockfile을 확인한다.
- 이미 설치된 라이브러리나 표준 라이브러리로 해결 가능한지 먼저 본다.
- 새 의존성이 runtime인지 dev/test 전용인지 구분한다.
- 라이선스, 유지보수 상태, 보안 이슈, 번들 크기 영향을 고려한다.

## 구현 기준

- 프로젝트가 사용하는 명령과 lockfile만 변경한다.
- 버전 업그레이드는 변경 범위와 breaking change를 확인한다.
- 의존성 추가 이유가 코드에서 실제로 드러나게 한다.
- 설치가 네트워크를 필요로 하면 실패 시 승인 요청 절차를 따른다.

## 금지

- 여러 패키지 매니저를 섞지 않는다.
- 사용하지 않는 의존성을 추가하지 않는다.
- lockfile 대량 변경을 검토 없이 포함하지 않는다.

## 완료 전

- install, build, test 중 변경 범위에 맞는 검증을 실행한다.
- 추가/업그레이드한 패키지와 이유를 `QA.md` 또는 최종 보고에 남긴다.
