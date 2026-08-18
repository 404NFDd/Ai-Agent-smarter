# HTML/CSS 작성 규격서

이 문서는 **근거와 예외까지 담은 원본 규격서**다. 에이전트에게 매번 넣는 용도가 아니다.
실행용 축약본은 `agent-rules.md`를 쓴다.

---

## 0. 전제

두 언어의 역할은 겹치지 않는다.

| 언어 | 답하는 질문 | 답하면 안 되는 질문 |
|---|---|---|
| HTML | 이것은 무엇인가 | 어떻게 보이는가 |
| CSS | 어떻게 보이는가 | 이것은 무엇인가 |

CSS가 난잡해지는 원인의 대부분은 이 경계가 무너진 결과다. HTML이 의미를 안 담으면 CSS가 그 부족분을 클래스로 메우고, 그 클래스가 다시 서로 충돌한다.

---

## 0.1 규칙 표기

모든 규칙에 **세 개의 축**이 붙는다. 하나의 라벨에 여러 의미를 섞지 않는다.

### 축 1 — Severity (강제 수준)

| 값 | 의미 |
|---|---|
| `MUST` | 예외 없음. 위반은 무조건 수정 |
| `SHOULD` | 사유를 남기면 예외 허용 |

### 축 2 — Source (근거의 출처)

| 값 | 의미 |
|---|---|
| `HTML` | HTML 표준이 요구하거나, 어기면 동작이 달라진다 |
| `WCAG` | 접근성 기준이 직접 요구한다 |
| `PROJECT` | 표준이 강제하지는 않지만 이 프로젝트에서 정했다 |

`MUST / PROJECT`가 존재한다. "표준상 필수는 아니지만 우리는 무조건 지킨다"를 정확히 표현하기 위해서다. 이걸 `MUST / WCAG`로 적으면 에이전트가 근거를 오해한다.

### 축 3 — 검증 방식

| 값 | 판정 주체 |
|---|---|
| `[기계]` | 파서 기반 검사기 |
| `[의미]` | 사람 또는 에이전트의 문맥 판단 |
| `[기계+의미]` | 검사기가 의심 패턴을 잡고, 최종 판단은 사람이 한다 |

`alt=""`가 존재한다는 사실만으로는 그 이미지가 정말 장식용인지 알 수 없다. 존재 검사와 적합성 검사는 다른 작업이다.

## 0.2 예외 표기

`SHOULD`를 어겨야 할 때는 지우지 말고 사유를 남긴다.

```css
/* rule-exception: no-important -- 서드파티 결제 위젯의 인라인 스타일 덮어쓰기 */
.payment_wrap .vendor_btn { color: var(--color-text-default) !important; }
```

```html
<!-- rule-exception: no-inline-style -- JS가 계산한 진행률을 CSS 변수로 주입 -->
<div class="progress" style="--progress: 60%"></div>
```

형식은 `rule-exception: <규칙 이름> -- <사유>`. 사유가 한 줄로 안 써지면 그건 예외가 아니라 실수다.

주석은 해당 선언 또는 규칙 **바로 앞 줄**에 둔다. 검사기가 위치로 연결하기 때문이다.

## 0.3 적용 범위

페이지 전체 문서와 재사용 컴포넌트에 같은 규칙을 무조건 적용하면 에이전트가 컴포넌트 안에 `main`, 스킵 링크, `h1`을 만들 수 있다. 그래서 실행 시 적용 범위를 따로 구분한다.

| 값 | 적용 대상 |
|---|---|
| `DOCUMENT` | 전체 HTML 문서 또는 페이지 셸 |
| `COMPONENT` | 재사용 컴포넌트, partial, 조각 마크업 |
| `ALL` | 둘 다 |

문서 골격(`lang`, `charset`, `viewport`, 대표 `h1`, 스킵 링크, 단일 `main`)은 `DOCUMENT`에만 적용한다. 콘텐츠 의미, 폼 접근성, 이미지 대체 텍스트, `a`/`button` 구분 등은 `ALL`에 적용한다. 재사용 컴포넌트의 heading 레벨은 페이지 문맥에 따라 달라지므로 호출자가 결정할 수 있게 한다.

## 0.4 프로젝트 프로파일

`PROJECT` 규칙 중 선택지가 있는 항목은 에이전트가 작업마다 다시 고르지 않는다. 프로젝트 시작 시 사람이 한 번 확정한다.

```text
CSS_ISOLATION = <global-layer | css-modules | tailwind>
UTILITY_STYLE = <allow | disallow>
JS_HOOK = <class-prefix | ref | data-attribute | data-testid>
H1_POLICY = <exactly-one | project-defined>
COLOR_TOKEN = <two-tier | three-tier>
VALIDATE_HTML = <project-defined command | none>
VALIDATE_CSS = <project-defined command | none>
```

값이 비어 있으면 에이전트는 기존 코드, 설정 파일, package scripts에서 현재 방식을 확인한다. 확인 가능한 기존 방식이 있으면 그대로 따른다. 그래도 판정할 수 없으면 새 아키텍처를 임의로 도입하지 않고 기존 구조를 유지한다.

## 0.5 기존 코드 수정 원칙

새 코드를 처음부터 만드는 규칙과 기존 코드에 손대는 규칙은 다르다. 기존 코드 수정 시에는 아래 행동 규칙을 먼저 적용한다.

```text
[MUST] 새 패턴을 만들기 전에 인접한 기존 HTML/CSS와 프로젝트 설정을 확인한다.
[MUST] 기존 네이밍, 토큰, 레이어/모듈, 컴포넌트 구조를 우선한다.
[MUST] 요청받지 않은 리팩터링을 하지 않는다.
[MUST] 작업에 필요하지 않은 클래스명, DOM 구조, 파일 구조를 바꾸지 않는다.
[MUST] 기존 토큰/컴포넌트/유틸로 표현 가능하면 같은 역할의 새 항목을 만들지 않는다.
[SHOULD] 변경 범위는 요청을 만족하는 최소 범위로 제한한다.
```

의미가 불명확해 수정하면 원래 의도가 바뀔 가능성이 있는 항목은 임의로 고치지 않는다. 가능한 작업은 완료하고, 남은 항목만 결과에 `확인 필요`로 기록한다.

---

# 1부. HTML 규칙

## 1.1 문서 골격

> 적용 범위: `DOCUMENT`. 재사용 컴포넌트에는 이 문서 골격 규칙을 직접 적용하지 않는다.

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <!-- 인코딩 선언: 문서 첫 1024바이트 안에 들어가야 한다.
       head 최상단에 두는 것은 그 조건을 확실히 만족시키기 위한 관행이다. -->
  <meta charset="utf-8">

  <!-- 뷰포트: 좁은 화면에서 콘텐츠가 리플로우되게 한다.
       WCAG는 이 태그가 아니라 "리플로우되는 결과"를 요구한다. -->
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- 제목: 탭, 히스토리, 검색 결과에 노출된다. 페이지마다 달라야 한다. -->
  <title>페이지마다 다른 제목</title>
</head>
```

| 규칙 | Severity | Source | 검증 |
|---|---|---|---|
| `html`에 `lang` | MUST | WCAG | 기계 |
| 인코딩 선언이 첫 1024바이트 안 | MUST | HTML | 기계 |
| `charset`을 `head` 최상단에 | MUST | PROJECT | 기계 |
| `viewport` 선언 | MUST | PROJECT | 기계 |
| `title`이 페이지마다 다름 | MUST | PROJECT | 의미 |

`charset` 최상단과 `viewport`가 `PROJECT`인 이유는 표준이 그 형태를 강제하지 않기 때문이다. 표준의 제약은 각각 "첫 1024바이트 안"과 "리플로우되는 결과"다. 규칙을 버리지는 않되 근거를 정확히 적는다.

## 1.2 영역 구분

```html
<body>
  <!-- 스킵 링크: 반복되는 헤더를 건너뛴다. 첫 포커스 요소여야 의미가 있다. -->
  <a class="skip_link" href="#main">본문 바로가기</a>

  <header>
    <!-- nav: 주요 내비게이션에만 사용. 링크 묶음이라고 다 nav가 아니다. -->
    <nav>...</nav>
  </header>

  <!-- main: 이 페이지에만 있는 내용. 화면에 보이는 것은 1개.
       tabindex="-1" 이 없으면 스킵 링크로 이동해도 포커스가 헤더에 남는다. -->
  <main id="main" tabindex="-1">
    ...
  </main>

  <footer>...</footer>
</body>
```

| 규칙 | Severity | Source | 검증 |
|---|---|---|---|
| 화면에 보이는 `main`은 1개 | MUST | HTML | 기계 |
| `main`을 중첩하지 않음 | MUST | HTML | 기계 |
| 반복 블록을 우회할 수단이 있음 | MUST | WCAG | 기계+의미 |
| 그 수단으로 스킵 링크를 쓰고 첫 포커스 요소로 둠 | MUST | PROJECT | 기계 |
| `nav`는 주요 내비게이션에만 | SHOULD | HTML | 의미 |
| `article`은 떼어내도 말이 되는 단위에 | SHOULD | HTML | 의미 |

**스킵 링크의 근거 구분.** WCAG 2.4.1이 요구하는 것은 반복 블록을 **우회할 수단**이지 스킵 링크라는 특정 구현이 아니다. 랜드마크 구조도 기법 중 하나다. 다만 랜드마크는 스크린리더 사용자에게만 작동하고, Tab 키만 쓰는 사용자에게는 수단이 없다. 그래서 스킵 링크를 프로젝트 필수로 정한다.

**`section` — SHOULD / HTML / 의미**

```text
독립적으로 식별 가능한 주제 묶음에 사용한다.
일반적으로 heading을 가진다.
스타일링이나 스크립팅만을 위한 컨테이너라면 div를 쓴다.
```

## 1.3 제목 계층

| 규칙 | Severity | Source | 검증 |
|---|---|---|---|
| 크기를 이유로 레벨을 고르지 않음 | MUST | PROJECT | 의미 |
| heading이 뒤따르는 내용을 설명함 | MUST | WCAG | 의미 |
| 레벨을 순방향으로 건너뛰지 않음 | MUST | PROJECT | 기계 |
| 페이지 대표 제목은 `h1` 하나 (`H1_POLICY=exactly-one`) | MUST | PROJECT | 기계 |

레벨 건너뛰기와 `h1` 단일은 둘 다 `PROJECT`다. HTML 표준은 여러 최상위 heading을 허용하고, W3C 문서도 레벨 건너뛰기에 대해 "가능하면 피하라"에 가깝게 쓴다. 표준 위반은 아니지만 에이전트에게 선택지를 줄이면 구조가 일관되므로 프로젝트에서 강제한다. 단, `h1` 정책은 프로젝트 프로파일의 `H1_POLICY`를 따른다.

**재사용 컴포넌트의 레벨 처리 — COMPONENT**

컴포넌트 내부에서 페이지 계층을 추측해 `h2`/`h3`를 고정하지 않는다. 호출자가 heading 레벨을 주입하거나 주변 문맥에서 결정할 수 있게 한다.

```jsx
// 카드를 어디에 꽂느냐에 따라 h2가 맞을 수도 h3가 맞을 수도 있다.
// 레벨을 하드코딩하면 "건너뛰지 마라" 규칙과 충돌해 재사용이 불가능해진다.
function Card({ as: Heading = 'h3', title }) {
  return (
    <article>
      <Heading className="card_title">{title}</Heading>
    </article>
  );
}
```

화면에 제목을 안 보이게 하려면 태그는 유지하고 시각적으로만 숨긴다.

```html
<!-- 스크린리더에는 읽히고 화면에는 안 보인다. 문서 구조를 유지하기 위한 것. -->
<h2 class="sr_only">추천 상품</h2>
```

## 1.4 콘텐츠 의미

| 내용 | 태그 | Severity | Source |
|---|---|---|---|
| 반복되는 항목 | `ul` / `ol` + `li` | SHOULD | HTML |
| 이름과 값의 쌍 | `dl` + `dt` + `dd` | SHOULD | HTML |
| 행과 열의 데이터 | `table` + `caption` + `th[scope]` | SHOULD | HTML |
| 날짜, 시간 | `<time datetime="...">` | SHOULD | HTML |
| 의미상 중요 | `strong` | SHOULD | HTML |
| 어조 강조 | `em` | SHOULD | HTML |

**`address`는 주소 태그가 아니다 — MUST / HTML / 의미**

```html
<!-- 맞음: 문서 또는 가장 가까운 article의 작성자/소유자 연락처 -->
<footer>
  <address>문의: <a href="mailto:help@example.com">help@example.com</a></address>
</footer>

<!-- 틀림: 배송지, 매장 주소, 회사 소재지는 address가 아니다 -->
<p>서울시 강남구 ...</p>
```

**`figure`는 독립 단위에만 — SHOULD / HTML / 의미**

```text
본문에서 하나의 독립적인 단위로 참조되는 이미지/도표/코드
  -> figure + 선택적 figcaption

본문 문장의 일부인 이미지
  -> img 단독
```

**레이아웃 목적의 `table` — MUST / PROJECT / 기계+의미**

금지한다. 단 HTML 메일은 예외다. 메일 클라이언트가 Flexbox를 지원하지 않는다.

## 1.5 조작 요소

**`a`와 `button`의 구분 — MUST / HTML / 기계+의미**

```html
<!-- a: 주소가 바뀐다. 새 탭 열기, 북마크, 히스토리가 동작한다. -->
<a href="/mypage">마이페이지</a>

<!-- button: 주소는 그대로, 동작만 실행된다. -->
<button type="button">저장</button>
```

검사기가 잡을 수 있는 것은 **의심 패턴**뿐이다.

```text
기계가 잡는 것
  div[onclick], span[onclick]
  href 없는 a
  role="button"이 붙은 div

기계가 못 잡는 것
  이 UI가 "이동"인지 "실행"인지
  -> 최종 판단은 의미 검토에서 한다
```

`div`에 `onclick`을 붙이면 아래를 전부 직접 구현해야 한다.

| 잃는 것 | 복구에 필요한 것 |
|---|---|
| 키보드 포커스 | `tabindex="0"` |
| Enter / Space 실행 | `keydown` 핸들러 |
| 보조기기 역할 인식 | `role="button"` |
| 비활성 상태 | `aria-disabled` + 클릭 차단 |
| 폼 제출/리셋 연동 | JS로 직접 처리 |

**폼**

| 규칙 | Severity | Source | 검증 |
|---|---|---|---|
| 모든 폼 컨트롤에 접근 가능한 이름 | MUST | WCAG | 기계 |
| 라벨 텍스트가 입력의 목적을 설명 | MUST | WCAG | 의미 |
| `button`에 `type` 명시 | MUST | PROJECT | 기계 |
| 텍스트 입력은 `label[for]`로 명시 연결 | SHOULD | PROJECT | 기계 |
| `type`을 정확히 사용 | SHOULD | PROJECT | 의미 |
| 그룹에 `fieldset` + `legend` | SHOULD | HTML | 의미 |

```html
<!-- 라벨이 시각적으로 필요 없는 경우: aria-label로 이름을 준다.
     placeholder는 입력을 시작하면 사라지므로 라벨을 대신할 수 없다. -->
<input type="search" aria-label="상품 검색" placeholder="검색어 입력">

<!-- 라디오/체크박스처럼 묶음 자체가 의미를 갖는 경우에만 fieldset을 쓴다.
     모든 폼에 씌우면 스크린리더가 legend를 매 입력마다 반복해 읽는다. -->
<fieldset>
  <legend>배송 방법</legend>
  <label><input type="radio" name="ship" value="std"> 일반</label>
  <label><input type="radio" name="ship" value="exp"> 특급</label>
</fieldset>
```

`button[type]`이 `PROJECT`인 이유는 HTML이 생략 시 동작(`submit`)을 정의하고 있기 때문이다. 표준 위반이 아니라 **의도치 않은 폼 제출을 막기 위한 안전 규칙**이다.

"모든 `input`에 `label`"은 오탐이 난다. `<input type="submit" value="저장">`은 값 자체가 이름이다. 검사 항목은 **접근 가능한 이름의 존재**여야 한다.

## 1.6 이미지

| 규칙 | Severity | Source | 검증 |
|---|---|---|---|
| 모든 `img`에 `alt` 속성 존재 | MUST | HTML | 기계 |
| `alt` 내용이 이미지 역할과 일치 | MUST | WCAG | 의미 |

```html
<!-- 의미 있는 이미지: 내용을 설명한다 -->
<img src="chart.png" alt="2026년 분기별 매출 추이">

<!-- 장식용: 빈 문자열. 속성 자체를 빼면 보조기기가 파일명을 읽는다.
     장식이 확실하면 CSS 배경으로 옮기는 편이 낫다. -->
<img src="deco.png" alt="">
```

**아이콘 전용 버튼 프로젝트 표준**

그림과 의미를 분리한다. 버튼에는 접근 가능한 이름이 있어야 하고, 아이콘은 보조기기에서 숨긴다. 프로젝트 기본 형태는 아래와 같다. 아이콘 구현이 `span` 대신 `svg`여도 의미 구조는 유지한다.

```html
<button type="button">
  <span class="icon_search" aria-hidden="true"></span>
  <span class="sr_only">검색</span>
</button>
```

## 1.7 하지 말 것

| 항목 | Severity | Source | 대신 | 예외 |
|---|---|---|---|---|
| `<font>` `<center>` | MUST | HTML | CSS | 없음 |
| `<br>`로 여백 만들기 | MUST | PROJECT | `margin` | 주소, 시 같은 실제 줄바꿈 |
| `&nbsp;`로 간격 조절 | MUST | PROJECT | `padding` / `gap` | 단어 붙임 방지 |
| `style="..."` 인라인 | SHOULD | PROJECT | 클래스 | JS 계산 값 주입 |
| 의미 없는 `div` 중첩 | SHOULD | PROJECT | 부모에 CSS 적용 | |

**`b`와 `i`는 금지 대상이 아니다.**

현행 HTML에서 둘 다 살아 있는 요소이고 고유한 의미가 있다. `font`, `center`와 같은 그룹에 넣으면 안 된다.

```text
중요성 부여                              -> strong
강세, 어조 변화                          -> em
단순 시각 장식                           -> CSS
중요성 없이 주의를 끄는 키워드, 제품명      -> b
분류학 학명, 외국어 구절, 다른 화자의 목소리 -> i
```

---

# 2부. CSS가 난잡해지는 원인

| 증상 | 원인 | 차단 규칙 |
|---|---|---|
| `!important`가 늘어난다 | 특이도 경쟁 | 층 순서 고정 (3.1) |
| 여백이 어긋나고 예외가 는다 | 여백 주인이 불명확 | 배치 책임 분리 (3.4) |
| 같은 회색이 여섯 종류 존재한다 | 값 하드코딩 | 토큰 사용 (3.3) |
| 마크업을 고치면 스타일이 깨진다 | 선택자가 DOM 구조에 의존 | 이름으로 선택 (3.5) |
| 클래스를 지우면 JS가 죽는다 | 스타일과 훅이 같은 클래스 | 훅 분리 (3.2) |
| `.red_title`이 파란색이다 | 이름이 모양 기반 | 이름은 역할 기반 (3.2) |
| 어느 파일에 쓸지 매번 다르다 | 층 개념 없음 | 층 고정 (3.1) |
| 상태 스타일이 흩어진다 | 상태 관리 주체가 둘 | 상태 두 종류로 분리 (3.6) |

---

# 3부. CSS 규칙

## 3.1 층

CSS 격리 방식은 프로젝트 프로파일의 `CSS_ISOLATION`으로 한 번 확정한다. 에이전트가 작업마다 다시 선택하지 않는다. 아래는 `CSS_ISOLATION=global-layer`인 경우다.

```css
/* 층 순서 선언. 이 한 줄이 이후 모든 우선순위를 결정한다.
   왼쪽이 앞 층, 오른쪽이 뒤 층이다. */
@layer overrides, reset, vendor, tokens, layout, component, utility, state;
```

| 층 | 담는 것 |
|---|---|
| `overrides` | 어쩔 수 없는 `!important` 덮어쓰기만 |
| `reset` | 태그 기본값 정규화 |
| `vendor` | 서드파티/프레임워크 CSS |
| `tokens` | 변수 정의 |
| `layout` | 판 나누기, 컬럼, 컴포넌트 간 간격 |
| `component` | 블록 내부 |
| `utility` | 한 가지 일만 하는 클래스 |
| `state` | 상태에 따른 변화 |

### 왜 이 순서인가

`@layer`는 일반 선언과 `!important` 선언에서 서로 **반대로** 동작한다.

```text
일반 선언
  뒤 층이 앞 층을 이긴다.
  단, 층 밖의 일반 선언은 층 안의 모든 일반 선언을 이긴다.

!important 선언
  앞 층이 뒤 층을 이긴다. (순서 역전)
  층 안의 !important는 층 밖의 !important보다 우선한다.
```

이 두 방향을 동시에 만족시키는 배치가 위 순서다.

```text
vendor를 앞쪽에 둔다
  -> 일반 선언에서 vendor가 약해진다
  -> 서드파티 기본 스타일을 내 component/state로 쉽게 덮는다

overrides를 맨 앞에 둔다
  -> !important에서 overrides가 가장 강해진다
  -> vendor 안의 !important를 덮을 수 있는 유일한 통로가 된다
```

앞 버전에서 "서드파티는 늦은 층에"라고 쓴 것은 틀렸다. `!important` 역전만 보고 일반 선언 쪽을 놓친 결과다.

```css
/* overrides 층 사용 예.
   여기 외의 어떤 층에서도 !important를 쓰지 않는다.
   overrides 안에서도 불가피한 이유를 바로 앞에 기록한다. */
@layer overrides {
  /* rule-exception: no-important -- 결제 위젯이 !important로 색을 고정한다 */
  .payment_wrap .vendor_btn { color: var(--color-text-default) !important; }
}
```

### 조건부 MUST / SHOULD

```text
CSS_ISOLATION = global-layer 인 경우
  -> 프로젝트의 모든 CSS는 선언된 @layer 안에 작성한다  [MUST / PROJECT / 기계]
  -> 층 밖의 스타일 규칙 작성을 금지한다
  -> !important는 overrides 층 밖에서 금지한다            [MUST / PROJECT / 기계]
  -> overrides 안에서도 불가피한 경우에만 쓰고 사유를 남긴다 [SHOULD / PROJECT / 기계+의미]
```

층 밖에 규칙 하나만 남아도 그것이 모든 층의 일반 선언을 이기므로 아키텍처에 구멍이 생긴다. 명세상 동작이므로 취향 문제가 아니다.

다른 방식을 골랐다면 이 규칙은 적용되지 않는다.

- CSS Modules -> 파일 단위 격리 + `layout` / `component` 폴더 분리
- Tailwind -> 유틸리티 우선, 컴포넌트 추출 기준만 정의

## 3.2 이름 — SHOULD / PROJECT / 의미

```text
.card_title          역할_대상
.card_title--alert   변형 (단독 사용 금지, 기본 클래스와 함께)
.sr_only             접근성 유틸
```

| 금지 | 이유 | 대안 |
|---|---|---|
| `.red_title` | 색이 바뀌면 이름이 거짓말이 된다 | `.title_alert` |
| `.left_box` | 위치가 바뀌면 이름이 거짓말이 된다 | `.column_nav` |
| `.mt_20` | 값이 이름에 박혀 토큰을 무력화한다 | 부모가 간격 소유 |

`.mt_20` 같은 값 기반 유틸 금지는 `UTILITY_STYLE=disallow`일 때 적용한다. Tailwind처럼 유틸리티 우선 체계를 택했다면 그건 규칙 위반이 아니라 다른 규칙 체계다.

**JS 훅 분리 — SHOULD / PROJECT / 기계**

방식은 프로젝트 프로파일의 `JS_HOOK`을 따른다. 핵심은 스타일 클래스와 동작 훅을 같은 이름으로 겸용하지 않는 것이다.

`JS_HOOK=class-prefix`인 경우:

```text
._toggle_btn   JS 전용. CSS 규칙 작성 금지
```

`JS_HOOK=ref`, `data-attribute`, `data-testid`를 쓰는 환경에서는 별도 접두사 클래스가 필요 없다. 에이전트가 기존 훅 방식을 다른 방식으로 바꾸지 않는다.

## 3.3 토큰 — SHOULD / PROJECT / 기계

**색상과 나머지에 서로 다른 규칙을 적용한다.** 아래 예시는 `COLOR_TOKEN=two-tier`인 경우다. `three-tier`를 선택한 프로젝트에서는 기존 3단 토큰 체계를 그대로 따른다.

```css
@layer tokens {
  :root {
    /* --- 색상 1단: 팔레트(원시값). 컴포넌트에서 직접 참조 금지 --- */
    --palette-blue-600: #2563eb;
    --palette-gray-900: #111827;
    --palette-gray-50:  #f9fafb;

    /* --- 색상 2단: 역할(의미). 컴포넌트는 이것만 참조한다 --- */
    --color-text-default: var(--palette-gray-900);
    --color-text-link:    var(--palette-blue-600);

    /* --- 공용 스케일: 단일 층. 컴포넌트에서 직접 사용 가능 --- */
    --space-4:         1rem;
    --radius-md:       8px;
    --font-size-body:  1rem;
  }

  /* 다크모드: 2단(역할)의 값만 바꾼다. 컴포넌트 CSS는 손대지 않는다. */
  [data-theme="dark"] {
    --color-text-default: var(--palette-gray-50);
  }
}
```

| 종류 | 규칙 |
|---|---|
| 색상 | 역할 토큰(`--color-*`)만 참조. `--palette-*` 직접 참조 금지 |
| 간격, 모서리, 글자 크기, 전환 시간 | 공용 스케일 토큰을 직접 사용 가능 |

```css
.card {
  padding: var(--space-4);           /* 정당: 공용 스케일 */
  border-radius: var(--radius-md);   /* 정당: 공용 스케일 */
  color: var(--color-text-default);  /* 정당: 색상 역할 토큰 */
  /* color: var(--palette-gray-900); */ /* 금지: 다크모드에서 깨진다 */
}
```

다크모드 문제는 **색상의 원시값 직접 참조**에서 발생한다. `--space-4`를 썼다고 발생하지 않는다.

**리터럴이 정당한 경우**

```text
transparent, currentColor, inherit
그라디언트 중간 색상
브랜드 로고/일러스트 전용 색
1px 같은 헤어라인
```

## 3.4 배치 책임 — SHOULD / PROJECT / 기계

> **컴포넌트는 자신의 외부 배치를 결정하지 않는다. 자신의 내부 레이아웃은 결정한다.**

```css
@layer layout {
  /* 부모가 컴포넌트 사이 간격을 소유한다.
     컴포넌트가 자기 바깥 여백을 모르면 어디에 꽂아도 간격이 맞는다. */
  .stack {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }
}

@layer component {
  .card {
    /* 내부 기준점. 자식의 absolute 배치를 위한 것. */
    position: relative;
    /* 내부 여백. 컴포넌트 소유. */
    padding: var(--space-4);
  }

  /* 내부 여백: 정당하다 */
  .card_title { margin-block-end: var(--space-2); }

  /* 내부 절대 배치: 정당하다. .card 기준으로만 움직인다. */
  .card_badge {
    position: absolute;
    inset-block-start: var(--space-2);
    inset-inline-end: var(--space-2);
    z-index: 1;                        /* 내부 겹침. 전역 충돌 없음 */
  }

  /* 고정 크기: 아이콘/아바타처럼 크기가 정체성인 요소는 정당하다 */
  .avatar {
    width: var(--size-avatar);
    height: var(--size-avatar);
  }
}
```

**컴포넌트 루트에서 금지**

```text
외부 margin
페이지 기준 absolute / fixed 배치
주변 레이아웃을 가정한 width / height
전역 쌓임 맥락을 가정한 z-index
```

내부 절대 배치까지 금지하면 배지 하나 놓으려고 억지로 layout 클래스를 만들게 된다.

## 3.5 선택자 — SHOULD / PROJECT / 기계

```css
/* 나쁨: 마크업 구조에 의존한다. div 하나만 끼워도 깨진다. */
.card > div > span { color: gray; }

/* 좋음: 이름에 의존한다. 마크업을 바꿔도 유지된다. */
.card_caption { color: var(--color-text-subtle); }
```

| 규칙 | 예외 |
|---|---|
| `!important` 금지 | `overrides` 층 안에서만 허용 |
| ID 선택자 금지 | 수정 불가능한 외부 위젯 대응 |
| 결합 깊이 3단 이하 | 본문 서식 영역, 중첩 목록, 표 내부 |
| 태그 선택자는 `reset` 층에서만 | 위와 동일 |

```css
/* 본문 서식 영역: CMS/에디터 산출 HTML에는 클래스가 없다.
   태그 선택자를 쓰되 진입점 클래스 하나로 범위를 가둔다.
   전역으로 새지만 않으면 된다. */
/* rule-exception: name-based-selector -- 에디터 산출 HTML에는 클래스가 없다 */
.prose h2      { margin-block-start: var(--space-8); }
.prose ul li + li { margin-block-start: var(--space-2); }
```

**z-index**

```css
@layer tokens {
  :root {
    /* 컴포넌트 "사이"의 겹침 순서만 토큰화한다. */
    --z-dropdown: 100;
    --z-sticky:   200;
    --z-modal:    300;
    --z-toast:    400;
  }
}
```

컴포넌트 내부의 국소적 겹침(`0`, `1`, `-1`)은 리터럴로 써도 된다. 새 쌓임 맥락 안에서만 의미가 있어 전역 충돌이 없다.

## 3.6 상태

**상태를 두 종류로 나눈다.** 접근성 의미를 올바르게 노출하는 요구와, 그 상태를 CSS/앱에서 어떻게 관리할지는 근거를 분리한다.

### A. 접근성 의미가 있는 상태

**상태 의미 노출 — MUST / WCAG / 기계+의미**

네이티브 속성 또는 ARIA 속성을 **정확한 요소에** 쓴다. 예를 들어 `aria-expanded`는 펼침/접힘을 제어하는 트리거에 둔다.

**상태 소스 단일화 — SHOULD / PROJECT / 기계+의미**

CSS는 가능하면 같은 네이티브/ARIA 상태를 직접 선택한다. `.is_open`처럼 동일 상태를 별도 클래스로 중복 관리하면 두 값이 어긋날 수 있으므로 피한다.

```html
<!-- aria-expanded는 "펼치고 접는 버튼"에 붙는다. 패널에 붙이면 안 된다.
     aria-controls가 버튼과 패널을 연결한다.
     패널의 표시 여부는 hidden 속성이 담당한다. -->
<button class="accordion_trigger" aria-expanded="false" aria-controls="panel-1">
  배송 정보
</button>
<div id="panel-1" class="accordion_panel" hidden>
  ...
</div>
```

```css
@layer state {
  /* 버튼의 ARIA 속성 하나가 접근성과 스타일을 동시에 담당한다.
     .is_open 같은 클래스를 따로 두면 둘이 어긋난다. */
  .accordion_trigger[aria-expanded="true"] .accordion_icon { rotate: 180deg; }
  .tab[aria-selected="true"] { border-block-end-color: var(--color-border-active); }

  /* 네이티브 상태는 의사 클래스로 바로 잡힌다 */
  .btn:disabled { opacity: .4; }
  .checkbox:checked + .checkbox_label { font-weight: 700; }
}
```

### B. 시각적, 애플리케이션 내부 상태 — SHOULD / PROJECT / 의미

대응하는 ARIA 속성이 없는 상태는 클래스나 `data-*`로 관리한다. 정의되지 않은 `aria-*`를 앱 내부 상태 저장용으로 새로 만들지 않는다.

```css
@layer state {
  /* 접근성 의미가 없는 순수 앱 상태. ARIA에 대응 속성이 없다. */
  .item.is_loading  { ... }
  .item.is_dragging { ... }
  .item[data-state="stale"] { ... }
}
```

**없는 ARIA 속성을 억지로 만들어 쓰지 않는다 — MUST / PROJECT.** `aria-*`는 정해진 속성만 사용한다.

### C. 포커스

**키보드 포커스 가시성 — MUST / WCAG / 기계+의미**

키보드 사용자가 현재 포커스를 명확히 확인할 수 있어야 한다. 특정 의사 클래스 자체가 요구사항은 아니다.

**`:focus-visible` 우선 — SHOULD / PROJECT / 기계+의미**

```css
@layer state {
  .btn:focus-visible {
    outline: 2px solid var(--color-border-focus);
    outline-offset: 2px;
  }
}
```

`outline: none`만 쓰고 동등 이상의 대체 포커스 표시가 없으면 MUST / WCAG 위반이다.

---

# 4부. HTML을 지키면 CSS가 줄어드는 지점

| HTML을 제대로 쓰면 | 직접 재구현하지 않아도 되는 것 |
|---|---|
| `button` 사용 | 키보드 조작, 포커스 가능성, `disabled` 시맨틱, 폼 연동 |
| `ul` / `li` 사용 | 항목 구분 클래스 |
| 제목 계층 준수 | 제목마다 개별 클래스 |
| `table` + `th` | 헤더 셀 스타일 클래스 |
| 네이티브 상태 속성 | 상태 클래스 절반 |

`cursor`는 여기 해당하지 않는다. CSS의 초기값은 `auto`이고 `pointer`는 링크를 나타내는 커서로 정의되어 있어, 버튼에 `cursor: pointer`를 주는 것은 별개의 표현 선택이다. 강제하지 않는다.

**클래스 개수가 이상하게 많으면 HTML이 의미를 안 담고 있다는 신호다.**

---

# 5부. 검증

## 5.1 기계 검증

검사 명령은 프로젝트 프로파일의 `VALIDATE_HTML` / `VALIDATE_CSS` 또는 프로젝트에 실제 정의된 scripts를 사용한다. 에이전트가 `npm run lint` 같은 명령을 임의로 추측하거나 새 검사 명령을 만들지 않는다.

**검사기는 파서 기반으로 구현한다.** 정규식과 건수 비교는 아래 이유로 신뢰할 수 없다.

```text
한 줄에 !important가 두 개 있을 수 있다
예외 주석 하나가 여러 선언에 걸릴 수 있다
주석이 엉뚱한 위치에 있어도 건수만 맞으면 통과한다
```

```text
CSS  -> PostCSS 또는 stylelint 커스텀 규칙으로 AST를 순회한다.
        각 declaration/rule의 직전 comment 노드를 확인해
        rule-exception 을 해당 선언에 연결한다.

HTML -> parse5 / jsdom 등으로 DOM을 만든 뒤 검사한다.
        속성 존재, 요소 개수, 중첩 관계는 전부 DOM 질의로 확인한다.
```

**검사 항목**

```text
--- MUST / HTML ---
[ ] [DOCUMENT] 인코딩 선언이 첫 1024바이트 안에 있다
[ ] [DOCUMENT] 화면에 보이는 main이 1개다
[ ] [DOCUMENT] main이 중첩되지 않았다
[ ] [ALL] alt 속성이 없는 img가 0개다
[ ] [ALL] font, center 요소가 0개다

--- MUST / WCAG ---
[ ] [DOCUMENT] html에 lang 속성이 있다
[ ] [ALL] 접근 가능한 이름이 없는 폼 컨트롤이 0개다
[ ] [ALL] outline을 제거했는데 대체 포커스 표시가 없는 규칙이 0건이다
[ ] [DOCUMENT] 반복 블록 우회 수단이 존재한다

--- MUST / PROJECT ---
[ ] [DOCUMENT] charset이 head 최상단에 있다
[ ] [DOCUMENT] viewport가 선언돼 있다
[ ] [DOCUMENT] 스킵 링크가 첫 포커스 요소다
[ ] [ALL] form 안 button에 type이 명시돼 있다
[ ] [DOCUMENT] heading 레벨을 순방향으로 건너뛴 곳이 0개다
[ ] [DOCUMENT] H1_POLICY=exactly-one이면 h1이 1개다
[ ] [ALL] 레이아웃 목적으로 의심되는 table이 0개다
[ ] [ALL] 패널 요소에 붙은 aria-expanded가 0개다
[ ] [ALL] 정의되지 않은 aria-* 를 앱 상태용으로 만든 곳이 0개다
[ ] (CSS_ISOLATION=global-layer) @layer 밖의 프로젝트 CSS 규칙이 0건이다
[ ] (CSS_ISOLATION=global-layer) overrides 층 밖의 !important가 0건이다

--- SHOULD / PROJECT (예외 주석 연결 후 판정) ---
[ ] overrides 안의 !important마다 rule-exception 사유가 연결돼 있다
[ ] ID 선택자가 0건이다
[ ] 인라인 style이 0건이다
[ ] 컴포넌트 루트에 외부 margin이 0건이다
[ ] 컴포넌트 루트에 페이지 기준 absolute/fixed가 0건이다
[ ] 컴포넌트에서 --palette-* 직접 참조가 0건이다
[ ] JS_HOOK=class-prefix이면 _ 로 시작하는 JS 훅 클래스에 CSS 규칙이 0건이다

--- 기계+의미 (의심 패턴만 보고, 최종 판단은 5.2에서) ---
[ ] div[onclick], span[onclick]
[ ] href 없는 a
[ ] role="button"이 붙은 div
```

## 5.2 의미 판단

문자열 검색으로는 판정할 수 없다. 작성 후 에이전트가 스스로 검토하거나 사람이 확인한다.

```text
alt 텍스트가 이미지의 역할을 실제로 설명하는가
  (alt="" 인 이미지가 정말 장식용인가)
heading이 뒤따르는 내용을 설명하는가
label 텍스트가 입력의 목적을 설명하는가
DOCUMENT라면 title이 페이지 내용을 설명하고 다른 페이지와 구분되는가
이 UI가 "이동"인가 "실행"인가 (a / button 최종 판단)
section이 독립적으로 식별 가능한 주제 묶음인가
article이 떼어내도 말이 되는 단위인가
address가 문서/article 작성자의 연락처인가
figure가 본문에서 독립 단위로 참조되는가
b/i를 쓴 자리가 strong/em/CSS로 대체되어야 하는 곳은 아닌가
fieldset이 묶음 자체에 의미가 있는 그룹에만 쓰였는가
클래스 이름이 역할을 가리키는가 (모양이 아니라)
선택자 깊이 초과가 진입점 클래스 안에 갇혀 있는가
토큰 리터럴 예외가 실제로 일회성 값인가
새 토큰/클래스/컴포넌트가 정말 필요한가, 기존 것을 재사용할 수 없는가
요청과 무관한 DOM/CSS를 바꾸지 않았는가
DOCUMENT 규칙을 COMPONENT 안에 잘못 적용하지 않았는가
```

## 5.3 3층 운영 구조

```text
1. html-css-rules.md   이 문서. 근거, 예제, 예외를 담은 원본 규격서.
                       사람이 읽고 판단할 때 참조한다.

2. agent-rules.md      실행용 축약본. 에이전트 컨텍스트에 넣는다.
                       PROJECT_PROFILE, 적용 범위, 기존 코드 보존 행동도 여기서 강제한다.

3. 검사기              기계 판정 가능한 규칙은 에이전트에게 기억시키지 않고
                       파서 기반 코드로 강제한다.
```

기계로 강제할 수 있는 것을 프롬프트에 넣으면 토큰만 쓰고 신뢰도는 낮다. 반대로 의미 판단 항목을 검사기에 넣으면 오탐만 쌓인다.

---

# 부록. 프로젝트 시작 시 결정할 것

`PROJECT` 출처 규칙 중 선택지가 있는 값은 여기서 확정하고 `agent-rules.md`의 `PROJECT_PROFILE`에 기록한다. 에이전트가 작업마다 다시 고르지 않는다.

```text
1. CSS 격리 방식       global-layer / css-modules / tailwind
2. 유틸리티 허용 여부 allow / disallow
3. JS 훅 분리 방식     class-prefix / ref / data-attribute / data-testid
4. h1 정책             exactly-one / project-defined
5. 색상 토큰 단계      two-tier / three-tier
6. HTML 검사 명령      project-defined command / none
7. CSS 검사 명령       project-defined command / none
```

## 도입 순서

```text
1. 층 순서 고정 + 층 밖 CSS 금지   -> !important 소멸
2. 배치 책임 분리                 -> 간격 예외 소멸
3. 색상 토큰 2단 구조              -> 색 난립 소멸
4. 상태를 A/B 두 종류로 분리        -> 상태 이중 관리 소멸
5. 이름 역할 기반                  -> 이름과 실제의 괴리 소멸
6. JS 훅 분리                     -> 전역 CSS 환경에서만
```
