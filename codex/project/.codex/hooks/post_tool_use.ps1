# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$memoryDir = Join-Path $projectRoot '.codex-memory'
New-Item -ItemType Directory -Force -Path $memoryDir | Out-Null

$modifiedPath = Join-Path $memoryDir 'MODIFIED_FILES.md'
$qaPath = Join-Path $memoryDir 'QA.md'
$metricsPath = Join-Path $memoryDir 'METRICS.md'
# 셀프체크 리마인더 주입 주기(누적 수정 건수 기준). 1 이면 매번.
$REMIND_EVERY = 3
$raw = [Console]::In.ReadToEnd().TrimStart([char]0xFEFF)
$toolName = ''
$toolCommand = ''
$toolResponse = ''
$now = Get-Date -Format 'yyyy-MM-dd HH:mm'

try {
    $inputData = $raw | ConvertFrom-Json -ErrorAction Stop
    $toolName = [string]$inputData.tool_name
    $toolCommand = [string]$inputData.tool_input.command
    # apply_patch 패치 본문은 실제 문자열 필드(input)에서 가져와야 줄바꿈이 보존된다.
    # ConvertTo-Json은 줄바꿈을 \n 리터럴로 이스케이프하므로 파싱에 쓸 수 없다.
    $patchText = [string]$inputData.tool_input.input
    $toolResponse = $inputData.tool_response | ConvertTo-Json -Depth 5 -Compress
} catch {
    $toolName = ''
    $toolCommand = ''
    $patchText = ''
    $toolResponse = ''
}

# apply_patch 입력에서 실제 파일 경로 추출.
# Codex apply_patch 포맷("*** Update/Add/Delete File: <경로>")과 git unified diff("+++ b/<경로>") 모두 처리.
function Get-PatchedFilePaths {
    param([string]$PatchText)
    $paths = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrWhiteSpace($PatchText)) { return $paths }
    $lines = $PatchText -split "`n"
    foreach ($line in $lines) {
        if ($line -match '^\*\*\*\s+(?:Update|Add|Delete)\s+File:\s*(.+?)\s*$') {
            $paths.Add($matches[1])
        } elseif ($line -match '^\+\+\+\s+b/(.+?)\s*$') {
            $paths.Add($matches[1])
        }
    }
    return $paths
}

if (-not (Test-Path -LiteralPath $modifiedPath)) {
    Set-Content -LiteralPath $modifiedPath -Encoding UTF8 -Value "# MODIFIED FILES`n`n| 일시 | 파일 | 작업 | 메모 |`n| --- | --- | --- | --- |"
}

if (-not (Test-Path -LiteralPath $qaPath)) {
    Set-Content -LiteralPath $qaPath -Encoding UTF8 -Value "# QA`n`n## 실행한 검증`n`n| 명령 | 결과 | 일시 | 메모 |`n| --- | --- | --- | --- |"
}

$modifiedFiles = @()
if ($toolName -eq 'apply_patch') {
    $patchedPaths = Get-PatchedFilePaths -PatchText $patchText
    if ($patchedPaths.Count -gt 0) {
        foreach ($p in $patchedPaths) {
            $modifiedFiles += $p
            Add-Content -LiteralPath $modifiedPath -Encoding UTF8 -Value "| $now | $p | 도구 사용 | apply_patch 실행 |"
        }
    } else {
        Add-Content -LiteralPath $modifiedPath -Encoding UTF8 -Value "| $now | 파일명 추출 실패 | 도구 사용 | apply_patch 실행 |"
    }
}

# 모델이 실행한 검증 명령(Bash test/lint/build 등) 결과 기록.
if ($toolName -eq 'Bash' -and $toolCommand -match '(?i)test|lint|build|typecheck|pytest|npm test|verify|검증|테스트') {
    $result = '성공'
    if ($toolResponse -match '(?i)fail|failed|error|exit code.*[1-9]|실패') {
        $result = '실패'
    }
    Add-Content -LiteralPath $qaPath -Encoding UTF8 -Value "| hook 감지 검증 명령 | $result | $now | Bash 검증 명령 실행 |"
}

# METRICS 카운터.
if (Test-Path -LiteralPath $metricsPath) {
    Add-Content -LiteralPath $metricsPath -Encoding UTF8 -Value "| $now | post_tool_use tool=$toolName files=$($modifiedFiles.Count) |"
}

# 셀프체크 리마인더. 수정이 없으면 컨텍스트를 늘리지 않는다.
if ($modifiedFiles.Count -eq 0) { exit }

# 보안 키워드는 전체 경로가 아니라 파일명으로 본다. 상위 폴더명에 의한 오탐을 막는다.
$securityKeywords = 'auth|login|token|password|secret|credential|permission|인증|권한|비밀|토큰'
$hasSecurityChange = $false
foreach ($f in $modifiedFiles) {
    if ([System.IO.Path]::GetFileName($f) -match "(?i)$securityKeywords") { $hasSecurityChange = $true; break }
}

# 보안 관련이면 즉시, 그 외에는 누적 REMIND_EVERY 건마다 한 번만.
$total = 0
if (Test-Path -LiteralPath $modifiedPath) {
    $total = (Select-String -LiteralPath $modifiedPath -Encoding UTF8 -Pattern '^\| \d{4}-\d{2}-\d{2}').Count
}
if (-not $hasSecurityChange -and ($total % $REMIND_EVERY) -ne 0) { exit }

$contextMsg = "[셀프체크] " + ($modifiedFiles -join ', ') + " (누적 $total 건)"
if ($hasSecurityChange) {
    $contextMsg += "`n- 인증/권한/입력 검증/secret 노출을 점검하세요. security-reviewer 보고는 QA.md 의 ## security-reviewer 보고 헤더 아래에 남깁니다."
} else {
    $contextMsg += "`n- 오류 처리, 예외 경로, 입력 검증 누락을 확인하세요."
}

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'PostToolUse'
        additionalContext = $contextMsg
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)