# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$additionalContext = @"
[전역 종료 전 확인]
- 최종 답변 전 검증 결과, 실행하지 못한 검증, 남은 위험을 확인하세요.
"@

$payload = @{
    decision = "allow"
    reason = "전역 종료 전 확인"
    hookSpecificOutput = @{
        hookEventName = "Stop"
        additionalContext = $additionalContext
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)
