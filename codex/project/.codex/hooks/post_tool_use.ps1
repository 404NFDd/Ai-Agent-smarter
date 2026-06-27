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

# 셀프체크 리마인더 구조화(D 항목 12): 수정 파일 / 오류처리 / 보안위험 3항.
$contextMsg = '[PostToolUse] 수정 또는 검증 흔적을 memory 파일에 기록했습니다.'
if ($modifiedFiles.Count -gt 0) {
    $securityKeywords = 'auth|login|token|password|secret|credential|인증|권한|비밀|토큰'
    $hasSecurityChange = $false
    foreach ($f in $modifiedFiles) {
        if ($f -match "(?i)$securityKeywords") { $hasSecurityChange = $true; break }
    }

    $contextMsg += "`n[셀프체크 리마인더]"
    $contextMsg += "`n- 수정 파일 $($modifiedFiles.Count)건: " + ($modifiedFiles -join ', ')
    $contextMsg += "`n- 에러 처리/예외 경로를 추가했나요? 빠진 오류 처리가 없는지 확인하세요."
    if ($hasSecurityChange) {
        $contextMsg += "`n- 보안상 위험한 부분은 없나요? 인증/권한/입력검증/secret 노출 점검 후 security-reviewer 서브에이전트 검토를 권장합니다."
        $contextMsg += "`n- 수정 파일이 $($modifiedFiles.Count)개 있음: reviewer 서브에이전트로 코드 검토를 권장합니다."
    } else {
        $contextMsg += "`n- 보안상 위험한 부분은 없나요? 입력 검증과 secret 노출 여부를 확인하세요."
        $contextMsg += "`n- 수정 파일이 $($modifiedFiles.Count)개 있음: reviewer 서브에이전트로 코드 검토를 권장합니다."
    }
}

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'PostToolUse'
        additionalContext = $contextMsg
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)