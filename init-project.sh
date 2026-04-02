#!/usr/bin/env bash

# Re-exec with bash if invoked via sh/dash (which ignores the shebang)
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -euo pipefail

# init-project.sh — Inject AI research environment template into a project
#
# Usage:
#   cd /path/to/project
#   bash /path/to/ai-research-env/init-project.sh            # First-time init
#   bash /path/to/ai-research-env/init-project.sh --update   # Update existing project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
PROJECT_DIR="$(pwd)"

# --- Parse arguments ---
UPDATE_MODE=false
for arg in "$@"; do
  case "$arg" in
    --update) UPDATE_MODE=true ;;
    --help|-h)
      echo "Usage: bash init-project.sh [--update]"
      echo ""
      echo "  (no flag)   First-time init — skip files that already exist"
      echo "  --update    Update existing project — overwrite template-owned files,"
      echo "              add new skills automatically, preserve .research/ state"
      exit 0
      ;;
  esac
done

MODE_LABEL="Init"
[ "$UPDATE_MODE" = true ] && MODE_LABEL="Update"

# --- Counters ---
COUNT_NEW=0; COUNT_UPD=0; COUNT_OK=0; COUNT_KEEP=0; COUNT_SKIP=0

# --- Copy functions ---

# Always overwrite: reports [new] / [upd] / [ok]
copy_always() {
  local src="$1" dst="$2"
  local rel="${dst#$PROJECT_DIR/}"
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo "  [new]  $rel"
    COUNT_NEW=$((COUNT_NEW + 1))
  elif cmp -s "$src" "$dst"; then
    echo "  [ok]   $rel"
    COUNT_OK=$((COUNT_OK + 1))
  else
    cp "$src" "$dst"
    echo "  [upd]  $rel — updated from template"
    COUNT_UPD=$((COUNT_UPD + 1))
  fi
}

# Smart: skip-if-exists in init mode, copy_always in update mode
copy_smart() {
  local src="$1" dst="$2"
  local rel="${dst#$PROJECT_DIR/}"
  if [ "$UPDATE_MODE" = true ]; then
    copy_always "$src" "$dst"
  else
    if [ -f "$dst" ]; then
      echo "  [skip] $rel — already exists"
      COUNT_SKIP=$((COUNT_SKIP + 1))
    else
      cp "$src" "$dst"
      echo "  [new]  $rel"
      COUNT_NEW=$((COUNT_NEW + 1))
    fi
  fi
}

# Never overwrite: preserves active research state, creates if new
copy_never_overwrite() {
  local src="$1" dst="$2"
  local rel="${dst#$PROJECT_DIR/}"
  if [ -f "$dst" ]; then
    echo "  [keep] $rel — research state preserved"
    COUNT_KEEP=$((COUNT_KEEP + 1))
  else
    cp "$src" "$dst"
    echo "  [new]  $rel"
    COUNT_NEW=$((COUNT_NEW + 1))
  fi
}

echo "=== AI Research Environment: Project $MODE_LABEL ==="
echo "Project path: $PROJECT_DIR"
echo "Template path: $TEMPLATE_DIR"
echo ""

# Safety check
if [ "$PROJECT_DIR" = "$SCRIPT_DIR" ]; then
  echo "[error] Cannot run inside the ai-research-env directory itself."
  echo "        Navigate to your research project directory first."
  exit 1
fi

# [1] Create directory structure
echo "[1] Creating directory structure..."

# Mirror template directory structure into project (cross-platform find)
while IFS= read -r dir; do
  [ -n "$dir" ] && mkdir -p "$PROJECT_DIR/$dir"
done < <(find "$TEMPLATE_DIR" -mindepth 1 -type d | sed "s|$TEMPLATE_DIR/||" | sort)

# Non-template project data directories
for dir in "profiling/scripts" "profiling/results" \
           "simulation/configs" "simulation/scripts" "simulation/results" \
           "docs/sections" "tests"; do
  mkdir -p "$PROJECT_DIR/$dir"
done

# [2] Core config files
echo "[2] Core config files (AGENTS.md, CLAUDE.md, GEMINI.md)..."
copy_smart "$TEMPLATE_DIR/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
copy_smart "$TEMPLATE_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
copy_smart "$TEMPLATE_DIR/GEMINI.md" "$PROJECT_DIR/GEMINI.md"

# [3] .gitignore, .aiexclude
echo "[3] .gitignore, .aiexclude..."
copy_smart "$TEMPLATE_DIR/.gitignore"  "$PROJECT_DIR/.gitignore"
copy_smart "$TEMPLATE_DIR/.aiexclude" "$PROJECT_DIR/.aiexclude"

# [4] Claude config + hooks
echo "[4] Claude config + hooks..."

# settings.json: smart merge (hooks from template, preserve MCP/permissions)
if [ "$UPDATE_MODE" = true ] && [ -f "$PROJECT_DIR/.claude/settings.json" ]; then
  # Try smart merge with jq (hooks only)
  if command -v jq &>/dev/null; then
    TEMP_SETTINGS=$(mktemp)
    if jq -s '.[0] * {hooks: .[1].hooks}' \
       "$PROJECT_DIR/.claude/settings.json" \
       "$TEMPLATE_DIR/.claude/settings.json" > "$TEMP_SETTINGS" 2>/dev/null; then
      if cmp -s "$TEMP_SETTINGS" "$PROJECT_DIR/.claude/settings.json"; then
        echo "  [ok]   .claude/settings.json (hooks up-to-date)"
        COUNT_OK=$((COUNT_OK + 1))
      else
        mv "$TEMP_SETTINGS" "$PROJECT_DIR/.claude/settings.json"
        echo "  [upd]  .claude/settings.json — hooks merged from template"
        COUNT_UPD=$((COUNT_UPD + 1))
      fi
    else
      echo "  [skip] .claude/settings.json — jq merge failed (check manually)"
      COUNT_SKIP=$((COUNT_SKIP + 1))
    fi
    rm -f "$TEMP_SETTINGS"
  else
    echo "  [skip] .claude/settings.json — jq not found (install jq for auto-merge)"
    echo "         Template: $TEMPLATE_DIR/.claude/settings.json"
    COUNT_SKIP=$((COUNT_SKIP + 1))
  fi
else
  if [ ! -f "$PROJECT_DIR/.claude/settings.json" ]; then
    cp "$TEMPLATE_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.json"
    echo "  [new]  .claude/settings.json"
    COUNT_NEW=$((COUNT_NEW + 1))
  else
    echo "  [skip] .claude/settings.json — already exists"
    COUNT_SKIP=$((COUNT_SKIP + 1))
  fi
fi

# Hooks: always overwrite (safety-critical infrastructure)
cp "$TEMPLATE_DIR/.claude/hooks/check-freeze.sh"  "$PROJECT_DIR/.claude/hooks/check-freeze.sh"
cp "$TEMPLATE_DIR/.claude/hooks/check-careful.sh" "$PROJECT_DIR/.claude/hooks/check-careful.sh"
cp "$TEMPLATE_DIR/.claude/hooks/pre-read-guard.sh" "$PROJECT_DIR/.claude/hooks/pre-read-guard.sh"
chmod +x "$PROJECT_DIR/.claude/hooks/check-freeze.sh"
chmod +x "$PROJECT_DIR/.claude/hooks/check-careful.sh"
chmod +x "$PROJECT_DIR/.claude/hooks/pre-read-guard.sh"
echo "  [done] hooks (always updated to latest)"

# [5] Claude Skills (dynamic discovery — no hardcoded list)
echo "[5] Claude Skills..."
for skill_file in "$TEMPLATE_DIR"/.claude/skills/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$(dirname "$skill_file")")"
  mkdir -p "$PROJECT_DIR/.claude/skills/$skill_name"
  copy_smart "$skill_file" "$PROJECT_DIR/.claude/skills/$skill_name/SKILL.md"
done

# [6] Antigravity Skills (dynamic discovery)
echo "[6] Antigravity Skills..."
for skill_file in "$TEMPLATE_DIR"/.agents/skills/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  skill_name="$(basename "$(dirname "$skill_file")")"
  mkdir -p "$PROJECT_DIR/.agents/skills/$skill_name"
  copy_smart "$skill_file" "$PROJECT_DIR/.agents/skills/$skill_name/SKILL.md"
done

# [6.5] Shared Skills (global 설치 권장)
echo "[6.5] Shared Skills..."
SHARED_COUNT=$(find "$TEMPLATE_DIR/shared-skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l || echo 0)
if [ "$SHARED_COUNT" -gt 0 ]; then
  echo "  [info] $SHARED_COUNT shared skills available"
  echo "         Run 'bash $SCRIPT_DIR/setup.sh' to install globally"
  echo "         (Recommended: shared skills work best as global skills)"
else
  echo "  [skip] No shared skills found"
fi

# [7] .agents/ rules + workflows (dynamic discovery)
echo "[7] .agents/ rules + workflows..."
for rule_file in "$TEMPLATE_DIR"/.agents/rules/*.md; do
  [ -f "$rule_file" ] || continue
  copy_smart "$rule_file" "$PROJECT_DIR/.agents/rules/$(basename "$rule_file")"
done
for wf_file in "$TEMPLATE_DIR"/.agents/workflows/*.md; do
  [ -f "$wf_file" ] || continue
  copy_smart "$wf_file" "$PROJECT_DIR/.agents/workflows/$(basename "$wf_file")"
done

# [8] Integration tests (always overwrite — test infrastructure)
echo "[8] Integration tests..."
if [ -d "$SCRIPT_DIR/tests" ]; then
  mkdir -p "$PROJECT_DIR/tests"
  cp "$SCRIPT_DIR/tests/test-check-freeze.sh"  "$PROJECT_DIR/tests/test-check-freeze.sh"
  cp "$SCRIPT_DIR/tests/test-check-careful.sh" "$PROJECT_DIR/tests/test-check-careful.sh"
  chmod +x "$PROJECT_DIR/tests/test-check-freeze.sh"
  chmod +x "$PROJECT_DIR/tests/test-check-careful.sh"
  echo "  [done] tests/ (hook unit tests)"
else
  echo "  [skip] tests/ not found in source"
fi

# [9] Scripts (dynamic discovery)
echo "[9] Scripts..."
for script_file in "$TEMPLATE_DIR"/scripts/*.sh; do
  [ -f "$script_file" ] || continue
  copy_smart "$script_file" "$PROJECT_DIR/scripts/$(basename "$script_file")"
  chmod +x "$PROJECT_DIR/scripts/$(basename "$script_file")" 2>/dev/null || true
done

# [10] Handoff protocol documentation
echo "[10] Handoff protocol..."
copy_smart "$TEMPLATE_DIR/.research/handoff/README.md" "$PROJECT_DIR/.research/handoff/README.md"

# [11] .research/ initial content — NEVER overwrite (active research state)
echo "[11] .research/ initial content..."
copy_never_overwrite "$TEMPLATE_DIR/.research/context.md"         "$PROJECT_DIR/.research/context.md"
copy_never_overwrite "$TEMPLATE_DIR/.research/wisdom.md"          "$PROJECT_DIR/.research/wisdom.md"
copy_never_overwrite "$TEMPLATE_DIR/.research/decisions.md"       "$PROJECT_DIR/.research/decisions.md"
copy_never_overwrite "$TEMPLATE_DIR/.research/scope-mode.txt"     "$PROJECT_DIR/.research/scope-mode.txt"
copy_never_overwrite "$TEMPLATE_DIR/.research/pipeline-status.md" "$PROJECT_DIR/.research/pipeline-status.md"


# [11.5] Generate project map (token efficiency)
echo "[11.5] Generating project map..."
if bash "$SCRIPT_DIR/scripts/generate-project-map.sh" "$PROJECT_DIR" 2>/dev/null; then
  echo "  [done] project-map.md"
else
  echo "  [warn] generate-project-map.sh failed (non-fatal)"
fi

# [12] Dynamic Model Selection bootstrap (idempotent, runs every time)
echo "[12] Dynamic Model Selection..."

DMS_OK=true

# 12a. Initial sync (if model-env.sh missing)
if [ ! -f "$HOME/.claude/model-env.sh" ]; then
  if command -v python3 &>/dev/null; then
    python3 "$SCRIPT_DIR/scripts/sync-models.py" && \
      echo "  [done] Initial model sync complete" || \
      { echo "  [warn] Model sync failed — check network"; DMS_OK=false; }
  else
    echo "  [warn] python3 not found — skipping model sync"
    DMS_OK=false
  fi
else
  echo "  [ok]   model-env.sh exists (last updated: $(date -r "$HOME/.claude/model-env.sh" '+%Y-%m-%d %H:%M'))"
fi

# 12b. .bashrc source injection
SHELL_RC=""
[ -f "$HOME/.zshrc" ]  && SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"

if [ -n "$SHELL_RC" ]; then
  if ! grep -q "model-env.sh" "$SHELL_RC" 2>/dev/null; then
    { echo ''; echo '# AI Research Env — Dynamic Model Selection'; \
      echo '[ -f ~/.claude/model-env.sh ] && source ~/.claude/model-env.sh'; } >> "$SHELL_RC"
    echo "  [done] Injected source into $SHELL_RC"
  else
    echo "  [ok]   $SHELL_RC already sources model-env.sh"
  fi
else
  echo "  [warn] .bashrc/.zshrc not found — add manually:"
  echo "         echo '[ -f ~/.claude/model-env.sh ] && source ~/.claude/model-env.sh' >> ~/.bashrc"
fi

# 12c. Cron registration
if crontab -l 2>/dev/null | grep -q "sync-models"; then
  echo "  [ok]   Hourly cron already registered"
else
  bash "$SCRIPT_DIR/scripts/install-cron.sh" > /dev/null && \
    echo "  [done] Hourly cron registered (10:00–20:00)" || \
    { echo "  [warn] Cron registration failed"; DMS_OK=false; }
fi

if [ "$DMS_OK" = true ]; then
  echo "  Dynamic Model Selection: active"
else
  echo "  Dynamic Model Selection: partial — check warnings above"
fi

echo ""
echo "=== $MODE_LABEL Complete ==="
printf "  New: %-3s  Updated: %-3s  Up-to-date: %-3s  Preserved: %-3s  Skipped: %s\n" \
  "$COUNT_NEW" "$COUNT_UPD" "$COUNT_OK" "$COUNT_KEEP" "$COUNT_SKIP"
echo ""

if [ "$UPDATE_MODE" = false ]; then
  echo "Project structure created at: $PROJECT_DIR/"
  echo "  ├── AGENTS.md, CLAUDE.md, GEMINI.md"
  echo "  ├── .claude/  (settings, hooks, skills incl. cross-review, pickup)"
  echo "  ├── .agents/  (rules, workflows, skills incl. cross-review, pickup)"
  echo "  ├── .research/ (context, wisdom, decisions, plans, feedback, handoff)"
  echo "  ├── scripts/  (invoke-claude.sh, create-handoff.sh)"
  echo "  ├── profiling/ (scripts, results[FROZEN])"
  echo "  ├── simulation/ (configs, scripts, results[FROZEN])"
  echo "  └── docs/sections/"
  echo ""
  echo "Next steps:"
  echo "  1. Write your research topic in .research/context.md"
  echo "  2. Check .research/scope-mode.txt (default: EXPLORATION)"
  echo "  3. Start with /brainstorm in Claude Code or Antigravity"
else
  if [ "$COUNT_UPD" -gt 0 ] || [ "$COUNT_NEW" -gt 0 ]; then
    echo "Changes applied. Run 'git diff' to review updates before committing."
  else
    echo "Everything already up to date."
  fi
fi
