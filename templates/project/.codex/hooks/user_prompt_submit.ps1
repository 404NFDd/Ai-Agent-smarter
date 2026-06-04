# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$raw = [Console]::In.ReadToEnd()
$prompt = $raw
$skills = @()

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

if ($prompt -match '(?i)test|lint|typecheck|build|verify|qa|coverage|테스트|검증|빌드|타입체크') {
    Add-Skill '.agents/skills/testing-qa/SKILL.md'
}

if ($prompt -match '(?i)implement|add|build|feature|plan|큰 작업|만들|추가|구현|계획|기능') {
    Add-Skill '.agents/skills/implementation-planning/SKILL.md'
}

if ($prompt -match '(?i)api|server|route|controller|endpoint|service|서버|엔드포인트') {
    Add-Skill '.agents/skills/backend-api/SKILL.md'
}

if ($prompt -match '(?i)ui|screen|component|button|modal|form|css|layout|responsive|accessibility|playwright|screenshot|화면|컴포넌트|버튼|반응형|접근성') {
    Add-Skill '.agents/skills/frontend-ui/SKILL.md'
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

$isLargeTask = $prompt -match '(?i)build|add|implement|refactor|structure|migration|rework|만들어줘|추가해줘|구현해줘|리팩터링|구조|마이그레이션|정리해줘'

$lines = @('[Codex 운영 컨텍스트]')

if ($skills.Count -gt 0) {
    $lines += '이 요청과 관련 있어 보이는 skill 후보:'
    foreach ($skill in $skills) {
        $lines += "- $skill"
    }
} else {
    $lines += '관련 skill이 있으면 작업 전에 확인하세요.'
}

if ($isLargeTask) {
    $lines += '큰 작업으로 보이면 편집 전 .codex-memory/PLAN.md, CONTEXT.md, CHECKLIST.md를 먼저 갱신하세요.'
}

$lines += '완료 전 QA.md에 검증 결과와 남은 위험을 기록하세요.'

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'UserPromptSubmit'
        additionalContext = ($lines -join "`n")
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)

