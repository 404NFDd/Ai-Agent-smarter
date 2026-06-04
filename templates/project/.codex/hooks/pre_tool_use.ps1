# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$raw = [Console]::In.ReadToEnd()
$skills = @()

function Add-Skill {
    param([string]$Path)
    if ($script:skills.Count -lt 3 -and $script:skills -notcontains $Path) {
        $script:skills += $Path
    }
}

if ($raw -match '(?i)\brm\b|remove-item|del\b|erase\b|삭제|제거') {
    Add-Skill '.agents/skills/git-workflow/SKILL.md'
}

if ($raw -match '(?i)migration|migrate|schema|db|database|마이그레이션|스키마') {
    Add-Skill '.agents/skills/database-migration/SKILL.md'
}

if ($raw -match '(?i)install|add package|npm|pnpm|yarn|pip|cargo|lockfile|패키지|의존성|설치') {
    Add-Skill '.agents/skills/dependency-management/SKILL.md'
}

if ($raw -match '(?i)deploy|release|publish|rollback|배포|릴리즈|롤백') {
    Add-Skill '.agents/skills/release-deploy/SKILL.md'
}

if ($raw -match '(?i)secret|token|password|auth|permission|보안|시크릿|인증|권한') {
    Add-Skill '.agents/skills/security/SKILL.md'
}

if ($raw -match '(?i)timeout|retry|rate limit|quota|idempotency|타임아웃|재시도|멱등|장애') {
    Add-Skill '.agents/skills/resilience/SKILL.md'
}

if ($raw -match '(?i)i18n|locale|timezone|currency|date format|다국어|로케일|시간대|통화') {
    Add-Skill '.agents/skills/i18n-time-currency/SKILL.md'
}

$lines = @('[도구 사용 전 확인]')

if ($skills.Count -gt 0) {
    $lines += '이 작업 전 확인할 skill 후보:'
    foreach ($skill in $skills) {
        $lines += "- $skill"
    }
} else {
    $lines += '위험 작업이면 관련 skill과 사용자 승인 필요 여부를 확인하세요.'
}

$payload = @{
    decision = 'allow'
    reason = '도구 사용 전 확인 완료'
    hookSpecificOutput = @{
        hookEventName = 'PreToolUse'
        additionalContext = ($lines -join "`n")
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)
