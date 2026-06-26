# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$additionalContext = @"
[전역 도구 사용 후 확인]
- 파일을 수정했거나 검증을 실행했다면 관련 기록 파일에 반영하세요.
"@

$payload = @{
    hookSpecificOutput = @{
        hookEventName = "PostToolUse"
        additionalContext = $additionalContext
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)
