---
name: i18n-time-currency
description: i18n, locale, timezone, date, time, currency, number format, 다국어, 로케일, 시간대, 날짜, 통화 처리 작업에 사용한다.
---

# I18n Time Currency Skill

## 목표

다국어 문구, 시간대, 날짜, 숫자, 통화 처리를 명시적으로 다뤄 지역별 오해와 계산 오류를 줄인다.

## 함께 적용하는 스킬

- 사용자 화면의 문구, 날짜, 숫자, 통화 표시 변경은 `../frontend-ui/SKILL.md`를 함께 적용한다.
- API 요청/응답에 locale, timezone, currency가 들어가면 `../backend-api/SKILL.md`를 함께 적용한다.
- 저장 schema나 query가 바뀌면 `../database-migration/SKILL.md`를 함께 적용한다.
- 고정 clock, locale fixture, 통화 반올림 테스트는 `../testing-qa/SKILL.md`를 함께 적용한다.

## 작업 전 확인

- 값이 저장되는 기준 timezone과 사용자에게 표시되는 timezone을 구분한다.
- 날짜만 필요한지, 특정 시각이 필요한지, 기간/반복 일정인지 확인한다.
- 통화 코드는 금액과 함께 저장/전달되는지 확인한다.
- 숫자, 통화, 날짜 포맷이 locale에 따라 달라지는지 확인한다.

## 구현 기준

- 저장은 가능하면 UTC 또는 도메인에서 합의한 기준으로 하고, 표시 시 사용자 timezone을 적용한다.
- API에는 모호한 지역 시간 문자열보다 timezone 또는 offset이 명확한 값을 사용한다.
- 통화 금액은 floating point 오차를 피하고 minor unit 또는 decimal 타입을 사용한다.
- 통화 변환과 포맷팅은 분리한다.
- 사용자 표시 문구는 하드코딩보다 기존 i18n 체계를 따른다.

## 금지

- 서버 timezone이나 개발자 로컬 timezone에 의존하지 않는다.
- currency code 없이 금액만 저장하거나 전송하지 않는다.
- locale별 소수점, 천 단위 구분, 날짜 순서를 직접 문자열 조합으로 처리하지 않는다.

## 완료 전

- timezone 경계, DST 가능성, locale별 포맷, 통화 반올림 테스트를 확인한다.
- 프로젝트에 i18n 체계가 없으면 남은 위험을 `QA.md`에 기록한다.
