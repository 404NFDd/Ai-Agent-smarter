# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$raw = [Console]::In.ReadToEnd()
$prompt = $raw
$skills = @()

function Add-Skill {
    param([string]$Path)
    if ($script:skills -notcontains $Path) {
        $script:skills += $Path
    }
}

if ($prompt -match '(?i)api|server|route|controller|endpoint|service|auth|permission|서버|인증|권한') {
    Add-Skill '.agents/skills/backend/SKILL.md'
}

if ($prompt -match '(?i)ui|screen|component|button|modal|form|css|layout|responsive|화면|컴포넌트|버튼|반응형') {
    Add-Skill '.agents/skills/frontend/SKILL.md'
}

if ($prompt -match '(?i)db|database|migration|schema|table|index|query|transaction|마이그레이션') {
    Add-Skill '.agents/skills/database/SKILL.md'
}

if ($prompt -match '(?i)test|lint|typecheck|build|verify|failure|bug|fix|테스트|검증|실패|버그|고쳐') {
    Add-Skill '.agents/skills/testing/SKILL.md'
}

if ($prompt -match '(?i)security|token|secret|password|injection|xss|csrf|permission|auth|보안|권한') {
    Add-Skill '.agents/skills/security/SKILL.md'
}

$isLargeTask = $prompt -match '(?i)build|add|implement|refactor|structure|migration|rework|만들어줘|추가해줘|구현해줘|리팩터링|구조|마이그레이션|정리해줘'

$lines = @('[Codex 운영 컨텍스트]')

if ($skills.Count -gt 0) {
    $lines += '이 요청과 관련 있어 보이는 skill:'
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

