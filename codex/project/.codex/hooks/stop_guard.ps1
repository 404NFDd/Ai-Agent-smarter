# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$memoryDir = Join-Path $projectRoot '.codex-memory'
$checklistPath = Join-Path $projectRoot '.codex-memory/CHECKLIST.md'
$qaPath = Join-Path $projectRoot '.codex-memory/QA.md'
$modifiedPath = Join-Path $projectRoot '.codex-memory/MODIFIED_FILES.md'
$statePath = Join-Path $projectRoot '.codex-memory/.stop_guard_state'
$verifyPath = Join-Path $projectRoot '.codex/verify.toml'
$metricsPath = Join-Path $projectRoot '.codex-memory/METRICS.md'

# verify.toml 파서: flat 섹션([lint] 등) + command/enabled/timeout 만 처리한다.
function ConvertFrom-VerifyToml {
    param([string]$Path)
    $list = New-Object System.Collections.Generic.List[hashtable]
    if (-not (Test-Path -LiteralPath $Path)) { return $list }
    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    $section = ''
    $entry = $null
    foreach ($line in $lines) {
        $t = $line.Trim()
        if ($t -eq '' -or $t.StartsWith('#')) { continue }
        if ($t -match '^\[(.+)\]$') {
            if ($entry) { $list.Add($entry) }
            $section = $matches[1].Trim()
            $entry = @{ name = $section; command = ''; enabled = $true; timeout = 120 }
            continue
        }
        if ($t -match '^(\w+)\s*=\s*(.*)$') {
            $key = $matches[1]; $val = $matches[2].Trim()
            if ($key -eq 'command') {
                $v = $val.Trim('"').Trim("'")
                $entry.command = $v
            } elseif ($key -eq 'enabled') {
                $entry.enabled = ($val -match 'true')
            } elseif ($key -eq 'timeout') {
                $tm = 0; [void][int]::TryParse($val, [ref]$tm); if ($tm -gt 0) { $entry.timeout = $tm }
            }
        }
    }
    if ($entry) { $list.Add($entry) }
    return $list
}

# 명령을 프로젝트 루트에서 timeout 초 안에 실행. 결과 해시 반환.
# Start-Process -PassThux 는 WaitForExit(ms) 후 ExitCode 를 반환하지 않는 PS 한계가 있어
# System.Diagnostics.Process 로 직접 실행해 ExitCode 를 안정적으로 얻는다.
function Invoke-Verify {
    param([string]$Command, [int]$Timeout, [string]$WorkDir)
    $result = @{ code = -1; tail = ''; timedOut = $false }
    if ([string]::IsNullOrWhiteSpace($Command)) { return $result }
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = 'cmd.exe'
        $psi.Arguments = "/c $Command"
        $psi.WorkingDirectory = $WorkDir
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        $proc = New-Object System.Diagnostics.Process
        $proc.StartInfo = $psi
        [void]$proc.Start()
        $outTask = $proc.StandardOutput.ReadToEndAsync()
        $errTask = $proc.StandardError.ReadToEndAsync()
        $ms = $Timeout * 1000
        $exited = $proc.WaitForExit($ms)
        if (-not $exited) {
            $result.timedOut = $true
            try { $proc.Kill() } catch {}
            $result.tail = 'timeout'
        } else {
            $proc.WaitForExit()
            $result.code = $proc.ExitCode
            $outTask.Wait(2000) | Out-Null
            $errTask.Wait(2000) | Out-Null
            $combined = "$($outTask.Result)`n$($errTask.Result)"
            if ($combined.Length -gt 500) { $combined = $combined.Substring($combined.Length - 500) }
            $result.tail = $combined.Trim()
        }
    } catch {
        $result.tail = "실행 오류: $($_.Exception.Message)"
    }
    return $result
}

# QA.md 가 없으면 헤더 생성.
if (-not (Test-Path -LiteralPath $qaPath)) {
    Set-Content -LiteralPath $qaPath -Encoding UTF8 -Value "# QA`n`n## 실행한 검증`n`n| 명령 | 결과 | 일시 | 메모 |`n| --- | --- | --- | --- |"
}

# verify.toml 실행.
$verifyList = ConvertFrom-VerifyToml -Path $verifyPath
$now = Get-Date -Format 'yyyy-MM-dd HH:mm'
$failedChecks = 0
$runChecks = 0
$checkSummary = @()
foreach ($v in $verifyList) {
    if (-not $v.enabled) { continue }
    if ([string]::IsNullOrWhiteSpace($v.command)) { continue }
    $runChecks += 1
    $r = Invoke-Verify -Command $v.command -Timeout $v.timeout -WorkDir $projectRoot
    $status = '통과'
    if ($r.timedOut) { $status = '실패' } elseif ($r.code -ne 0) { $status = '실패' }
    if ($status -eq '실패') { $failedChecks += 1 }
    $memo = "$($v.command)"
    if ($r.timedOut) { $memo += " | timeout($($v.timeout)s)" } elseif ($r.code -ne 0) { $memo += " | exit=$($r.code)" }
    if ($r.tail) { $memo += " | " + ($r.tail -replace "\|", "/" -replace "`n", " ") }
    Add-Content -LiteralPath $qaPath -Encoding UTF8 -Value "| verify:$($v.name) | $status | $now | $memo |"
    $checkSummary += "$($v.name)=$status"
}

# METRICS.md 카운터.
$verifyPass = $runChecks - $failedChecks
if (Test-Path -LiteralPath $metricsPath) {
    Add-Content -LiteralPath $metricsPath -Encoding UTF8 -Value "| $now | verify 실행=$runChecks 통과=$verifyPass 실패=$failedChecks |"
}

# 수정 파일 행(MODIFIED_FILES) + git status 보완.
$modifiedRows = @()
if (Test-Path -LiteralPath $modifiedPath) {
    $modifiedRows = Get-Content -LiteralPath $modifiedPath -Encoding UTF8 | Where-Object { $_ -match '^\| \d{4}-\d{2}-\d{2}' }
}

# QA 행(verify 포함) + 모델이 돌린 검증 행.
$qaRows = @()
if (Test-Path -LiteralPath $qaPath) {
    $qaRows = Get-Content -LiteralPath $qaPath -Encoding UTF8 | Where-Object { $_ -match '^\| .+ \| .+ \| \d{4}-\d{2}-\d{2}' }
}

# 보고서 마커(## security-reviewer 보고) 존재 여부.
$hasSecurityReport = $false
if (Test-Path -LiteralPath $qaPath) {
    $qaContent = Get-Content -LiteralPath $qaPath -Encoding UTF8
    foreach ($l in $qaContent) {
        if ($l -match '^##\s+security-reviewer\s+보고') { $hasSecurityReport = $true }
    }
}

# 보안 관련 수정 파일 감지.
$securityKeywords = 'auth|login|token|password|secret|credential|인증|권한|비밀|토큰'
$hasSecurityChange = $false
foreach ($row in $modifiedRows) {
    if ($row -match "(?i)$securityKeywords") { $hasSecurityChange = $true; break }
}

$reasons = @()

# 게이트 1: verify 검사 실패. reviewer/tester 서브에이전트 보고 요구.
if ($failedChecks -gt 0) {
    $reasons += "verify.toml 검사 $failedChecks 건 실패($checkSummary). 실패한 검사를 수정하고 reviewer/tester 서브에이전트 실행 후 QA.md에 ## reviewer 보고(또는 ## tester 보고)를 추가하세요."
}

# 게이트 2: 보안 관련 수정인데 security-reviewer 보고 마커 없음.
if ($hasSecurityChange -and -not $hasSecurityReport) {
    $reasons += "인증/권한/비밀정보 관련 파일이 수정됐습니다. security-reviewer 서브에이전트 실행 후 QA.md에 ## security-reviewer 보고를 추가하세요."
}

# 게이트 3: CHECKLIST 미완료.
if (Test-Path -LiteralPath $checklistPath) {
    $openItems = Select-String -LiteralPath $checklistPath -Encoding UTF8 -Pattern '^\s*-\s*\[\s\]'
    if ($openItems.Count -gt 0) {
        $reasons += 'CHECKLIST.md에 미완료 항목(- [ ])이 남아 있습니다.'
    }
}

# 게이트 4: 모델이 돌린 검증(QA 행) 중 실패/확인 필요.
$failedQa = @()
foreach ($row in $qaRows) {
    $cols = $row -split '\|'
    if ($cols.Count -ge 3) {
        $resultCell = $cols[2].Trim()
        if ($resultCell -match '실패|확인 필요') { $failedQa += $row }
    }
}
if ($failedQa.Count -gt 0) {
    $reasons += 'QA.md에 실패/확인 필요 검증 행이 남아 있습니다. tester 서브에이전트로 검증 보완 후 결과를 반영하세요.'
}

# 보조 안내: 수정 파일 있고 verify 통과 + 보안 아닌 경우 reviewer 권고(비강제).
if ($modifiedRows.Count -gt 0 -and $failedChecks -eq 0 -and -not $hasSecurityChange) {
    $reasons += "수정 파일이 $($modifiedRows.Count)건 있습니다. 품질 강화를 위해 reviewer 서브에이전트(code review) 실행을 권장합니다."
}

# 루프/토큰 과사용 방지(A+B+C):
#   A. 게이트당 차단 한도 = 2회.
#   B. 세션 전역 차단 캡(SESSION_BLOCK_CAP). 누적 차단 수가 이 값을 넘으면 모든 게이트 advisory 전환(더 이상 block 안 함).
#   C. 한도 도달 시 자동 해제가 아니라 '사용자에게 진행 여부 확인' block. 사용자 응답 후 통과.
$utf8 = [System.Text.UTF8Encoding]::new($false)
$GATE_BLOCK_LIMIT = 2
$SESSION_BLOCK_CAP = 8
$sessionBlocksPath = Join-Path $memoryDir '.session_blocks'

$blockCount = 0
$lastReason = ''
$lastAsked = ''
if (Test-Path -LiteralPath $statePath) {
    $state = [System.IO.File]::ReadAllText($statePath, $utf8)
    if ($state -match '(?m)^count=(\d+)') { $blockCount = [int]$matches[1] }
    if ($state -match '(?m)^reason=(.*)$') { $lastReason = $matches[1] }
    if ($state -match '(?m)^asked=(.*)$') { $lastAsked = $matches[1] }
}

# 세션 전역 차단 수.
$sessionBlocks = 0
if (Test-Path -LiteralPath $sessionBlocksPath) {
    $sb = [System.IO.File]::ReadAllText($sessionBlocksPath, $utf8)
    if ($sb -match '(\d+)') { $sessionBlocks = [int]$matches[1] }
}

$reasonJoined = $reasons -join ' '

# B: 세션 전역 캡 초과 → 모든 게이트 advisory 전환(block 안 함). verify 결과는 이미 QA 에 기록됐다.
if ($sessionBlocks -ge $SESSION_BLOCK_CAP) {
    if (Test-Path -LiteralPath $statePath) { Remove-Item -LiteralPath $statePath -Force }
    $payload = @{
        continue = $true
        hookSpecificOutput = @{
            hookEventName = 'Stop'
            additionalContext = "[Stop] 세션 차단 한도($SESSION_BLOCK_CAP)에 도달해 모든 게이트를 advisory 로 전환합니다. 더 이상 block 하지 않습니다. 남은 위험을 수동으로 확인해 최종 답변에 명시하세요."
        }
    }
    Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)
    exit
}

if ($reasons.Count -gt 0) {
    if ($reasonJoined -eq $lastReason) {
        $blockCount = $blockCount + 1
    } else {
        $blockCount = 1
        $lastAsked = ''
    }

    # C: 이미 같은 사유로 사용자 확인을 요청했으면 → 사용자가 응답한 것으로 보고 통과.
    if ($blockCount -ge $GATE_BLOCK_LIMIT -and $lastAsked -eq $reasonJoined) {
        if (Test-Path -LiteralPath $statePath) { Remove-Item -LiteralPath $statePath -Force }
        $payload = @{ continue = $true }
        Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)
        exit
    }

    # 세션 전역 차단 수 증가(block 결정마다).
    $sessionBlocks = $sessionBlocks + 1
    [System.IO.File]::WriteAllText($sessionBlocksPath, "$sessionBlocks", $utf8)

    if ($blockCount -ge $GATE_BLOCK_LIMIT) {
        # C: 한도 도달 → 사용자에게 진행 여부 확인 block(자동 해제 아님).
        [System.IO.File]::WriteAllText($statePath, "count=$blockCount`nreason=$reasonJoined`nasked=$reasonJoined", $utf8)
        $askMsg = "게이트가 2회 차단했습니다. 사용자에게 진행 여부를 확인하세요. 사유: $reasonJoined. 사용자가 승인하면 그대로 완료하고, 거부하면 해당 작업을 중단하세요. (자동 해제 대신 사용자 확인으로 전환 - 토큰 낭비 방지)"
        $payload = @{ decision = 'block'; reason = $askMsg }
    } else {
        [System.IO.File]::WriteAllText($statePath, "count=$blockCount`nreason=$reasonJoined`nasked=", $utf8)
        $payload = @{ decision = 'block'; reason = $reasonJoined }
    }
} else {
    if (Test-Path -LiteralPath $statePath) { Remove-Item -LiteralPath $statePath -Force }
    $payload = @{ continue = $true }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)