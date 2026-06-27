#!/usr/bin/env bash
# user_prompt_submit.ps1 의 bash 미러(비Windows 환경용). jq 필요.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS="$ROOT/.agents/skills"
MEM="$ROOT/.codex-memory"
mkdir -p "$MEM"
NOW=$(date '+%Y-%m-%d %H:%M')

PROMPT=$(cat | jq -r '.prompt // empty' 2>/dev/null || echo '')

skills=()
addskill() { if [ "${#skills[@]}" -lt 3 ]; then for s in "${skills[@]}"; do [ "$s" = "$1" ] && return; done; skills+=("$1"); fi; }

printf '%s' "$PROMPT" | grep -qiE '처음|파악|구조|온보딩|살펴|둘러|readme|onboarding|overview|explore' && addskill codebase-onboarding
printf '%s' "$PROMPT" | grep -qiE 'bug|error|fail|fix|debug|repro|버그|오류|에러|실패|고쳐|재현|디버그' && addskill bugfix-debugging
printf '%s' "$PROMPT" | grep -qiE 'test|lint|typecheck|build|verify|qa|coverage|fixture|테스트|검증|빌드|타입체크' && addskill testing-qa
printf '%s' "$PROMPT" | grep -qiE 'implement|add|build|feature|plan|큰 작업|만들|추가|구현|계획|기능' && addskill implementation-planning
printf '%s' "$PROMPT" | grep -qiE 'api|server|route|controller|endpoint|service|rate limit|서버|엔드포인트|업로드' && addskill backend-api
printf '%s' "$PROMPT" | grep -qiE 'ui|screen|component|button|modal|css|layout|화면|컴포넌트|버튼|접근성|대비' && addskill frontend-ui
printf '%s' "$PROMPT" | grep -qiE 'db|database|migration|schema|table|query|마이그레이션|스키마|쿼리' && addskill database-migration
printf '%s' "$PROMPT" | grep -qiE 'security|token|secret|password|injection|xss|csrf|permission|auth|보안|인증|인가|권한|시크릿' && addskill security
printf '%s' "$PROMPT" | grep -qiE 'style|naming|comment|abstraction|convention|스타일|네이밍|주석|추상화|컨벤션' && addskill code-style
printf '%s' "$PROMPT" | grep -qiE 'git|branch|commit|pr|pull request|push|worktree|브랜치|커밋|푸시' && addskill git-workflow
printf '%s' "$PROMPT" | grep -qiE 'doc|docs|readme|changelog|문서|가이드' && addskill documentation
printf '%s' "$PROMPT" | grep -qiE 'review|검토|리뷰' && addskill review
printf '%s' "$PROMPT" | grep -qiE 'performance|perf|slow|cache|bottleneck|bundle|성능|느림|캐시|병목' && addskill performance
printf '%s' "$PROMPT" | grep -qiE 'timeout|retry|backoff|idempotency|rate limit|circuit breaker|resilience|타임아웃|재시도|멱등|장애|복원력' && addskill resilience
printf '%s' "$PROMPT" | grep -qiE 'i18n|locale|timezone|currency|date format|다국어|로케일|시간대|통화|번역' && addskill i18n-time-currency
printf '%s' "$PROMPT" | grep -qiE 'dependency|package|install|lockfile|upgrade|npm|pnpm|yarn|pip|cargo|패키지|의존성|설치' && addskill dependency-management
printf '%s' "$PROMPT" | grep -qiE 'release|deploy|version|tag|rollback|배포|릴리즈|버전|롤백' && addskill release-deploy
printf '%s' "$PROMPT" | grep -qiE 'log|metric|trace|tracing|sentry|observability|로그|메트릭|트레이싱|관측' && addskill observability
printf '%s' "$PROMPT" | grep -qiE 'refactor|cleanup|rework|리팩터링|정리' && addskill refactoring
printf '%s' "$PROMPT" | grep -qiE 'codex|agent|collaboration|handoff|질문|중간 보고|협업|에이전트' && addskill ai-agent-collaboration

islarge=0
printf '%s' "$PROMPT" | grep -qiE 'build|add|implement|refactor|structure|migration|rework|만들어줘|추가해줘|구현해줘|리팩터링|구조|마이그레이션|정리해줘' && islarge=1
isbugfix=0
printf '%s' "$PROMPT" | grep -qiE 'fix|고쳐|버그|오류|에러|재현|debug' && isbugfix=1

# 큰 작업 → plan_required 기록.
if [ "$islarge" = "1" ]; then
  printf '%s' "$NOW" > "$MEM/.plan_required"
fi

# skill 본문 주입(강제 읽기, 4KB 상한).
ctx="[Codex 운영 컨텍스트]"
injected=0
budget=4000
used=0
for s in "${skills[@]:-}"; do
  [ -z "$s" ] && continue
  remaining=$((budget - used))
  [ "$remaining" -le 200 ] && break
  f="$SKILLS/$s/SKILL.md"
  [ -f "$f" ] || continue
  content=$(head -c "$remaining" "$f")
  ctx="$ctx"$'\n'$'\n'"[skill 매뉴얼: $s]"$'\n'"$content"
  used=$((used + ${#content}))
  injected=1
done
[ "$injected" = "0" ] && ctx="$ctx"$'\n'"관련 skill이 있으면 작업 전에 .agents/skills/INDEX.md 를 확인하세요."

[ "$islarge" = "1" ] && ctx="$ctx"$'\n'$'\n'"[큰 작업 게이트] 구현(apply_patch) 전에 먼저 planner 서브에이전트로 계획을 세우고 .codex-memory/PLAN.md, CONTEXT.md, CHECKLIST.md 를 작성/갱신하세요. PLAN.md 를 저장하기 전에는 편집이 차단됩니다." && { [ ! -f "$MEM/PLAN.md" ] && ctx="$ctx"$'\n'"PLAN.md 가 없습니다. 큰 작업 시작 전 PLAN/CONTEXT/CHECKLIST 뼈대를 먼저 만드세요."; }
[ "$isbugfix" = "1" ] && ctx="$ctx"$'\n'"버그 수정은 재현 → 검증 흐름으로 진행하세요(bugfix-debugging skill 참조)."
ctx="$ctx"$'\n'"완료 전 QA.md 에 검증 결과와 남은 위험을 기록하세요."

[ -f "$MEM/METRICS.md" ] && printf '| %s | user_prompt skills=%s large=%s |\n' "$NOW" "${#skills[@]}" "$islarge" >> "$MEM/METRICS.md"

printf '%s' "$ctx" | jq -Rsc '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:.}}'