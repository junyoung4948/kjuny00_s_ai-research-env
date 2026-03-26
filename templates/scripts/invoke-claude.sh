#!/usr/bin/env bash
set -euo pipefail

# invoke-claude.sh — Antigravity에서 Claude Code를 비대화형으로 호출
#
# Antigravity(Gemini)가 작업 완료 후, Claude Code에게 review/validate/incorporate 등을
# 직접 요청할 때 사용합니다. SKILL.md의 claude-model 필드를 자동으로 읽어 적합한 모델을 선택합니다.
#
# Usage:
#   bash scripts/invoke-claude.sh \
#     --skill brainstorm \
#     --action review \
#     --artifact ".research/plans/hypothesis-cache-draft.md" \
#     --output ".research/plans/hypothesis-cache-review.md" \
#     [--context "추가 컨텍스트 설명"] \
#     [--model opus]  # SKILL.md 값 오버라이드
#
# Exit codes:
#   0 — 성공
#   1 — 인자 오류 또는 파일 미존재
#   2 — claude 명령 실행 실패

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Argument Parsing ---
SKILL=""
ACTION=""
ARTIFACT=""
OUTPUT=""
CONTEXT=""
MODEL_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)    SKILL="$2";    shift 2 ;;
    --action)   ACTION="$2";   shift 2 ;;
    --artifact) ARTIFACT="$2"; shift 2 ;;
    --output)   OUTPUT="$2";   shift 2 ;;
    --context)  CONTEXT="$2";  shift 2 ;;
    --model)    MODEL_OVERRIDE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: bash scripts/invoke-claude.sh --skill SKILL --action ACTION --artifact PATH --output PATH [--context TEXT] [--model MODEL]"
      echo ""
      echo "Options:"
      echo "  --skill     Skill context (brainstorm, experiment-design, validate, analyze, diagnose, document, reflect)"
      echo "  --action    Action type (review, incorporate, validate, analyze, custom)"
      echo "  --artifact  Path to the artifact to process (relative to project root)"
      echo "  --output    Path where Claude should write the result (relative to project root)"
      echo "  --context   Additional context for the request (optional)"
      echo "  --model     Override claude-model from SKILL.md (opus, sonnet) (optional)"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Validation ---
if [[ -z "$SKILL" || -z "$ACTION" || -z "$ARTIFACT" || -z "$OUTPUT" ]]; then
  echo "Error: --skill, --action, --artifact, --output are required."
  echo "Run with --help for usage."
  exit 1
fi

if [[ ! -f "$PROJECT_DIR/$ARTIFACT" ]]; then
  echo "Error: Artifact not found: $PROJECT_DIR/$ARTIFACT"
  exit 1
fi

# --- Model Selection ---
# Read claude-model from SKILL.md YAML frontmatter
SKILL_FILE="$PROJECT_DIR/.claude/skills/$SKILL/SKILL.md"
MODEL="sonnet"  # default fallback

if [[ -f "$SKILL_FILE" ]]; then
  # Extract claude-model from YAML frontmatter (between --- markers)
  EXTRACTED=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | grep '^claude-model:' | head -1 | awk '{print $2}')
  if [[ -n "$EXTRACTED" ]]; then
    MODEL="$EXTRACTED"
  fi
fi

# Override if explicitly specified
if [[ -n "$MODEL_OVERRIDE" ]]; then
  MODEL="$MODEL_OVERRIDE"
fi

# --- Construct Prompt ---
PROMPT="You are processing a cross-agent handoff request. Follow CLAUDE.md and AGENTS.md rules.

Action: $ACTION
Skill context: /$SKILL
Artifact to process: $ARTIFACT
Write output to: $OUTPUT

Instructions:
1. Read the artifact at '$ARTIFACT'.
2. Follow the /$SKILL skill's behavioral phases for the '$ACTION' action.
3. Write your output to '$OUTPUT'.
4. Apply all safety rules (3-Strike Rule, Anti-Slop, Evidence-Based Completion).
5. End with Completion Status (DONE/DONE_WITH_CONCERNS/BLOCKED/NEEDS_CONTEXT)."

if [[ -n "$CONTEXT" ]]; then
  PROMPT="$PROMPT

Additional context: $CONTEXT"
fi

# --- Execute ---
echo "[invoke-claude] Calling Claude Code..."
echo "  Skill:    $SKILL"
echo "  Action:   $ACTION"
echo "  Model:    $MODEL"
echo "  Artifact: $ARTIFACT"
echo "  Output:   $OUTPUT"

cd "$PROJECT_DIR"

if claude -p --model "$MODEL" "$PROMPT"; then
  echo "[invoke-claude] Success. Output written to: $OUTPUT"
  exit 0
else
  EXIT_CODE=$?
  echo "[invoke-claude] Failed with exit code: $EXIT_CODE"
  exit 2
fi
