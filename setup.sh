#!/usr/bin/env bash
set -euo pipefail

# setup.sh — 전역 설정 설치
# ai-research-env 레포에서 한 번만 실행하면 됩니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== AI Research Environment: 전역 설정 설치 ==="

# 1. Claude Code 전역 설정
CLAUDE_GLOBAL_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_GLOBAL_DIR"

if [ -f "$CLAUDE_GLOBAL_DIR/CLAUDE.md" ]; then
  echo "[skip] ~/.claude/CLAUDE.md 이미 존재합니다. 덮어쓰지 않습니다."
else
  cp "$SCRIPT_DIR/global/claude/CLAUDE.md" "$CLAUDE_GLOBAL_DIR/CLAUDE.md"
  echo "[done] ~/.claude/CLAUDE.md 설치 완료"
fi

if [ -f "$CLAUDE_GLOBAL_DIR/settings.json" ]; then
  echo "[skip] ~/.claude/settings.json 이미 존재합니다. 덮어쓰지 않습니다."
  echo "       수동으로 병합하세요: $SCRIPT_DIR/global/claude/settings.json"
else
  cp "$SCRIPT_DIR/global/claude/settings.json" "$CLAUDE_GLOBAL_DIR/settings.json"
  echo "[done] ~/.claude/settings.json 설치 완료"
fi

# 2. Gemini/Antigravity 전역 설정
# Antigravity는 ~/.gemini/ 또는 프로젝트별 설정을 사용합니다.
# 전역 GEMINI.md와 AGENTS.md는 참조용으로 안내만 합니다.
echo ""
echo "[info] Gemini 전역 설정 파일:"
echo "       - $SCRIPT_DIR/global/gemini/GEMINI.md"
echo "       - $SCRIPT_DIR/global/gemini/AGENTS.md"
echo "       Antigravity의 전역 설정 경로에 수동으로 복사하세요."

echo ""
echo "=== 설치 완료 ==="

# 3. Dynamic Model Selection 설정
echo ""
echo "=== Dynamic Model Selection 설정 ==="

# 3a. 초기 sync 실행
if command -v python3 &>/dev/null; then
  python3 "$SCRIPT_DIR/scripts/sync-models.py" && \
    echo "[done] 초기 모델 동기화 완료" || \
    echo "[warn] 모델 동기화 실패 (네트워크 확인 필요)"
else
  echo "[skip] python3이 없어 모델 동기화를 건너뜁니다."
fi

# 3b. cron 등록
bash "$SCRIPT_DIR/scripts/install-cron.sh" 2>/dev/null && \
  echo "[done] 1시간 단위 cron 등록 완료" || \
  echo "[warn] cron 등록 실패"

# 3c. 셸 프로파일에 source 추가
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
  if ! grep -q "model-env.sh" "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# AI Research Env — Dynamic Model Selection' >> "$SHELL_RC"
    echo '[ -f ~/.claude/model-env.sh ] && source ~/.claude/model-env.sh' >> "$SHELL_RC"
    echo "[done] ${SHELL_RC}에 model-env.sh source 추가 완료"
  else
    echo "[skip] ${SHELL_RC}에 이미 model-env.sh source가 존재합니다."
  fi
else
  echo "[warn] .bashrc/.zshrc를 찾을 수 없습니다. 수동으로 추가하세요:"
  echo "       echo '[ -f ~/.claude/model-env.sh ] && source ~/.claude/model-env.sh' >> ~/.bashrc"
fi

echo ""
echo "=== 완료 ==="
echo ""
echo "⚠️  현재 터미널에 즉시 적용하려면:"
echo "    source ~/.claude/model-env.sh"
echo ""
echo "다음 단계: 연구 프로젝트에 템플릿을 적용하세요."
echo "  cd /path/to/your/research-project"
echo "  bash $SCRIPT_DIR/init-project.sh"
