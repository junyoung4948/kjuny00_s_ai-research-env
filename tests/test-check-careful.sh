#!/usr/bin/env bash
set -euo pipefail

# test-check-careful.sh — Unit tests for check-careful.sh hook
# Usage: bash tests/test-check-careful.sh [path/to/check-careful.sh]
#
# Expects check-careful.sh to be in the same directory as this script,
# or passed as the first argument.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="${1:-$SCRIPT_DIR/../templates/.claude/hooks/check-careful.sh}"

if [ ! -f "$HOOK" ]; then
  echo "[error] Hook not found: $HOOK"
  echo "        Run from ai-research-env/ or pass hook path as argument."
  exit 1
fi

PASS=0
FAIL=0

assert_ask() {
  local description="$1"
  local input="$2"
  local result
  result=$(echo "$input" | bash "$HOOK")
  if echo "$result" | grep -q '"permissionDecision":"ask"'; then
    echo "  [PASS] $description"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $description"
    echo "         Expected: ask"
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

echo "=== test-check-careful.sh ==="
echo "Hook: $HOOK"
echo ""

# Test 1: Block dangerous rm -rf
assert_ask \
  "Ask: rm -rf / (dangerous recursive delete)" \
  "{\"tool_input\":{\"command\":\"rm -rf /tmp/test_dir\"}}"

# Test 2: Allow safe rm -rf pattern (cache cleanup)
assert_allow \
  "Allow: rm -rf __pycache__ (safe exception)" \
  "{\"tool_input\":{\"command\":\"rm -rf __pycache__\"}}"

# Test 3: Block git reset --hard
assert_ask \
  "Ask: git reset --hard (destructive)" \
  "{\"tool_input\":{\"command\":\"git reset --hard HEAD~1\"}}"

# Test 4: Allow empty command
assert_allow \
  "Allow: empty command field" \
  "{\"tool_input\":{}}"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
