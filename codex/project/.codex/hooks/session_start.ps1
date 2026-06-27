# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$memoryDir = Join-Path $projectRoot '.codex-memory'
$memoryFiles = @(
    '.codex-memory/PLAN.md',
    '.codex-memory/CONTEXT.md',
    '.codex-memory/CHECKLIST.md',
    '.codex-memory/DECISIONS.md',
    '.codex-memory/QA.md'
)

$modifiedPath = Join-Path $memoryDir 'MODIFIED_FILES.md'

# MODIFIED_FILES.md 누적 방지: 세션 시작 시 이전 내용을 날짜 아카이브로 옮기고 헤더만 남긴다.
if (Test-Path -LiteralPath $modifiedPath) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $archivePath = Join-Path $memoryDir "MODIFIED_FILES.$stamp.md"
    try {
        Move-Item -LiteralPath $modifiedPath -Destination $archivePath -Force -ErrorAction Stop
    } catch {}
}
Set-Content -LiteralPath $modifiedPath -Encoding UTF8 -Value "# MODIFIED FILES`n`n| 일시 | 파일 | 작업 | 메모 |`n| --- | --- | --- | --- |"

# stop_guard 상태 초기화(세션 시작 시 잔류 카운터 제거).
$statePath = Join-Path $memoryDir '.stop_guard_state'
if (Test-Path -LiteralPath $statePath) { Remove-Item -LiteralPath $statePath -Force }
# 세션 전역 차단 수 초기화(루프/토큰 과사용 방지 B).
$sessionBlocksPath = Join-Path $memoryDir '.session_blocks'
if (Test-Path -LiteralPath $sessionBlocksPath) { Remove-Item -LiteralPath $sessionBlocksPath -Force }
if (Test-Path -LiteralPath (Join-Path $memoryDir '.plan_gate_state')) { Remove-Item -LiteralPath (Join-Path $memoryDir '.plan_gate_state') -Force }
if (Test-Path -LiteralPath (Join-Path $memoryDir '.plan_required')) { Remove-Item -LiteralPath (Join-Path $memoryDir '.plan_required') -Force }

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
    $lines += '.codex-memory 파일이 없으면 큰 작업 전 PLAN/CONTEXT/CHECKLIST를 먼저 작성하세요.'
}

# CHECKLIST.md 미완료 항목을 추출해 남은 작업으로 주입(C 항목 8).
$checklistPath = Join-Path $projectRoot '.codex-memory/CHECKLIST.md'
if (Test-Path -LiteralPath $checklistPath) {
    $openItems = Select-String -LiteralPath $checklistPath -Encoding UTF8 -Pattern '^\s*-\s*\[\s\]'
    if ($openItems.Count -gt 0) {
        $lines += ''
        $lines += '[현재 남은 작업]'
        foreach ($item in $openItems) {
            $lines += "- $($item.Line.Trim())"
        }
    }
}

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'SessionStart'
        additionalContext = ($lines -join "`n")
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)