#!/usr/bin/env bash
# pre-read-guard.sh
# Pre-Read Guard Hook - Bash implementation inspired by OpenWolf pre-read.ts
# Detects duplicate file reads and provides project-map information

set -uo pipefail

# Get session ID from hook input JSON
# Main session and sub-agents share the same session_id
get_session_id() {
    local json_input="${1:-}"

    if [[ -z "$json_input" ]]; then
        echo "default"
        return 0
    fi

    local session_id

    # Try jq first (most reliable)
    if command -v jq >/dev/null 2>&1; then
        session_id=$(echo "$json_input" | jq -r '.session_id // empty' 2>/dev/null)
        if [[ -n "$session_id" ]]; then
            echo "$session_id"
            return 0
        fi
    fi

    # Fallback to sed (works for single-line JSON)
    session_id=$(echo "$json_input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    if [[ -n "$session_id" ]]; then
        echo "$session_id"
        return 0
    fi

    # Last resort: default
    echo "default"
}

# Note: session_id is extracted from hook input JSON (official field)
# Main session and sub-agents share the same session_id automatically
readonly SCRIPT_NAME="${0##*/}"
readonly PROJECT_MAP=".research/project-map.md"
readonly LOG_MAX_AGE_DAYS=10

# Logging functions
log_info() {
    printf "📋 project-map: %s\n" "$*" >&2
}

log_warning() {
    printf "⚡ pre-read: %s\n" "$*" >&2
}

log_debug() {
    [[ "${DEBUG:-}" == "1" ]] && printf "[DEBUG] %s\n" "$*" >&2
}

# Extract file_path from JSON input
extract_file_path() {
    local json_input="$1"
    local file_path

    # Try jq first (most reliable, handles nested JSON)
    if command -v jq >/dev/null 2>&1; then
        file_path=$(echo "$json_input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
        if [[ -n "$file_path" ]]; then
            echo "$file_path"
            return 0
        fi
    fi

    # Fallback to sed (works for single-line JSON)
    file_path=$(echo "$json_input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

    echo "$file_path"
}

# Check if file was already read in this session
is_duplicate_read() {
    local file_path="$1"
    local session_log="$2"

    [[ -f "$session_log" ]] && grep -qx "$file_path" "$session_log" 2>/dev/null
}

# Get file info from project map
get_file_info_from_map() {
    local file_path="$1"
    local filename
    filename=$(basename "$file_path")

    if [[ ! -f "$PROJECT_MAP" ]]; then
        echo ""
        return
    fi

    # Extract directory path for section matching
    local dir_path
    dir_path=$(dirname "$file_path")

    # Search for the directory section in project-map
    # Format: ## path/to/directory
    local section_line
    section_line=$(grep -n "^## ${dir_path}\$" "$PROJECT_MAP" 2>/dev/null | head -1 | cut -d: -f1)

    if [[ -n "$section_line" ]]; then
        # Found exact section - search for filename until next section or max 20 lines
        local match
        match=$(sed -n "$((section_line + 1)),$((section_line + 20))p" "$PROJECT_MAP" 2>/dev/null | \
                awk '/^##/ {exit} /^\- `'"${filename}"'`/ {print; exit}' | \
                sed 's/^- `//' | sed 's/` — / — /')

        if [[ -n "$match" ]]; then
            echo "$match"
            return
        fi
    fi

    # Fallback: basename-only search (less accurate)
    # This may return wrong file if multiple files have same basename
    grep "^\- \`${filename}\`" "$PROJECT_MAP" 2>/dev/null | head -1 | \
        sed 's/^- `//' | sed 's/` — / — /'
}

# Clean up session log files older than LOG_MAX_AGE_DAYS
cleanup_old_logs() {
    find ".research" -maxdepth 1 -name ".session-reads-*.log" \
        -mtime "+${LOG_MAX_AGE_DAYS}" -delete 2>/dev/null || true
}

# Record file read
record_file_read() {
    local file_path="$1"
    local session_log="$2"

    # Create .research directory if it doesn't exist
    mkdir -p "$(dirname "$session_log")" 2>/dev/null || true

    # Append to session log
    echo "$file_path" >> "$session_log" 2>/dev/null || true
}

# Main processing function
process_read_request() {
    local json_input="$1"
    local session_log="$2"
    local file_path

    # Extract file path from JSON
    file_path=$(extract_file_path "$json_input")

    log_debug "Extracted file_path: $file_path"
    log_debug "Session log: $session_log"

    if [[ -z "$file_path" ]]; then
        log_debug "No file_path found in JSON input"
        return 0
    fi

    # Check for duplicate reads
    if is_duplicate_read "$file_path" "$session_log"; then
        local filename
        filename=$(basename "$file_path")

        # Get file info for more context
        local file_info
        file_info=$(get_file_info_from_map "$file_path")

        if [[ -n "$file_info" ]]; then
            # Extract token estimate from file info
            local tokens
            tokens=$(echo "$file_info" | sed -n 's/.*(~\([0-9]*\) tok).*/\1/p')
            if [[ -n "$tokens" ]]; then
                log_warning "$filename already read this session (~$tokens tok). Use existing knowledge instead of re-reading."
            else
                log_warning "$filename already read this session. Use existing knowledge instead of re-reading."
            fi
        else
            log_warning "$filename already read this session. Use existing knowledge instead of re-reading."
        fi
    else
        # First time reading this file
        local file_info
        file_info=$(get_file_info_from_map "$file_path")

        if [[ -n "$file_info" ]]; then
            log_info "$file_info"
        else
            local filename
            filename=$(basename "$file_path")
            log_info "$filename"
        fi

        # Record this read
        record_file_read "$file_path" "$session_log"
    fi
}

# Main function
main() {
    # Clean up logs older than LOG_MAX_AGE_DAYS (non-blocking)
    cleanup_old_logs

    # Read JSON input from stdin
    local json_input
    json_input=$(cat)

    log_debug "Raw JSON input: $json_input"

    # Debug: Save hook input to file for inspection (only when DEBUG_HOOK_INPUT=1)
    if [[ "${DEBUG_HOOK_INPUT:-0}" == "1" ]]; then
        mkdir -p .research/debug 2>/dev/null
        echo "$json_input" >> .research/debug/hook-inputs.jsonl
    fi

    # Determine session ID (supports main + sub-agents)
    local session_id
    session_id=$(get_session_id "$json_input")
    local session_log=".research/.session-reads-${session_id}.log"

    log_debug "Session ID: $session_id"

    # Process the read request
    process_read_request "$json_input" "$session_log"

    # Always output empty JSON to allow the read to proceed
    echo "{}"
}

# Error handling
handle_error() {
    local exit_code=$?
    log_debug "Error occurred, exit code: $exit_code"
    # Still output empty JSON to allow read to proceed
    echo "{}"
    exit 0  # Don't fail the hook, just provide the warning
}

# Set up error trap
trap handle_error ERR

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi