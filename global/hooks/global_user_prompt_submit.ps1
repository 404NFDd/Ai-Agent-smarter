# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$additionalContext = @"
[전역 요청 시작 지침]
응답 첫 줄에 `[HOOK: UserPromptSubmit 읽음]`을 표시하세요.
- 반드시 필요할 때를 제외하고 한글로 답하세요.
- 프로젝트 루트에 AGENTS.md가 있으면 먼저 확인하세요.
- 프로젝트 hook 또는 skill이 있으면 더 구체적인 프로젝트 지침으로 취급하세요.
"@

$payload = @{
    hookSpecificOutput = @{
        hookEventName = "UserPromptSubmit"
        additionalContext = $additionalContext
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)

