# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$memoryFiles = @(
    '.codex-memory/PLAN.md',
    '.codex-memory/CONTEXT.md',
    '.codex-memory/CHECKLIST.md',
    '.codex-memory/DECISIONS.md',
    '.codex-memory/QA.md'
)

$existing = @()
foreach ($file in $memoryFiles) {
    if (Test-Path -LiteralPath (Join-Path $projectRoot $file)) {
        $existing += $file
    }
}

$lines = @('[작업 기억 복구]')

if ($existing.Count -gt 0) {
    $lines += '다음 파일을 먼저 확인하세요.'
    foreach ($file in $existing) {
        $lines += "- $file"
    }
    $lines += '현재 남은 작업은 CHECKLIST.md 기준으로 진행하세요.'
} else {
    $lines += '.codex-memory 파일이 없으면 큰 작업 전 템플릿을 생성하세요.'
}

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'SessionStart'
        additionalContext = ($lines -join "`n")
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)

