#!/usr/bin/env bash
set -euo pipefail

# Guard/Freeze hook: Block modifications to profiling/results/ and simulation/results/
# Inspired by gstack freeze pattern — protect fixed paths

INPUT=$(cat)

# Extract file_path from tool_input — Python primary (handles escaped quotes correctly)
FILE_PATH=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)

# grep fallback (for environments without Python)
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)
fi

# No file_path found — allow
if [ -z "$FILE_PATH" ]; then
  echo '{}'
  exit 0
fi

# Convert to absolute path
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$(pwd)/$FILE_PATH"
fi

# Protected directory list
FROZEN_DIRS=(
  "profiling/results"
  "simulation/results"
)

PROJECT_ROOT="$(pwd)"

for FROZEN in "${FROZEN_DIRS[@]}"; do
  FROZEN_ABS="${PROJECT_ROOT}/${FROZEN}"
  if [[ "$FILE_PATH" == "$FROZEN_ABS"/* ]] || [[ "$FILE_PATH" == "$FROZEN_ABS" ]]; then
    printf '{"permissionDecision":"deny","message":"[freeze] Blocked: %s is inside FROZEN directory (%s/). Experiment results must not be modified to ensure reproducibility."}\n' "$FILE_PATH" "$FROZEN"
    exit 0
  fi
done

# Not a protected path — allow
echo '{}'
