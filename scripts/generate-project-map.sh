#!/usr/bin/env bash
# generate-project-map.sh
# Project Map Generator - Bash implementation inspired by OpenWolf anatomy-scanner
# Creates .research/project-map.md with file descriptions and token estimates

set -uo pipefail
shopt -s inherit_errexit

# Script directory detection
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_NAME="${0##*/}"

# Constants
readonly PROJECT_MAP_FILE=".research/project-map.md"
declare -A TOKEN_RATIOS=(
    [md]=4.0
    [code]=3.5
    [mixed]=3.75
)

# Known files lookup (from OpenWolf KNOWN_FILES)
declare -A KNOWN_FILES=(
    [settings.json]="Claude Code settings"
    [keybindings.json]="Claude Code keybindings"
    [CLAUDE.md]="Claude Code instructions"
    [GEMINI.md]="Gemini agent instructions"
    [AGENTS.md]="Agent configuration"
    [README.md]="Project overview"
    [package.json]="Node.js package configuration"
    [pyproject.toml]="Python project configuration"
    [Cargo.toml]="Rust project configuration"
    [go.mod]="Go module configuration"
)

# Global variables
declare -g project_root=""
declare -g output_file=""
declare -gi file_count=0
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

Generate project map with file descriptions and token estimates.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug output
    --dry-run       Show what would be generated without writing

ARGUMENTS:
    PROJECT_ROOT    Path to project root directory

EXAMPLES:
    $SCRIPT_NAME ./templates/
    $SCRIPT_NAME --verbose /path/to/project
    $SCRIPT_NAME --dry-run .

OUTPUT:
    Creates .research/project-map.md in PROJECT_ROOT

EOF
}

# Extract description from SKILL.md YAML frontmatter
extract_skill_description() {
    local file="$1"

    # Look for description: field in YAML frontmatter
    awk '
        /^---$/ { in_frontmatter = !in_frontmatter; next }
        in_frontmatter && /^description:\s*(.+)$/ {
            gsub(/^description:\s*/, "");
            gsub(/^["\047]|["\047]$/, "");
            print;
            exit
        }
    ' "$file" 2>/dev/null || echo ""
}

# Extract description from shell script header comment
extract_shell_description() {
    local file="$1"

    # Skip shebang, get first # comment
    sed -n '
        /^#!/d
        /^[[:space:]]*#[^#]/{
            s/^[[:space:]]*#[[:space:]]*//
            p
            q
        }
    ' "$file" 2>/dev/null || echo ""
}

# Extract description from markdown heading
extract_markdown_description() {
    local file="$1"

    # Get first H1 or H2 heading
    grep -m1 '^#{1,2}[[:space:]]' "$file" 2>/dev/null | \
        sed 's/^#{1,2}[[:space:]]*//' || echo ""
}

# Extract description from Python docstring or comment
extract_python_description() {
    local file="$1"

    # Try docstring first
    local docstring
    docstring=$(awk '
        /^[[:space:]]*"""/ {
            if (NF > 1) {
                gsub(/^[[:space:]]*"""[[:space:]]*/, "")
                gsub(/[[:space:]]*"""[[:space:]]*$/, "")
                if (length > 0) print
            } else {
                getline
                gsub(/^[[:space:]]*/, "")
                gsub(/[[:space:]]*"""[[:space:]]*$/, "")
                if (length > 0) print
            }
            exit
        }
        /^[[:space:]]*"'"'"'"'"'"'/ {
            if (NF > 1) {
                gsub(/^[[:space:]]*"'"'"'"'"'"'[[:space:]]*/, "")
                gsub(/[[:space:]]*"'"'"'"'"'"'[[:space:]]*$/, "")
                if (length > 0) print
            } else {
                getline
                gsub(/^[[:space:]]*/, "")
                gsub(/[[:space:]]*"'"'"'"'"'"'[[:space:]]*$/, "")
                if (length > 0) print
            }
            exit
        }
    ' "$file" 2>/dev/null)

    if [[ -n "$docstring" ]]; then
        echo "$docstring"
    else
        # Fallback to first # comment
        grep -m1 '^[[:space:]]*#[^#]' "$file" 2>/dev/null | \
            sed 's/^[[:space:]]*#[[:space:]]*//' || echo ""
    fi
}

# Extract description based on file type
extract_description() {
    local file="$1"
    local basename="${file##*/}"
    local extension="${file##*.}"

    # Check known files first
    if [[ -v "KNOWN_FILES[$basename]" ]]; then
        echo "${KNOWN_FILES[$basename]}"
        return 0
    fi

    # Extract by file type
    case "$extension" in
        md)
            if [[ "$basename" == "SKILL.md" ]]; then
                extract_skill_description "$file"
            else
                extract_markdown_description "$file"
            fi
            ;;
        sh)
            extract_shell_description "$file"
            ;;
        py)
            extract_python_description "$file"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Estimate token count
estimate_tokens() {
    local file="$1"
    local extension="${file##*.}"
    local char_count
    local ratio

    char_count=$(wc -c < "$file" 2>/dev/null || echo "0")

    # Determine ratio based on file type
    case "$extension" in
        md|txt|rst)
            ratio="${TOKEN_RATIOS[md]}"
            ;;
        json|yaml|yml|toml|xml)
            ratio="${TOKEN_RATIOS[mixed]}"
            ;;
        *)
            ratio="${TOKEN_RATIOS[code]}"
            ;;
    esac

    # Calculate tokens (char_count / ratio)
    python3 -c "print(int($char_count / $ratio))" 2>/dev/null || \
        awk "BEGIN { printf \"%.0f\", $char_count / $ratio }"
}

# Generate directory section
generate_directory_section() {
    local dir="$1"
    local relative_dir="${dir#"$project_root"}"
    relative_dir="${relative_dir#/}"

    # Skip empty directories
    local file_list
    file_list=$(find "$dir" -maxdepth 1 -type f -not -path '*/.*' 2>/dev/null | sort || true)
    [[ -z "$file_list" ]] && return 0

    printf "\n## %s\n" "${relative_dir:-"."}"

    local file
    while IFS= read -r file || [[ -n "$file" ]]; do
        [[ -z "$file" ]] && continue

        local filename="${file##*/}"
        local description
        local tokens

        description=$(extract_description "$file")
        tokens=$(estimate_tokens "$file")

        if [[ -n "$description" ]]; then
            printf -- "- \`%s\` — %s (~%s tok)\n" "$filename" "$description" "$tokens"
        else
            printf -- "- \`%s\` (~%s tok)\n" "$filename" "$tokens"
        fi

        ((file_count++))
    done <<< "$file_list"
}

# Generate project map content
generate_project_map() {
    local timestamp
    timestamp=$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S%z')

    cat <<EOF
# Project Map
> Generated: $timestamp | Files: 0

EOF

    # Find all directories with files, sorted by path
    local directories
    directories=$(find "$project_root" -type d -not -path '*/.*' 2>/dev/null | sort || true)

    local dir
    while IFS= read -r dir || [[ -n "$dir" ]]; do
        [[ -z "$dir" ]] && continue
        generate_directory_section "$dir"
    done <<< "$directories"

    # Update file count in header (only for real files, not stdout)
    if [[ "$output_file" != "/dev/stdout" ]] && command -v sed >/dev/null 2>&1; then
        sed -i.tmp "s/Files: 0/Files: $file_count/" "$output_file"
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
    output_file="$project_root/$PROJECT_MAP_FILE"

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

    log_info "Starting project map generation..."

    if ! parse_args "$@"; then
        dry_run=1
    else
        dry_run=0
    fi

    if [[ $dry_run -eq 1 ]]; then
        log_info "DRY RUN: Would generate $output_file"
        output_file="/dev/stdout"
    fi

    generate_project_map > "$output_file"

    if [[ $dry_run -eq 0 ]]; then
        log_info "Project map generated: $output_file"
        log_info "Found $file_count files"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi