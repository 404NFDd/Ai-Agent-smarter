# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$memoryDir = Join-Path $projectRoot '.codex-memory'
New-Item -ItemType Directory -Force -Path $memoryDir | Out-Null

$modifiedPath = Join-Path $memoryDir 'MODIFIED_FILES.md'
$qaPath = Join-Path $memoryDir 'QA.md'
$raw = [Console]::In.ReadToEnd().TrimStart([char]0xFEFF)
$toolName = ''
$toolCommand = ''
$toolResponse = ''
$now = Get-Date -Format 'yyyy-MM-dd HH:mm'

try {
    $inputData = $raw | ConvertFrom-Json -ErrorAction Stop
    $toolName = [string]$inputData.tool_name
    $toolCommand = [string]$inputData.tool_input.command
    $toolResponse = $inputData.tool_response | ConvertTo-Json -Depth 5 -Compress
} catch {
    $toolName = ''
    $toolCommand = ''
    $toolResponse = ''
}

if (-not (Test-Path -LiteralPath $modifiedPath)) {
    Set-Content -LiteralPath $modifiedPath -Encoding UTF8 -Value "# MODIFIED FILES`n`n| 일시 | 파일 | 작업 | 메모 |`n| --- | --- | --- | --- |"
}

if (-not (Test-Path -LiteralPath $qaPath)) {
    Set-Content -LiteralPath $qaPath -Encoding UTF8 -Value "# QA`n`n## 실행한 검증`n`n| 명령 | 결과 | 일시 | 메모 |`n| --- | --- | --- | --- |"
}

if ($toolName -eq 'apply_patch') {
    Add-Content -LiteralPath $modifiedPath -Encoding UTF8 -Value "| $now | hook 감지 파일 수정 | 도구 사용 | apply_patch 실행 |"
}

if ($toolName -eq 'Bash' -and $toolCommand -match '(?i)test|lint|build|typecheck|pytest|npm test|verify|검증|테스트') {
    $result = '기록'
    if ($toolResponse -match '(?i)fail|failed|error|exit code.*[1-9]|실패') {
        $result = '확인 필요'
    }
    Add-Content -LiteralPath $qaPath -Encoding UTF8 -Value "| hook 감지 검증 명령 | $result | $now | Bash 검증 명령 실행 |"
}

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'PostToolUse'
        additionalContext = '[PostToolUse] 수정 또는 검증 흔적을 memory 파일에 기록했습니다.'
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)

