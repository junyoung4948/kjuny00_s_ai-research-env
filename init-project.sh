#!/usr/bin/env bash
set -euo pipefail

# init-project.sh — Inject AI research environment template into a project
# Usage: cd /path/to/project && bash /path/to/ai-research-env/init-project.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
PROJECT_DIR="$(pwd)"

echo "=== AI Research Environment: Project Initialization ==="
echo "Project path: $PROJECT_DIR"
echo "Template path: $TEMPLATE_DIR"
echo ""

# Safety check
if [ "$PROJECT_DIR" = "$SCRIPT_DIR" ]; then
  echo "[error] Cannot run inside the ai-research-env directory itself."
  echo "        Navigate to your research project directory first."
  exit 1
fi

# 1. Create directory structure
echo "[1/8] Creating directory structure..."
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
  ".agents/skills/brainstorm"
  ".agents/skills/experiment-design"
  ".agents/skills/validate"
  ".agents/skills/analyze"
  ".agents/skills/diagnose"
  ".agents/skills/document"
  ".agents/skills/reflect"
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

# 2. Copy core config files (skip if already exists)
echo "[2/8] Copying core config files..."

copy_if_not_exists() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ]; then
    echo "  [skip] $(basename "$dst") — already exists"
  else
    cp "$src" "$dst"
    echo "  [done] $(basename "$dst")"
  fi
}

copy_if_not_exists "$TEMPLATE_DIR/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
copy_if_not_exists "$TEMPLATE_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
copy_if_not_exists "$TEMPLATE_DIR/GEMINI.md" "$PROJECT_DIR/GEMINI.md"

# 3. .gitignore, .aiexclude
echo "[3/8] .gitignore, .aiexclude..."
copy_if_not_exists "$TEMPLATE_DIR/.gitignore" "$PROJECT_DIR/.gitignore"
copy_if_not_exists "$TEMPLATE_DIR/.aiexclude" "$PROJECT_DIR/.aiexclude"

# 4. Claude config + hooks
echo "[4/8] Claude config + hooks..."
copy_if_not_exists "$TEMPLATE_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.json"
cp "$TEMPLATE_DIR/.claude/hooks/check-freeze.sh" "$PROJECT_DIR/.claude/hooks/check-freeze.sh"
cp "$TEMPLATE_DIR/.claude/hooks/check-careful.sh" "$PROJECT_DIR/.claude/hooks/check-careful.sh"
chmod +x "$PROJECT_DIR/.claude/hooks/check-freeze.sh"
chmod +x "$PROJECT_DIR/.claude/hooks/check-careful.sh"
echo "  [done] hooks (always overwritten with latest)"

# 5. Claude Skills
echo "[5/8] Claude Skills (SKILL.md)..."
for SKILL in brainstorm experiment-design validate analyze diagnose document reflect; do
  copy_if_not_exists "$TEMPLATE_DIR/.claude/skills/$SKILL/SKILL.md" "$PROJECT_DIR/.claude/skills/$SKILL/SKILL.md"
done

# 6. Antigravity Skills (mirror from Claude — single source)
echo "[6/8] Antigravity Skills (mirrored from Claude)..."
for SKILL in brainstorm experiment-design validate analyze diagnose document reflect; do
  copy_if_not_exists "$TEMPLATE_DIR/.claude/skills/$SKILL/SKILL.md" "$PROJECT_DIR/.agents/skills/$SKILL/SKILL.md"
done

# 7. .agents/ rules + workflows
echo "[7/8] .agents/ rules + workflows..."
copy_if_not_exists "$TEMPLATE_DIR/.agents/rules/research-roles.md" "$PROJECT_DIR/.agents/rules/research-roles.md"
copy_if_not_exists "$TEMPLATE_DIR/.agents/rules/anti-slop.md" "$PROJECT_DIR/.agents/rules/anti-slop.md"
copy_if_not_exists "$TEMPLATE_DIR/.agents/rules/safety.md" "$PROJECT_DIR/.agents/rules/safety.md"
copy_if_not_exists "$TEMPLATE_DIR/.agents/workflows/research-cycle.md" "$PROJECT_DIR/.agents/workflows/research-cycle.md"

# 8. .research/ initial content
echo "[8/8] .research/ initial content..."
copy_if_not_exists "$TEMPLATE_DIR/.research/context.md" "$PROJECT_DIR/.research/context.md"
copy_if_not_exists "$TEMPLATE_DIR/.research/wisdom.md" "$PROJECT_DIR/.research/wisdom.md"
copy_if_not_exists "$TEMPLATE_DIR/.research/decisions.md" "$PROJECT_DIR/.research/decisions.md"
copy_if_not_exists "$TEMPLATE_DIR/.research/scope-mode.txt" "$PROJECT_DIR/.research/scope-mode.txt"
copy_if_not_exists "$TEMPLATE_DIR/.research/pipeline-status.md" "$PROJECT_DIR/.research/pipeline-status.md"

echo ""
echo "=== Initialization Complete ==="
echo ""
echo "Project structure:"
echo "  $PROJECT_DIR/"
echo "  ├── AGENTS.md, CLAUDE.md, GEMINI.md"
echo "  ├── .claude/  (settings, hooks, skills)"
echo "  ├── .agents/  (rules, workflows, skills)"
echo "  ├── .research/ (context, wisdom, decisions, plans, feedback)"
echo "  ├── profiling/ (scripts, results[FROZEN])"
echo "  ├── simulation/ (configs, scripts, results[FROZEN])"
echo "  └── docs/sections/"
echo ""
echo "Next steps:"
echo "  1. Write your research topic in .research/context.md"
echo "  2. Check .research/scope-mode.txt (default: EXPLORATION)"
echo "  3. Start with /brainstorm in Claude Code or Antigravity"
