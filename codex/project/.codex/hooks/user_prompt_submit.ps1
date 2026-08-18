# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$skillsDir = Join-Path $projectRoot '.agents/skills'
$memoryDir = Join-Path $projectRoot '.codex-memory'
$planRequiredPath = Join-Path $memoryDir '.plan_required'
$metricsPath = Join-Path $memoryDir 'METRICS.md'

$raw = [Console]::In.ReadToEnd().TrimStart([char]0xFEFF)
$prompt = ''
$skills = @()

try {
    $inputData = $raw | ConvertFrom-Json -ErrorAction Stop
    $prompt = [string]$inputData.prompt
} catch {
    $prompt = ''
}

# 스킬 본문을 안전하게 읽어 주입(강제 읽기). 길이 상한으로 자원 낭비 방지.
function Get-SkillContent {
    param([string]$SkillName, [int]$Budget)
    $skillFile = Join-Path $skillsDir "$SkillName/SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile)) { return '' }
    $content = Get-Content -LiteralPath $skillFile -Raw -Encoding UTF8
    if ($content.Length -gt $Budget) { $content = $content.Substring(0, $Budget) + "...(이후 생략, chapters/ 참조)" }
    return $content
}

function Add-Skill {
    param([string]$Path)
    if ($script:skills.Count -lt 3 -and $script:skills -notcontains $Path) {
        $script:skills += $Path
    }
}

if ($prompt -match '(?i)처음|파악|구조|온보딩|살펴|둘러|readme|onboarding|overview|explore') {
    Add-Skill '.agents/skills/codebase-onboarding/SKILL.md'
}

if ($prompt -match '(?i)bug|error|fail|failure|fix|debug|repro|버그|오류|에러|실패|고쳐|재현|디버그') {
    Add-Skill '.agents/skills/bugfix-debugging/SKILL.md'
}

if ($prompt -match '(?i)test|lint|typecheck|build|verify|qa|coverage|fixture|test data|테스트|검증|빌드|타입체크|테스트 데이터') {
    Add-Skill '.agents/skills/testing-qa/SKILL.md'
}

if ($prompt -match '(?i)implement|add|build|feature|plan|큰 작업|만들|추가|구현|계획|기능') {
    Add-Skill '.agents/skills/implementation-planning/SKILL.md'
}

if ($prompt -match '(?i)api|server|route|controller|endpoint|service|rate limit|quota|resource consumption|pagination|upload|서버|엔드포인트|리소스|업로드') {
    Add-Skill '.agents/skills/backend-api/SKILL.md'
}

if ($prompt -match '(?i)ui|screen|component|button|modal|\bform\b|css|layout|responsive|accessibility|contrast|color contrast|playwright|screenshot|화면|컴포넌트|버튼|반응형|접근성|색상 대비|대비') {
    Add-Skill '.agents/skills/frontend-ui/SKILL.md'
}

if ($prompt -match '(?i)\bhtml\b|\bcss\b|markup|stylesheet|selector|마크업|스타일시트|선택자') {
    Add-Skill '.agents/skills/html-css-rules/SKILL.md'
}

if ($prompt -match '(?i)db|database|migration|schema|table|index|query|transaction|마이그레이션|스키마|쿼리') {
    Add-Skill '.agents/skills/database-migration/SKILL.md'
}

if ($prompt -match '(?i)security|token|secret|password|injection|xss|csrf|permission|auth|authz|보안|인증|인가|권한|시크릿') {
    Add-Skill '.agents/skills/security/SKILL.md'
}

if ($prompt -match '(?i)style|naming|comment|abstraction|convention|스타일|네이밍|주석|추상화|컨벤션') {
    Add-Skill '.agents/skills/code-style/SKILL.md'
}

if ($prompt -match '(?i)git|branch|commit|pr|pull request|push|dirty|worktree|브랜치|커밋|푸시') {
    Add-Skill '.agents/skills/git-workflow/SKILL.md'
}

if ($prompt -match '(?i)doc|docs|readme|changelog|문서|가이드') {
    Add-Skill '.agents/skills/documentation/SKILL.md'
}

if ($prompt -match '(?i)review|검토|리뷰') {
    Add-Skill '.agents/skills/review/SKILL.md'
}

if ($prompt -match '(?i)performance|perf|slow|cache|bottleneck|bundle|성능|느림|캐시|병목|번들') {
    Add-Skill '.agents/skills/performance/SKILL.md'
}

if ($prompt -match '(?i)timeout|retry|backoff|idempotency|idempotent|rate limit|quota|circuit breaker|resilience|타임아웃|재시도|멱등|장애|복원력') {
    Add-Skill '.agents/skills/resilience/SKILL.md'
}

if ($prompt -match '(?i)i18n|locale|timezone|time zone|currency|date format|number format|translation|다국어|로케일|시간대|날짜|통화|번역') {
    Add-Skill '.agents/skills/i18n-time-currency/SKILL.md'
}

if ($prompt -match '(?i)dependency|package|install|lockfile|upgrade|npm|pnpm|yarn|pip|cargo|패키지|의존성|설치|업그레이드') {
    Add-Skill '.agents/skills/dependency-management/SKILL.md'
}

if ($prompt -match '(?i)release|deploy|version|tag|rollback|배포|릴리즈|버전|롤백') {
    Add-Skill '.agents/skills/release-deploy/SKILL.md'
}

if ($prompt -match '(?i)log|metric|trace|tracing|sentry|observability|로그|메트릭|트레이싱|관측') {
    Add-Skill '.agents/skills/observability/SKILL.md'
}

if ($prompt -match '(?i)refactor|cleanup|rework|리팩터링|정리') {
    Add-Skill '.agents/skills/refactoring/SKILL.md'
}

if ($prompt -match '(?i)codex|agent|collaboration|handoff|질문|중간 보고|협업|에이전트') {
    Add-Skill '.agents/skills/ai-agent-collaboration/SKILL.md'
}

# 의도 분류(갭 4): action-verb 기반 작업 유형 보강. 큰 작업은 planner 게이트로 연결.
$isLargeTask = $prompt -match '(?i)build|add|implement|refactor|structure|migration|rework|만들어줘|추가해줘|구현해줘|리팩터링|구조|마이그레이션|정리해줘'
$isBugfix = $prompt -match '(?i)fix|고쳐|버그|오류|에러|재현|debug'

# 큰 작업 감지 → plan_required 상태 기록(C 항목 5/6). PLAN.md 가 이후에 갱신되어야 게이트 해제.
if ($isLargeTask) {
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($planRequiredPath, (Get-Date -Format 'yyyy-MM-dd HH:mm'), $utf8)
}

$lines = @('[Codex 운영 컨텍스트]')

# 강제 읽기(B 항목 1): 매칭 skill 경로만 추천하지 않고 본문을 주입.
$injectedAny = $false
$budget = 4000
$usedBudget = 0
foreach ($skillPath in $skills) {
    $skillName = ($skillPath -split '/')[-2]
    $remaining = $budget - $usedBudget
    if ($remaining -le 200) { break }
    $content = Get-SkillContent -SkillName $skillName -Budget $remaining
    if ($content) {
        $lines += ''
        $lines += "[skill 매뉴얼: $skillName]"
        $lines += $content
        $usedBudget += $content.Length
        $injectedAny = $true
    }
}
if (-not $injectedAny) {
    $lines += '관련 skill이 있으면 작업 전에 .agents/skills/INDEX.md 를 확인하세요.'
}

# 큰 작업 지시: planner + 계획 문서 우선.
if ($isLargeTask) {
    $lines += ''
    $lines += '[큰 작업 게이트] 구현(apply_patch) 전에 먼저 planner 서브에이전트로 계획을 세우고 .codex-memory/PLAN.md, CONTEXT.md, CHECKLIST.md 를 작성/갱신하세요. PLAN.md 를 저장하기 전에는 편집이 차단됩니다.'
    $planPath = Join-Path $memoryDir 'PLAN.md'
    if (-not (Test-Path -LiteralPath $planPath)) {
        $lines += 'PLAN.md 가 없습니다. 큰 작업 시작 전 PLAN/CONTEXT/CHECKLIST 뼈대를 먼저 만드세요.'
    }
}

if ($isBugfix) {
    $lines += '버그 수정은 재현 → 검증 흐름으로 진행하세요(bugfix-debugging skill 참조).'
}

$lines += '완료 전 QA.md 에 검증 결과와 남은 위험을 기록하세요.'

if (Test-Path -LiteralPath $metricsPath) {
    Add-Content -LiteralPath $metricsPath -Encoding UTF8 -Value "| $(Get-Date -Format 'yyyy-MM-dd HH:mm') | user_prompt skills=$($skills.Count) large=$isLargeTask |"
}

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'UserPromptSubmit'
        additionalContext = ($lines -join "`n")
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)
