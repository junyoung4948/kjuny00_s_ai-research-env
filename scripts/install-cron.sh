#!/bin/bash
# install-cron.sh — Register sync-models.py as an hourly cron job
#
# Usage: bash install-cron.sh
# This will add (or update) a cron entry that runs sync-models.py every hour.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYNC_SCRIPT="${SCRIPT_DIR}/sync-models.py"
CRON_MARKER="# sync-models-dynamic-selection"
LOG_FILE="${HOME}/.claude/sync-models.log"

if [ ! -f "$SYNC_SCRIPT" ]; then
    echo "ERROR: sync-models.py not found at ${SYNC_SCRIPT}"
    exit 1
fi

# Remove existing entry if present, then add new one
(crontab -l 2>/dev/null | grep -v "${CRON_MARKER}") | {
    cat
    echo "0 10-20 * * * python3 ${SYNC_SCRIPT} >> ${LOG_FILE} 2>&1 ${CRON_MARKER}"
} | crontab -

echo "[install-cron] ✓ Registered hourly cron job for sync-models.py"
echo "[install-cron] Logs will be written to: ${LOG_FILE}"
echo "[install-cron] Verify with: crontab -l"
