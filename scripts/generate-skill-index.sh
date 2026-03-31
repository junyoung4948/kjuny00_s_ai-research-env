#!/usr/bin/env bash
# generate-skill-index.sh
# Skill Index Generator - Bash implementation inspired by aspens skill-reader.js
# Creates .research/skill-index.md with skill names and descriptions from SKILL.md files

set -uo pipefail
shopt -s inherit_errexit

# Script directory detection
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_NAME="${0##*/}"

# Constants
readonly SKILL_INDEX_FILE=".research/skill-index.md"

# Global variables
declare -g project_root=""
declare -g output_file=""
declare -gi skill_count=0
declare -a temp_files=()

# Cleanup function
cleanup() {
    local exit_code=$?
    for temp_file in "${temp_files[@]}"; do
        [[ -f "$temp_file" ]] && rm -f -- "$temp_file"
    done
    exit $exit_code
}

# Setup trap
trap cleanup EXIT

# Logging functions
log_info() {
    printf "[INFO] %s\n" "$*" >&2
}

log_error() {
    printf "[ERROR] %s\n" "$*" >&2
}

log_debug() {
    [[ "${DEBUG:-}" == "1" ]] && printf "[DEBUG] %s\n" "$*" >&2
}

# Usage function
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] PROJECT_ROOT

Generate skill index from SKILL.md files with names and descriptions.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug output
    --dry-run       Show what would be generated without writing

ARGUMENTS:
    PROJECT_ROOT    Path to project root directory

EXAMPLES:
    $SCRIPT_NAME ./
    $SCRIPT_NAME --verbose /path/to/project
    $SCRIPT_NAME --dry-run .

OUTPUT:
    Creates .research/skill-index.md in PROJECT_ROOT

DIRECTORIES SEARCHED:
    - .claude/skills/
    - .agents/skills/
    - templates/.claude/skills/
    - templates/.agents/skills/
    - shared-skills/

EOF
}

# Extract skill metadata from SKILL.md YAML frontmatter
extract_skill_metadata() {
    local file="$1"
    local skill_name=""
    local skill_description=""
    local agent_type=""

    # Determine agent type from path
    if [[ "$file" == *.claude/skills/* ]]; then
        agent_type="claude"
    elif [[ "$file" == *.agents/skills/* ]]; then
        agent_type="gemini"
    elif [[ "$file" == *shared-skills/* ]]; then
        agent_type="both"
    else
        agent_type="unknown"
    fi

    # Extract skill name from directory name (parent of SKILL.md)
    local skill_dir
    skill_dir=$(dirname "$file")
    skill_name=$(basename "$skill_dir")

    # Extract description from YAML frontmatter
    skill_description=$(awk '
        /^---$/ { in_frontmatter = !in_frontmatter; next }
        in_frontmatter && /^description:\s*(.+)$/ {
            gsub(/^description:\s*/, "");
            gsub(/^["\047]|["\047]$/, "");
            print;
            exit
        }
    ' "$file" 2>/dev/null || echo "")

    # If no description in frontmatter, try to get first line of content
    if [[ -z "$skill_description" ]]; then
        skill_description=$(grep -v '^---$' "$file" | grep -v '^[[:space:]]*$' | head -1 | sed 's/^[#[:space:]]*//' 2>/dev/null || echo "")
    fi

    # Truncate description if too long
    if [[ ${#skill_description} -gt 100 ]]; then
        skill_description="${skill_description:0:97}..."
    fi

    printf "%s|%s|%s\n" "$skill_name" "$agent_type" "$skill_description"
}

# Find all SKILL.md files
find_skill_files() {
    local search_paths=(
        ".claude/skills"
        ".agents/skills"
        "templates/.claude/skills"
        "templates/.agents/skills"
        "shared-skills"
    )

    local path
    for path in "${search_paths[@]}"; do
        local full_path="$project_root/$path"
        if [[ -d "$full_path" ]]; then
            find "$full_path" -name "SKILL.md" -type f 2>/dev/null | sort || true
        fi
    done
}

# Generate skill index content
generate_skill_index() {
    local timestamp
    timestamp=$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S%z')

    cat <<EOF
# Skill Index
> Generated: $timestamp | Skills: 0

| Skill | Agent | Description |
|-------|-------|-------------|
EOF

    # Find all SKILL.md files and process them
    local skill_files
    skill_files=$(find_skill_files)

    local file metadata skill_name agent_type skill_description
    while IFS= read -r file || [[ -n "$file" ]]; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue

        log_debug "Processing: $file"

        metadata=$(extract_skill_metadata "$file")
        IFS='|' read -r skill_name agent_type skill_description <<< "$metadata"

        if [[ -n "$skill_name" ]]; then
            printf "| %s | %s | %s |\n" "$skill_name" "$agent_type" "$skill_description"
            ((skill_count++))
        fi
    done <<< "$skill_files"

    # Update skill count in header (only for real files, not stdout)
    if [[ "$output_file" != "/dev/stdout" ]] && command -v sed >/dev/null 2>&1; then
        sed -i.tmp "s/Skills: 0/Skills: $skill_count/" "$output_file"
        rm -f "$output_file.tmp"
    fi
}

# Parse command line arguments
parse_args() {
    local dry_run=0
    local verbose=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -d|--debug)
                DEBUG=1
                shift
                ;;
            --dry-run)
                dry_run=1
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                usage >&2
                exit 1
                ;;
            *)
                if [[ -z "$project_root" ]]; then
                    project_root="$1"
                else
                    log_error "Multiple project roots specified"
                    usage >&2
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$project_root" ]]; then
        log_error "PROJECT_ROOT is required"
        usage >&2
        exit 1
    fi

    # Validate project root exists
    if [[ ! -d "$project_root" ]]; then
        log_error "Project root does not exist: $project_root"
        exit 1
    fi

    # Convert to absolute path
    project_root="$(cd -- "$project_root" && pwd -P)"
    output_file="$project_root/$SKILL_INDEX_FILE"

    # Set verbose logging
    if [[ $verbose -eq 1 ]]; then
        exec 2> >(while IFS= read -r line; do printf "[VERBOSE] %s\n" "$line"; done)
    fi

    log_debug "Project root: $project_root"
    log_debug "Output file: $output_file"
    log_debug "Dry run: $dry_run"

    # Create .research directory if it doesn't exist
    if [[ $dry_run -eq 0 ]]; then
        mkdir -p "$(dirname "$output_file")"
    fi

    return $dry_run
}

# Main function
main() {
    local dry_run

    log_info "Starting skill index generation..."

    if ! parse_args "$@"; then
        dry_run=1
    else
        dry_run=0
    fi

    if [[ $dry_run -eq 1 ]]; then
        log_info "DRY RUN: Would generate $output_file"
        output_file="/dev/stdout"
    fi

    generate_skill_index > "$output_file"

    if [[ $dry_run -eq 0 ]]; then
        log_info "Skill index generated: $output_file"
        log_info "Found $skill_count skills"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi