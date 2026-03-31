#!/usr/bin/env bash
# pre-read-guard.sh
# Pre-Read Guard Hook - Bash implementation inspired by OpenWolf pre-read.ts
# Detects duplicate file reads and provides project-map information

set -uo pipefail

# Constants
readonly SCRIPT_NAME="${0##*/}"
readonly SESSION_LOG=".research/.session-reads.log"
readonly PROJECT_MAP=".research/project-map.md"

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

    # Try to extract file_path using basic text processing
    # Handle both "file_path":"value" and "file_path": "value" formats
    local file_path
    file_path=$(echo "$json_input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

    # If that failed, try with single quotes (less common but possible)
    if [[ -z "$file_path" ]]; then
        file_path=$(echo "$json_input" | sed -n "s/.*\"file_path\"[[:space:]]*:[[:space:]]*'\([^']*\)'.*/\1/p")
    fi

    echo "$file_path"
}

# Check if file was already read in this session
is_duplicate_read() {
    local file_path="$1"

    [[ -f "$SESSION_LOG" ]] && grep -qx "$file_path" "$SESSION_LOG" 2>/dev/null
}

# Get file info from project map
get_file_info_from_map() {
    local file_path="$1"
    local filename
    filename=$(basename "$file_path")

    if [[ -f "$PROJECT_MAP" ]]; then
        # Look for the file in project map
        # Match pattern like: - `filename` — description (~tokens tok)
        grep "^\- \`$filename\`" "$PROJECT_MAP" 2>/dev/null | head -1 | sed 's/^- `//' | sed 's/` — / — /'
    else
        echo ""
    fi
}

# Record file read
record_file_read() {
    local file_path="$1"

    # Create .research directory if it doesn't exist
    mkdir -p "$(dirname "$SESSION_LOG")" 2>/dev/null || true

    # Append to session log
    echo "$file_path" >> "$SESSION_LOG" 2>/dev/null || true
}

# Main processing function
process_read_request() {
    local json_input="$1"
    local file_path

    # Extract file path from JSON
    file_path=$(extract_file_path "$json_input")

    log_debug "Extracted file_path: $file_path"

    if [[ -z "$file_path" ]]; then
        log_debug "No file_path found in JSON input"
        return 0
    fi

    # Check for duplicate reads
    if is_duplicate_read "$file_path"; then
        local filename
        filename=$(basename "$file_path")

        # Get file info for more context
        local file_info
        file_info=$(get_file_info_from_map "$file_path")

        if [[ -n "$file_info" ]]; then
            # Extract token estimate from file info
            local tokens
            tokens=$(echo "$file_info" | sed -n 's/.*(\([0-9]*\) tok).*/\1/p')
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
        record_file_read "$file_path"
    fi
}

# Main function
main() {
    # Read JSON input from stdin
    local json_input
    json_input=$(cat)

    log_debug "Raw JSON input: $json_input"

    # Process the read request
    process_read_request "$json_input"

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