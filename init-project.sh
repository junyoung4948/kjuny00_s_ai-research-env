#!/usr/bin/env bash
set -euo pipefail

# init-project.sh — 연구 프로젝트에 AI 환경 템플릿 주입
# 사용법: cd /path/to/project && bash /path/to/ai-research-env/init-project.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
PROJECT_DIR="$(pwd)"

echo "=== AI Research Environment: 프로젝트 초기화 ==="
echo "프로젝트 경로: $PROJECT_DIR"
echo "템플릿 경로:   $TEMPLATE_DIR"
echo ""

# 안전 확인
if [ "$PROJECT_DIR" = "$SCRIPT_DIR" ]; then
  echo "[error] ai-research-env 디렉토리 자체에서는 실행할 수 없습니다."
  echo "        연구 프로젝트 디렉토리로 이동한 후 실행하세요."
  exit 1
fi

# 1. 디렉토리 구조 생성
echo "[1/7] 디렉토리 구조 생성..."
DIRS=(
  ".research/plans"
  ".research/feedback"
  ".research/retros"
  ".research/logs/profiling"
  ".research/logs/simulation"
  ".claude/skills/brainstorm"
  ".claude/skills/experiment-design"
  ".claude/skills/validate"
  ".claude/skills/analyze"
  ".claude/skills/diagnose"
  ".claude/skills/document"
  ".claude/skills/reflect"
  ".claude/hooks"
  ".agents/rules"
  ".agents/workflows"
  "profiling/scripts"
  "profiling/results"
  "simulation/configs"
  "simulation/scripts"
  "simulation/results"
  "docs/sections"
)

for DIR in "${DIRS[@]}"; do
  mkdir -p "$PROJECT_DIR/$DIR"
done

# 2. 핵심 설정 파일 복사 (충돌 방지: 기존 파일은 건너뜀)
echo "[2/7] 핵심 설정 파일 복사..."

copy_if_not_exists() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ]; then
    echo "  [skip] $(basename "$dst") — 이미 존재"
  else
    cp "$src" "$dst"
    echo "  [done] $(basename "$dst")"
  fi
}

copy_if_not_exists "$TEMPLATE_DIR/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
copy_if_not_exists "$TEMPLATE_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
copy_if_not_exists "$TEMPLATE_DIR/GEMINI.md" "$PROJECT_DIR/GEMINI.md"

# 3. .gitignore, .aiexclude
echo "[3/7] .gitignore, .aiexclude..."
copy_if_not_exists "$TEMPLATE_DIR/.gitignore" "$PROJECT_DIR/.gitignore"
copy_if_not_exists "$TEMPLATE_DIR/.aiexclude" "$PROJECT_DIR/.aiexclude"

# 4. Claude 설정 + hooks
echo "[4/7] Claude 설정 + hooks..."
copy_if_not_exists "$TEMPLATE_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.json"
cp "$TEMPLATE_DIR/.claude/hooks/check-freeze.sh" "$PROJECT_DIR/.claude/hooks/check-freeze.sh"
cp "$TEMPLATE_DIR/.claude/hooks/check-careful.sh" "$PROJECT_DIR/.claude/hooks/check-careful.sh"
chmod +x "$PROJECT_DIR/.claude/hooks/check-freeze.sh"
chmod +x "$PROJECT_DIR/.claude/hooks/check-careful.sh"
echo "  [done] hooks (항상 최신으로 덮어씀)"

# 5. Skills
echo "[5/7] Skills (SKILL.md)..."
for SKILL in brainstorm experiment-design validate analyze diagnose document reflect; do
  copy_if_not_exists "$TEMPLATE_DIR/.claude/skills/$SKILL/SKILL.md" "$PROJECT_DIR/.claude/skills/$SKILL/SKILL.md"
done

# 6. .agents/ rules + workflows
echo "[6/7] .agents/ rules + workflows..."
copy_if_not_exists "$TEMPLATE_DIR/.agents/rules/research-roles.md" "$PROJECT_DIR/.agents/rules/research-roles.md"
copy_if_not_exists "$TEMPLATE_DIR/.agents/workflows/research-cycle.md" "$PROJECT_DIR/.agents/workflows/research-cycle.md"

# 7. .research/ 초기 컨텐츠
echo "[7/7] .research/ 초기 컨텐츠..."
copy_if_not_exists "$TEMPLATE_DIR/.research/context.md" "$PROJECT_DIR/.research/context.md"
copy_if_not_exists "$TEMPLATE_DIR/.research/wisdom.md" "$PROJECT_DIR/.research/wisdom.md"
copy_if_not_exists "$TEMPLATE_DIR/.research/decisions.md" "$PROJECT_DIR/.research/decisions.md"
copy_if_not_exists "$TEMPLATE_DIR/.research/scope-mode.txt" "$PROJECT_DIR/.research/scope-mode.txt"
copy_if_not_exists "$TEMPLATE_DIR/.research/pipeline-status.md" "$PROJECT_DIR/.research/pipeline-status.md"

echo ""
echo "=== 초기화 완료 ==="
echo ""
echo "프로젝트 구조:"
echo "  $PROJECT_DIR/"
echo "  ├── AGENTS.md, CLAUDE.md, GEMINI.md"
echo "  ├── .claude/  (settings, hooks, skills)"
echo "  ├── .agents/  (rules, workflows, skills)"
echo "  ├── .research/ (context, wisdom, decisions, plans, feedback)"
echo "  ├── profiling/ (scripts, results[FROZEN])"
echo "  ├── simulation/ (configs, scripts, results[FROZEN])"
echo "  └── docs/sections/"
echo ""
echo "다음 단계:"
echo "  1. .research/context.md에 연구 주제를 작성하세요"
echo "  2. .research/scope-mode.txt를 확인하세요 (기본: EXPLORATION)"
echo "  3. Claude Code 또는 Antigravity에서 /brainstorm으로 시작하세요"
