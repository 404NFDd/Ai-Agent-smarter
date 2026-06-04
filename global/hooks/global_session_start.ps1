# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$additionalContext = @"
[전역 세션 시작 알림]
응답 첫 줄에 `[HOOK: SessionStart 읽음]`을 표시하세요.
프로젝트 루트에 다음 파일이 있으면 먼저 확인하세요.
- AGENTS.md
- .codex-memory/PLAN.md
- .codex-memory/CONTEXT.md
- .codex-memory/CHECKLIST.md
- .codex-memory/DECISIONS.md
- .codex-memory/QA.md
"@

$payload = @{
    hookSpecificOutput = @{
        hookEventName = "SessionStart"
        additionalContext = $additionalContext
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)

