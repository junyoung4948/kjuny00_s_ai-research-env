#!/usr/bin/env bash
set -euo pipefail

# create-handoff.sh — Handoff signal 파일 생성
#
# Agent가 상대방에게 작업을 요청할 때 signal JSON 파일을 생성합니다.
# 주로 Claude Code → Antigravity 방향에서 사용됩니다.
# (Antigravity → Claude 방향은 invoke-claude.sh로 직접 호출 가능)
#
# Usage:
#   bash scripts/create-handoff.sh \
#     --from claude --to antigravity \
#     --action review --skill experiment-design \
#     --artifact ".research/plans/experiment-cache-draft.md" \
#     [--context "실험 설계의 논리적 검증 요청"] \
#     [--requires-human]
#
# Output: .research/handoff/queue/{timestamp}-{from}-to-{to}-{action}.json

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
QUEUE_DIR="$PROJECT_DIR/.research/handoff/queue"

# --- Argument Parsing ---
FROM=""
TO=""
ACTION=""
SKILL=""
ARTIFACT=""
CONTEXT=""
REQUIRES_HUMAN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)     FROM="$2";     shift 2 ;;
    --to)       TO="$2";       shift 2 ;;
    --action)   ACTION="$2";   shift 2 ;;
    --skill)    SKILL="$2";    shift 2 ;;
    --artifact) ARTIFACT="$2"; shift 2 ;;
    --context)  CONTEXT="$2";  shift 2 ;;
    --requires-human) REQUIRES_HUMAN="true"; shift ;;
    -h|--help)
      echo "Usage: bash scripts/create-handoff.sh --from FROM --to TO --action ACTION --skill SKILL --artifact PATH [--context TEXT] [--requires-human]"
      echo ""
      echo "Options:"
      echo "  --from           Source agent (claude, antigravity)"
      echo "  --to             Target agent (claude, antigravity)"
      echo "  --action         Action type (review, incorporate, validate, analyze, custom)"
      echo "  --skill          Skill context (brainstorm, experiment-design, etc.)"
      echo "  --artifact       Path to the artifact (relative to project root)"
      echo "  --context        Description of the request (optional)"
      echo "  --requires-human Mark as requiring human approval (optional)"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Validation ---
if [[ -z "$FROM" || -z "$TO" || -z "$ACTION" || -z "$SKILL" || -z "$ARTIFACT" ]]; then
  echo "Error: --from, --to, --action, --skill, --artifact are required."
  echo "Run with --help for usage."
  exit 1
fi

# Ensure queue directory exists
mkdir -p "$QUEUE_DIR"

# --- Generate Signal ---
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
FILENAME="${TIMESTAMP}-${FROM}-to-${TO}-${ACTION}.json"
FILEPATH="$QUEUE_DIR/$FILENAME"
CREATED_AT=$(date -Iseconds)

# Use python3 for reliable JSON generation (pattern from check-freeze.sh)
python3 -c "
import json, sys

signal = {
    'id': '$TIMESTAMP',
    'from': '$FROM',
    'to': '$TO',
    'action': '$ACTION',
    'skill': '$SKILL',
    'artifact': '$ARTIFACT',
    'context': '''$CONTEXT''',
    'requires_human': $REQUIRES_HUMAN == 'true',
    'status': 'pending',
    'created_at': '$CREATED_AT'
}

# Clean up boolean
signal['requires_human'] = '$REQUIRES_HUMAN' == 'true'

with open('$FILEPATH', 'w') as f:
    json.dump(signal, f, indent=2, ensure_ascii=False)
" 2>/dev/null || {
  # Fallback: direct echo if python3 fails
  cat > "$FILEPATH" <<EOF
{
  "id": "$TIMESTAMP",
  "from": "$FROM",
  "to": "$TO",
  "action": "$ACTION",
  "skill": "$SKILL",
  "artifact": "$ARTIFACT",
  "context": "$CONTEXT",
  "requires_human": $REQUIRES_HUMAN,
  "status": "pending",
  "created_at": "$CREATED_AT"
}
EOF
}

echo "[create-handoff] Signal created: .research/handoff/queue/$FILENAME"
echo "  From:     $FROM"
echo "  To:       $TO"
echo "  Action:   $ACTION"
echo "  Skill:    $SKILL"
echo "  Artifact: $ARTIFACT"

if [[ "$REQUIRES_HUMAN" == "true" ]]; then
  echo "  [!] requires_human: true — 자동 처리되지 않음, 연구자 확인 필요"
fi

if [[ "$TO" == "antigravity" ]]; then
  echo ""
  echo "  Next: Antigravity에서 /pickup 실행하여 처리"
elif [[ "$TO" == "claude" ]]; then
  echo ""
  echo "  Next: Claude Code에서 /pickup 실행하거나, invoke-claude.sh로 직접 호출"
fi
