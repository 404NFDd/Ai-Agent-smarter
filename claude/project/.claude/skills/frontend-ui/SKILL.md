---
name: frontend-ui
description: 기존 컴포넌트 패턴, 접근성, 반응형 기준을 지키며 UI를 작업하게 한다. 사용 조건: UI, 화면, 컴포넌트, 버튼, 모달, form, css, layout, responsive, accessibility, color contrast, Playwright, screenshot 작업에 사용한다.
---

# Frontend UI Skill

## 목표

기존 디자인 시스템과 사용자 흐름에 맞는 UI를 만들고, 화면 깨짐과 접근성 회귀를 줄인다.

## 함께 적용하는 스킬

- API 계약이나 오류 표시가 바뀌면 `../backend-api/SKILL.md`를 함께 적용한다.
- 로그인, 권한, 사용자 입력 출력, 민감 정보 표시가 걸리면 `../security/SKILL.md`를 함께 적용한다.
- 날짜, 시간대, 숫자, 통화, 다국어 문구가 바뀌면 `../i18n-time-currency/SKILL.md`를 함께 적용한다.
- UI 동작, 접근성, 브라우저 확인은 `../testing-qa/SKILL.md`로 검증한다.

## 작업 전 확인

- 기존 컴포넌트, 디자인 토큰, spacing, 색상, 아이콘 라이브러리를 확인한다.
- 대상 화면의 모바일과 데스크톱 레이아웃을 함께 고려한다.
- 폼, 모달, 버튼, 키보드 조작처럼 접근성에 영향을 주는 요소인지 확인한다.

## 구현 기준

- semantic HTML을 우선하고, 버튼/링크/폼 컨트롤의 역할을 바꾸지 않는다.
- 입력 필드에는 label 또는 접근 가능한 이름을 제공한다.
- 오류 메시지는 어떤 입력이 잘못됐는지 텍스트로 알 수 있게 한다.
- 모달은 열릴 때 내부로 focus를 이동시키고, 닫힐 때 호출 지점 또는 논리적 위치로 되돌린다.
- `Tab`과 `Shift+Tab` 이동, 닫기 버튼, escape 처리 필요성을 확인한다.
- WCAG 2.2 1.4.3 기준으로 일반 텍스트와 이미지 텍스트 대비는 최소 4.5:1을 목표로 한다.
- 큰 텍스트와 큰 텍스트 이미지는 WCAG 2.2 1.4.3 기준으로 최소 3:1을 목표로 한다.
- 텍스트가 버튼, 카드, 표, 좁은 화면에서 넘치지 않게 한다.

## 금지

- 기존 앱 화면에 맞지 않는 랜딩 페이지식 hero나 장식 요소를 추가하지 않는다.
- 접근성 문제를 `aria-*`만 추가해서 덮지 않는다.
- viewport width에 직접 비례하는 글자 크기를 기본 전략으로 쓰지 않는다.
- 색상만으로 오류, 성공, 선택 상태를 전달하지 않는다.

## 완료 전

- lint 또는 build를 실행한다.
- 가능하면 브라우저, Playwright, 스크린샷 중 하나로 주요 화면을 확인한다.
- keyboard navigation, label/error text, modal focus, 색상 대비 수동 확인이 남으면 `QA.md`에 남긴다.

## 참고 기준

- WCAG 2.2는 키보드 조작, 입력 오류 식별, label 또는 instruction, 1.4.3 Contrast (Minimum)을 기본 접근성 확인 대상으로 둔다.
- W3C WAI-ARIA APG Dialog (Modal) Pattern은 모달 내부 focus 이동과 `Tab`/`Shift+Tab` focus 순환을 설명한다.
