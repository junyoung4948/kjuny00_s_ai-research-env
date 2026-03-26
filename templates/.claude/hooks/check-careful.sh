#!/usr/bin/env bash
set -euo pipefail

# Careful hook: Detect dangerous commands and ask for user confirmation
# Inspired by gstack careful pattern

INPUT=$(cat)

# Extract command from tool_input — Python primary (handles escaped quotes correctly)
COMMAND=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("tool_input",{}).get("command",""))' 2>/dev/null || true)

# grep fallback (for environments without Python)
if [ -z "$COMMAND" ]; then
  COMMAND=$(printf '%s' "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)
fi

# No command found — allow
if [ -z "$COMMAND" ]; then
  echo '{}'
  exit 0
fi

# Safe exception patterns (no warning for these)
SAFE_PATTERNS=(
  "rm -rf __pycache__"
  "rm -rf .pytest_cache"
  "rm -rf node_modules"
  "rm -rf .next"
  "rm -rf dist"
  "rm -rf build"
  "rm -rf .mypy_cache"
)

for SAFE in "${SAFE_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$SAFE"* ]]; then
    echo '{}'
    exit 0
  fi
done

# Dangerous pattern detection
if [[ "$COMMAND" =~ rm[[:space:]]+-r[f]?[[:space:]] ]] || [[ "$COMMAND" =~ rm[[:space:]]+-fr[[:space:]] ]]; then
  printf '{"permissionDecision":"ask","message":"[careful] Destructive: recursive delete (rm -r). This permanently removes files. Are you sure?"}\n'
  exit 0
fi

if [[ "$COMMAND" == *"git reset --hard"* ]]; then
  printf '{"permissionDecision":"ask","message":"[careful] Destructive: git reset --hard discards all uncommitted changes."}\n'
  exit 0
fi

if [[ "$COMMAND" == *"git push -f"* ]] || [[ "$COMMAND" == *"git push --force"* ]]; then
  printf '{"permissionDecision":"ask","message":"[careful] Destructive: force push can overwrite remote history."}\n'
  exit 0
fi

if [[ "$COMMAND" == *"kill -9"* ]]; then
  printf '{"permissionDecision":"ask","message":"[careful] Destructive: kill -9 forcefully terminates a process without cleanup."}\n'
  exit 0
fi

if [[ "$COMMAND" =~ DROP[[:space:]]+TABLE ]] || [[ "$COMMAND" =~ DROP[[:space:]]+DATABASE ]]; then
  printf '{"permissionDecision":"ask","message":"[careful] Destructive: SQL DROP command detected."}\n'
  exit 0
fi

if [[ "$COMMAND" == *"git clean -f"* ]]; then
  printf '{"permissionDecision":"ask","message":"[careful] Destructive: git clean -f removes untracked files permanently."}\n'
  exit 0
fi

# No dangerous patterns — allow
echo '{}'
