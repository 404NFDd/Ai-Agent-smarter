# Windows PowerShell 5.1에서 한글이 깨지지 않도록 이 파일은 UTF-8 with BOM으로 저장한다.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$skillsDir = Join-Path $projectRoot '.agents/skills'
$memoryDir = Join-Path $projectRoot '.codex-memory'
$planRequiredPath = Join-Path $memoryDir '.plan_required'
$planPath = Join-Path $memoryDir 'PLAN.md'
$planGateState = Join-Path $memoryDir '.plan_gate_state'

$raw = [Console]::In.ReadToEnd().TrimStart([char]0xFEFF)
$toolName = ''
$toolCommand = ''
$patchText = ''
$skills = @()

try {
    $inputData = $raw | ConvertFrom-Json -ErrorAction Stop
    $toolName = [string]$inputData.tool_name
    $toolCommand = [string]$inputData.tool_input.command
    $patchText = [string]$inputData.tool_input.input
} catch {
    $toolName = ''
    $toolCommand = ''
    $patchText = ''
}

$toolText = "$toolName $toolCommand"

function Add-Skill {
    param([string]$Path)
    if ($script:skills.Count -lt 3 -and $script:skills -notcontains $Path) {
        $script:skills += $Path
    }
}

# apply_patch 대상 파일 경로 추출(post_tool_use 와 동일 로직).
function Get-PatchedFilePaths {
    param([string]$PatchText)
    $paths = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrWhiteSpace($PatchText)) { return $paths }
    foreach ($line in ($PatchText -split "`n")) {
        if ($line -match '^\*\*\*\s+(?:Update|Add|Delete)\s+File:\s*(.+?)\s*$') {
            $paths.Add($matches[1])
        } elseif ($line -match '^\+\+\+\s+b/(.+?)\s*$') {
            $paths.Add($matches[1])
        }
    }
    return $paths
}

# MAP.toml 에서 path/content 매칭용 규칙 로드.
function Get-MapRules {
    param([string]$Section)
    $mapPath = Join-Path $skillsDir 'MAP.toml'
    $rules = @()
    if (-not (Test-Path -LiteralPath $mapPath)) { return $rules }
    $sectionName = ''
    $current = $null
    foreach ($line in (Get-Content -LiteralPath $mapPath -Encoding UTF8)) {
        $t = $line.Trim()
        if ($t -eq '' -or $t.StartsWith('#')) { continue }
        if ($t -match '^\[\[(.+)\]\]$') {
            if ($current) { $rules += ,$current }
            $sectionName = $matches[1].Trim()
            $current = @{ section = $sectionName; pattern = ''; skill = '' }
            continue
        }
        if ($current -and $t -match '^(\w+)\s*=\s*(.*)$') {
            $val = $matches[2].Trim().Trim('"').Trim("'")
            # TOML basic string 언이스케이프(수동 파서 보강).
            $val = $val -replace '\\\\', '\' -replace '\\"', '"'
            if ($matches[1] -eq 'pattern') { $current.pattern = $val }
            elseif ($matches[1] -eq 'skill') { $current.skill = $val }
        }
    }
    if ($current) { $rules += ,$current }
    return ($rules | Where-Object { $_.section -eq $Section } | Where-Object { $_.pattern -and $_.skill })
}

# glob 을 정규식으로 변환: ** -> .*, * -> [^/]* , 정규식 메타문자는 이스케이프.
function ConvertFrom-Glob {
    param([string]$Glob)
    $sb = New-Object System.Text.StringBuilder
    $i = 0
    $meta = [System.Collections.Generic.HashSet[char]]::new([char[]]('.\+()[]{}^$|'))
    while ($i -lt $Glob.Length) {
        $c = $Glob[$i]
        if ($c -eq '*') {
            if ($i + 1 -lt $Glob.Length -and $Glob[$i + 1] -eq '*') {
                [void]$sb.Append('.*'); $i += 2
            } else {
                [void]$sb.Append('[^/]*'); $i += 1
            }
        } elseif ($meta.Contains($c)) {
            [void]$sb.Append('\'); [void]$sb.Append($c); $i += 1
        } else {
            [void]$sb.Append($c); $i += 1
        }
    }
    return $sb.ToString()
}

# 스킬 본문 주입(강제 읽기).
function Get-SkillContent {
    param([string]$SkillName, [int]$Budget)
    $skillFile = Join-Path $skillsDir "$SkillName/SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile)) { return '' }
    $content = Get-Content -LiteralPath $skillFile -Raw -Encoding UTF8
    if ($content.Length -gt $Budget) { $content = $content.Substring(0, $Budget) + "...(이후 생략)" }
    return $content
}

# 1) 계획 게이트(C 항목 5): apply_patch 시 .plan_required 상태가 있고 PLAN.md 가 그 이후에
#    갱신되지 않았으면 1회 차단. 3회 동일 차단 시 수동 전환.
function Test-PlanGate {
    if ($toolName -ne 'apply_patch') { return $null }
    if (-not (Test-Path -LiteralPath $planRequiredPath)) { return $null }
    $requiredTime = [datetime]([System.IO.File]::ReadAllText($planRequiredPath, [System.Text.UTF8Encoding]::new($false)).Trim())
    # PLAN.md 가 존재하고 plan_required 시점보다 이후에 갱신됐으면 게이트 해제.
    if (Test-Path -LiteralPath $planPath) {
        $planMtime = (Get-Item -LiteralPath $planPath).LastWriteTime
        if ($planMtime -ge $requiredTime) {
            Remove-Item -LiteralPath $planRequiredPath -Force -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $planGateState) { Remove-Item -LiteralPath $planGateState -Force -ErrorAction SilentlyContinue }
            return $null
        }
    }
    # 차단 사유 집계 + 루프/토큰 과사용 방지(A+B+C). 게이트당 한도 2, 세션 전역 캡 8, 한도 시 사용자 확인.
    $reason = '큰 작업이 감지되었습니다. 구현(apply_patch) 전에 planner 서브에이전트로 계획을 세우고 .codex-memory/PLAN.md 를 먼저 저장하세요. PLAN.md 저장 후에는 자동으로 게이트가 해제됩니다.'
    $GATE_BLOCK_LIMIT = 2
    $SESSION_BLOCK_CAP = 8
    $sessionBlocksPath = Join-Path $memoryDir '.session_blocks'
    $utf8 = [System.Text.UTF8Encoding]::new($false)

    # B: 세션 전역 차단 수.
    $sessionBlocks = 0
    if (Test-Path -LiteralPath $sessionBlocksPath) {
        $sb = [System.IO.File]::ReadAllText($sessionBlocksPath, $utf8)
        if ($sb -match '(\d+)') { $sessionBlocks = [int]$matches[1] }
    }
    if ($sessionBlocks -ge $SESSION_BLOCK_CAP) {
        Remove-Item -LiteralPath $planRequiredPath -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $planGateState) { Remove-Item -LiteralPath $planGateState -Force -ErrorAction SilentlyContinue }
        return @{ warn = "세션 차단 한도($SESSION_BLOCK_CAP)에 도달해 계획 게이트를 advisory 로 전환합니다. 수동으로 PLAN.md 를 확인하고 위험을 답변에 명시하세요." }
    }

    $count = 0
    $lastReason = ''
    $lastAsked = ''
    if (Test-Path -LiteralPath $planGateState) {
        $st = [System.IO.File]::ReadAllText($planGateState, $utf8)
        if ($st -match '(?m)^count=(\d+)') { $count = [int]$matches[1] }
        if ($st -match '(?m)^reason=(.*)$') { $lastReason = $matches[1] }
        if ($st -match '(?m)^asked=(.*)$') { $lastAsked = $matches[1] }
    }
    if ($reason -eq $lastReason) { $count += 1 } else { $count = 1; $lastAsked = '' }

    # C: 같은 사유로 이미 사용자 확인을 요청했으면 → 사용자 응답한 것으로 보고 통과(게이트 해제).
    if ($count -ge $GATE_BLOCK_LIMIT -and $lastAsked -eq $reason) {
        Remove-Item -LiteralPath $planRequiredPath -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $planGateState) { Remove-Item -LiteralPath $planGateState -Force -ErrorAction SilentlyContinue }
        return $null
    }

    # 세션 전역 차단 수 증가.
    $sessionBlocks = $sessionBlocks + 1
    [System.IO.File]::WriteAllText($sessionBlocksPath, "$sessionBlocks", $utf8)

    if ($count -ge $GATE_BLOCK_LIMIT) {
        [System.IO.File]::WriteAllText($planGateState, "count=$count`nreason=$reason`nasked=$reason", $utf8)
        return @{ block = "계획 게이트가 2회 차단했습니다. 사용자에게 진행 여부를 확인하세요. 사유: $reason 사용자가 승인하면 PLAN.md 없이 진행하고, 거부하면 계획 작성으로 돌아가세요. (자동 해제 대신 사용자 확인으로 전환 - 토큰 낭비 방지)" }
    }
    [System.IO.File]::WriteAllText($planGateState, "count=$count`nreason=$reason`nasked=", $utf8)
    return @{ block = $reason }
}

$planGate = Test-PlanGate
if ($planGate -and $planGate.block) {
    $payload = @{
        decision = 'block'
        reason = $planGate.block
    }
    Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)
    exit
}

# 2) 기존 Bash 위험 작업 키워드 라우팅 유지.
if ($toolText -match '(?i)\brm\b|remove-item|del\b|erase\b|삭제|제거') {
    Add-Skill '.agents/skills/git-workflow/SKILL.md'
}
if ($toolText -match '(?i)migration|migrate|schema|db|database|마이그레이션|스키마') {
    Add-Skill '.agents/skills/database-migration/SKILL.md'
}
if ($toolText -match '(?i)install|add package|npm|pnpm|yarn|pip|cargo|lockfile|패키지|의존성|설치') {
    Add-Skill '.agents/skills/dependency-management/SKILL.md'
}
if ($toolText -match '(?i)deploy|release|publish|rollback|배포|릴리즈|롤백') {
    Add-Skill '.agents/skills/release-deploy/SKILL.md'
}
if ($toolText -match '(?i)secret|token|password|auth|permission|보안|시크릿|인증|권한') {
    Add-Skill '.agents/skills/security/SKILL.md'
}
if ($toolText -match '(?i)timeout|retry|rate limit|quota|idempotency|타임아웃|재시도|멱등|장애') {
    Add-Skill '.agents/skills/resilience/SKILL.md'
}
if ($toolText -match '(?i)i18n|locale|timezone|currency|date format|다국어|로케일|시간대|통화') {
    Add-Skill '.agents/skills/i18n-time-currency/SKILL.md'
}

# 3) 작업 위치 조건(B 항목 2): apply_patch 대상 경로 → MAP.toml path 매칭.
if ($toolName -eq 'apply_patch') {
    $targetPaths = Get-PatchedFilePaths -PatchText $patchText
    $pathRules = Get-MapRules -Section 'path'
    foreach ($p in $targetPaths) {
        foreach ($rule in $pathRules) {
            $regex = ConvertFrom-Glob -Glob $rule.pattern
            if ($p -match "^$regex$") {
                Add-Skill ".agents/skills/$($rule.skill)/SKILL.md"
            }
        }
    }
}

# 4) 파일 내용 조건(B 항목 2): apply_patch 대상 파일 본문 패턴 → MAP.toml content 매칭.
if ($toolName -eq 'apply_patch' -and $patchText) {
    $contentRules = Get-MapRules -Section 'content'
    foreach ($rule in $contentRules) {
        if ($patchText -match $rule.pattern) {
            Add-Skill ".agents/skills/$($rule.skill)/SKILL.md"
        }
    }
}

# 강제 읽기(B 항목 1): 매칭 skill 본문 주입.
$lines = @('[도구 사용 전 확인]')
if ($planGate -and $planGate.warn) { $lines += $planGate.warn }

$injectedAny = $false
$usedBudget = 0
$budget = 4000
foreach ($skillPath in $skills) {
    $skillName = ($skillPath -split '/')[-2]
    $remaining = $budget - $usedBudget
    if ($remaining -le 200) { break }
    $content = Get-SkillContent -SkillName $skillName -Budget $remaining
    if ($content) {
        $lines += ''
        $lines += "[skill 매뉴얼: $skillName]"
        $lines += $content
        $usedBudget += $content.Length
        $injectedAny = $true
    }
}
if (-not $injectedAny) {
    $lines += '위험 작업이면 관련 skill(.agents/skills/INDEX.md)과 사용자 승인 필요 여부를 확인하세요.'
}

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'PreToolUse'
        additionalContext = ($lines -join "`n")
    }
}

Write-Output ($payload | ConvertTo-Json -Depth 5 -Compress)