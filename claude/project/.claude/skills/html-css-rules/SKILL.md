---
name: html-css-rules
description: HTML은 의미만, CSS는 표현만 담당하도록 마크업 시맨틱과 CSS 아키텍처 규칙을 적용한다. 사용 조건: HTML, CSS, 마크업, 퍼블리싱, 화면, 컴포넌트, 레이아웃, 스타일, 클래스 이름, 접근성, a11y, WCAG, aria, 시맨틱, @layer, 디자인 토큰, z-index, !important, 선택자, 폼, 버튼, heading, alt, 포커스 작업에 사용한다.
---

# HTML/CSS 작성 규칙

HTML/CSS 작성 시 적용할 실행 규칙이다. 근거, 예제, 예외 판단이 필요하면 `references/html-css-rules.md` 를 읽는다. 이 문서만으로 판단이 서면 참조 문서를 열지 않는다.

참조 문서를 여는 경우:

```text
규칙의 근거를 사람에게 설명해야 할 때
예외를 둘지 판단이 안 설 때
검사기를 구현할 때 (5부)
프로젝트 시작 시 PROJECT 규칙을 확정할 때 (부록)
```

## 표기

```text
[MUST]   예외 없음
[SHOULD] rule-exception 주석으로 사유를 남기면 예외 허용
(HTML)   표준 요구      (WCAG) 접근성 기준 요구      (PROJECT) 프로젝트 결정
```

예외 형식: `rule-exception: <규칙명> -- <사유>` 를 해당 줄 바로 앞에.

## 작업 순서

```text
1. HTML 의미에 맞게 구조를 먼저 결정한다
2. CSS 아키텍처 규칙을 적용한다
3. 검사기를 실행한다
4. MUST 위반은 수정한다
5. SHOULD 위반은 수정하거나 예외를 기록한다
6. 의미 판단 항목만 마지막에 self-review 한다
7. 판단이 애매하면 고치지 말고 사람에게 확인을 요청한다
```

---

## HTML

```text
[MUST] (HTML)    html에 lang. 인코딩 선언은 head 최상단
[MUST] (PROJECT) viewport 선언
[MUST] (HTML)    보이는 main은 1개, 중첩 금지
[MUST] (PROJECT) 스킵 링크를 첫 포커스 요소로. 도착지에 tabindex="-1"
[MUST] (PROJECT) h1은 1개. heading 레벨 순방향 건너뛰기 금지
[MUST] (PROJECT) 크기를 이유로 heading 레벨을 고르지 않는다
[MUST] (WCAG)    heading과 label이 실제 내용/목적을 설명한다
[MUST] (HTML)    모든 img에 alt. 장식용은 alt=""
[MUST] (WCAG)    모든 폼 컨트롤에 접근 가능한 이름
[MUST] (PROJECT) form 안 button에 type 명시
[MUST] (HTML)    주소 이동은 a, 동작 실행은 button. div[onclick] 금지
[MUST] (HTML)    address는 문서/article 작성자 연락처 전용. 일반 주소는 p
[MUST] (HTML)    font, center 금지
[MUST] (PROJECT) 레이아웃 목적 table 금지 (HTML 메일 제외)

[SHOULD] (HTML)  반복 항목은 ul/ol/li, 데이터는 table+th[scope]
[SHOULD] (HTML)  section은 독립 주제 묶음에만. 단순 컨테이너는 div
[SHOULD] (HTML)  figure는 본문에서 독립 단위로 참조되는 것에만
[SHOULD] (HTML)  fieldset+legend는 묶음 자체가 의미를 갖는 그룹에만
[SHOULD] (PROJECT) 인라인 style 금지. 단 JS 계산 값 주입은 예외
```

**b / i 는 금지가 아니다.** 중요성은 `strong`, 어조는 `em`, 장식은 CSS. 주의를 끄는 키워드는 `b`, 학명/외국어/다른 화자는 `i`.

**아이콘 버튼 형태 고정**

```html
<button type="button">
  <span class="icon_search" aria-hidden="true"></span>  <!-- 그림만 -->
  <span class="sr_only">검색</span>                      <!-- 의미만 -->
</button>
```

**재사용 컴포넌트의 heading 레벨은 파라미터로 받는다.** 하드코딩하면 건너뛰기 금지 규칙과 충돌한다.

---

## CSS

### 층 (전역 @layer를 선택한 경우)

```css
@layer overrides, reset, vendor, tokens, layout, component, utility, state;
```

```text
[MUST] (PROJECT) 모든 프로젝트 CSS는 층 안에. 층 밖 규칙 금지
[MUST] (PROJECT) !important는 overrides 층에서만
```

이유: 일반 선언은 뒤 층이 이기고 `!important`는 앞 층이 이긴다. 층 밖 일반 선언은 층 안 모든 일반 선언을 이긴다. vendor를 앞에 둬야 일반 선언을 쉽게 덮고, overrides를 맨 앞에 둬야 vendor의 `!important`를 덮는다.

CSS Modules나 Tailwind를 선택했으면 이 절은 적용하지 않는다.

### 나머지

```text
[SHOULD] (PROJECT) 이름은 역할 기반. 모양/위치/값 기반 금지
                   .red_title X  .left_box X  .mt_20 X
[SHOULD] (PROJECT) 색상은 --color-* 역할 토큰만. --palette-* 직접 참조 금지
[SHOULD] (PROJECT) 간격/모서리/글자크기는 공용 스케일 토큰 직접 사용 가능
[SHOULD] (PROJECT) 선택자는 이름 기반. 결합 깊이 3단 이하. ID 선택자 금지
[SHOULD] (PROJECT) 컴포넌트 사이 z-index만 토큰화. 내부 겹침은 리터럴 허용
```

### 배치 책임

> 컴포넌트는 외부 배치를 결정하지 않는다. 내부 레이아웃은 결정한다.

```text
컴포넌트 루트에서 금지
  외부 margin / 페이지 기준 absolute,fixed
  주변을 가정한 width,height / 전역 z-index

컴포넌트 내부에서 허용
  내부 여백 / 내부 absolute / 아이콘,아바타 고정 크기 / 내부 z-index
```

컴포넌트 사이 간격은 부모가 `gap`으로 준다.

### 상태

```text
A. 접근성 의미가 있는 상태  [MUST] (WCAG)
   네이티브/ARIA 속성을 정확한 요소에 쓰고, CSS는 그 속성을 선택한다.
   aria-expanded는 트리거 버튼에. 패널에 붙이지 않는다.
   같은 상태를 클래스로 중복 관리하지 않는다.

B. 앱 내부 상태  [SHOULD] (PROJECT)
   대응 ARIA 속성이 없으면 .is_loading, [data-state="..."] 사용.
   없는 aria-* 를 만들어 쓰지 않는다.

C. 포커스  [MUST] (WCAG)
   :focus-visible 우선. 요구사항은 키보드 포커스의 가시성이다.
   outline: none만 쓰고 대체 스타일이 없으면 위반.
```

```html
<button class="accordion_trigger" aria-expanded="false" aria-controls="panel-1">
  배송 정보
</button>
<div id="panel-1" class="accordion_panel" hidden>...</div>
```

---

## 작성 후 self-review (검사기가 못 잡는 항목)

```text
alt="" 인 이미지가 정말 장식용인가
heading이 뒤따르는 내용을 설명하는가
label이 입력의 목적을 설명하는가
이 UI가 이동인가 실행인가 (a / button)
section, article, address, figure가 의미에 맞는가
클래스 이름이 역할을 가리키는가
선택자 깊이 초과가 진입점 클래스 안에 갇혀 있는가
```

애매한 항목은 **수정하지 말고 확인을 요청한다.** 확신 없이 고치면 원래 의도를 잃는다.
