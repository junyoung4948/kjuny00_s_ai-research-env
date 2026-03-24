#!/usr/bin/env bash
set -euo pipefail

# Guard/Freeze hook: profiling/results/ 와 simulation/results/ 수정 차단
# gstack freeze 패턴 차용 — 고정 경로 보호

INPUT=$(cat)

# file_path 추출 (Edit/Write 도구의 tool_input에서)
FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)

# Python fallback (이스케이프된 따옴표 처리)
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)
fi

# file_path가 없으면 허용
if [ -z "$FILE_PATH" ]; then
  echo '{}'
  exit 0
fi

# 절대 경로로 변환
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$(pwd)/$FILE_PATH"
fi

# 보호 디렉토리 목록
FROZEN_DIRS=(
  "profiling/results"
  "simulation/results"
)

PROJECT_ROOT="$(pwd)"

for FROZEN in "${FROZEN_DIRS[@]}"; do
  FROZEN_ABS="${PROJECT_ROOT}/${FROZEN}"
  if [[ "$FILE_PATH" == "$FROZEN_ABS"* ]]; then
    printf '{"permissionDecision":"deny","message":"[freeze] Blocked: %s is inside FROZEN directory (%s/). Experiment results must not be modified to ensure reproducibility."}\n' "$FILE_PATH" "$FROZEN"
    exit 0
  fi
done

# 보호 대상이 아니면 허용
echo '{}'
