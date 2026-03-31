#!/usr/bin/env bash
set -euo pipefail

# test-check-freeze.sh — Unit tests for check-freeze.sh hook
# Usage: bash tests/test-check-freeze.sh [path/to/check-freeze.sh]
#
# Expects check-freeze.sh to be in the same directory as this script,
# or passed as the first argument.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="${1:-$SCRIPT_DIR/../templates/.claude/hooks/check-freeze.sh}"

if [ ! -f "$HOOK" ]; then
  echo "[error] Hook not found: $HOOK"
  echo "        Run from ai-research-env/ or pass hook path as argument."
  exit 1
fi

PASS=0
FAIL=0

assert_deny() {
  local description="$1"
  local input="$2"
  local result
  result=$(echo "$input" | bash "$HOOK")
  if echo "$result" | grep -q '"permissionDecision":"deny"'; then
    echo "  [PASS] $description"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $description"
    echo "         Expected: deny"
    echo "         Got: $result"
    FAIL=$((FAIL + 1))
  fi
}

assert_allow() {
  local description="$1"
  local input="$2"
  local result
  result=$(echo "$input" | bash "$HOOK")
  if [ "$result" = "{}" ]; then
    echo "  [PASS] $description"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $description"
    echo "         Expected: {}"
    echo "         Got: $result"
    FAIL=$((FAIL + 1))
  fi
}

PROJECT_ROOT="$(pwd)"

echo "=== test-check-freeze.sh ==="
echo "Hook: $HOOK"
echo "Project root: $PROJECT_ROOT"
echo ""

# Test 1: Block edit inside frozen profiling directory
assert_deny \
  "Block: edit inside profiling/results/" \
  "{\"tool_input\":{\"file_path\":\"$PROJECT_ROOT/profiling/results/run_001.json\"}}"

# Test 2: Block edit inside frozen simulation directory
assert_deny \
  "Block: edit inside simulation/results/" \
  "{\"tool_input\":{\"file_path\":\"$PROJECT_ROOT/simulation/results/output.csv\"}}"

# Test 3: Allow edit outside frozen directories
assert_allow \
  "Allow: edit inside simulation/scripts/" \
  "{\"tool_input\":{\"file_path\":\"$PROJECT_ROOT/simulation/scripts/run.py\"}}"

# Test 4: Allow empty file_path (no path to check)
assert_allow \
  "Allow: empty file_path" \
  "{\"tool_input\":{}}"

# Test 5: Block path that equals frozen dir exactly (not just prefix)
assert_deny \
  "Block: file_path == profiling/results (exact match)" \
  "{\"tool_input\":{\"file_path\":\"$PROJECT_ROOT/profiling/results\"}}"

# Test 6: Allow path that starts with frozen dir name but is different directory
assert_allow \
  "Allow: profiling/results-backup/ (not frozen)" \
  "{\"tool_input\":{\"file_path\":\"$PROJECT_ROOT/profiling/results-backup/file.json\"}}"

# Test 7: grep-primary parsing still works for standard JSON
assert_deny \
  "Block: grep-parsed path in profiling/results/" \
  "{\"tool_input\":{\"file_path\":\"$PROJECT_ROOT/profiling/results/data.csv\"}}"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
