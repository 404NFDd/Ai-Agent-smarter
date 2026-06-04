# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$checklistPath = Join-Path $projectRoot '.codex-memory/CHECKLIST.md'
$qaPath = Join-Path $projectRoot '.codex-memory/QA.md'
$modifiedPath = Join-Path $projectRoot '.codex-memory/MODIFIED_FILES.md'

$reasons = @()

$modifiedRows = @()
if (Test-Path -LiteralPath $modifiedPath) {
    $modifiedRows = Get-Content -LiteralPath $modifiedPath -Encoding UTF8 | Where-Object { $_ -match '^\| \d{4}-\d{2}-\d{2}' }
}

$qaRows = @()
if (Test-Path -LiteralPath $qaPath) {
    $qaRows = Get-Content -LiteralPath $qaPath -Encoding UTF8 | Where-Object { $_ -match '^\| .+ \| .+ \| \d{4}-\d{2}-\d{2}' }
}

if ($modifiedRows.Count -gt 0 -and $qaRows.Count -eq 0) {
    $reasons += '수정 파일 기록은 있지만 QA.md에 검증 결과가 없습니다.'
}

if (Test-Path -LiteralPath $checklistPath) {
    $openCoreItems = Select-String -LiteralPath $checklistPath -Encoding UTF8 -Pattern '^\s*-\s*\[\s\].*(QA|verify|verification|modified|file|complete|risk|검증|수정|파일|완료|남은 위험)'
    if ($openCoreItems.Count -gt 0) {
        $reasons += 'CHECKLIST.md에 완료 전 핵심 미완료 항목이 남아 있습니다.'
    }
}

if ($reasons.Count -gt 0) {
    $payload = @{
        decision = 'block'
        reason = ($reasons -join ' ')
    }
} else {
    $payload = @{
        decision = 'allow'
        reason = '완료 조건 충족'
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)

