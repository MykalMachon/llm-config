#!/usr/bin/env bash

# OpenCode Agents Installation Script
# Installs agent configurations from .opencode/agent/ to ~/.config/opencode/agent/

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global variables
REPO_ROOT=""
AGENTS_SOURCE_DIR=""
AGENTS_DEST_DIR="${HOME}/.config/opencode/agent"
VERBOSE=false
DRY_RUN=false
FORCE=false
SKIP_EXISTING=false
BACKUP=false
INTERACTIVE=true
BATCH_MODE=false
BATCH_CHOICE=""

# Function to print colored output
print_info() {
	echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_verbose() {
	if [[ "$VERBOSE" == true ]]; then
		echo -e "${CYAN}[VERBOSE]${NC} $1"
	fi
}

# Show help message
show_help() {
	cat << EOF
OpenCode Agents Installation Script

USAGE:
    $0 [OPTIONS]

DESCRIPTION:
    Installs OpenCode agent configurations from .opencode/agent/ to ~/.config/opencode/agent/

OPTIONS:
    -n, --dry-run       Show what would be done without executing
    -f, --force         Overwrite files without prompting
    -b, --backup        Always backup existing files
    -s, --skip-existing Skip files that already exist
    -v, --verbose       Verbose output
    -h, --help          Show this help message
    -i, --interactive   Prompt for each collision (default)
    --batch-mode        Apply same choice to all collisions

EXAMPLES:
    $0                  # Interactive installation with prompts for conflicts
    $0 --dry-run        # See what would be installed without making changes
    $0 --force          # Overwrite all existing files
    $0 --backup         # Backup existing files before installing
    $0 --skip-existing  # Skip any files that already exist

COLLISION HANDLING:
    When files already exist, you can choose to:
    - Skip: Keep existing file, don't install new one
    - Overwrite: Replace existing file with new one
    - Backup: Move existing to .bak file, then install new one
    - Quit: Exit the installation

EOF
}

# Parse command line arguments
parse_args() {
	while [[ $# -gt 0 ]]; do
		case $1 in
			-n|--dry-run)
				DRY_RUN=true
				shift
				;;
			-f|--force)
				FORCE=true
				INTERACTIVE=false
				shift
				;;
			-b|--backup)
				BACKUP=true
				shift
				;;
			-s|--skip-existing)
				SKIP_EXISTING=true
				INTERACTIVE=false
				shift
				;;
			-v|--verbose)
				VERBOSE=true
				shift
				;;
			-h|--help)
				show_help
				exit 0
				;;
			-i|--interactive)
				INTERACTIVE=true
				BATCH_MODE=false
				shift
				;;
			--batch-mode)
				BATCH_MODE=true
				shift
				;;
			*)
				print_error "Unknown option: $1"
				echo "Use --help for usage information."
				exit 1
				;;
		esac
	done
}

# Check for required dependencies
check_dependencies() {
	print_verbose "Checking dependencies..."
	
	local missing_deps=()
	
	if ! command -v git &> /dev/null; then
		missing_deps+=("git")
	fi
	
	if [[ ${#missing_deps[@]} -gt 0 ]]; then
		print_error "Missing required dependencies: ${missing_deps[*]}"
		print_error "Please install missing dependencies and try again."
		exit 1
	fi
	
	print_verbose "All dependencies found"
}

# Find repository root and validate source directory
find_repo_root() {
	print_verbose "Finding repository root..."
	
	# Try git to find repo root
	if REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
		print_verbose "Found git repository root: $REPO_ROOT"
	else
		# Fall back to current directory
		REPO_ROOT="$(pwd)"
		print_verbose "Not in git repository, using current directory: $REPO_ROOT"
	fi
	
	AGENTS_SOURCE_DIR="${REPO_ROOT}/.opencode/agent"
	
	# Validate source directory exists
	if [[ ! -d "$AGENTS_SOURCE_DIR" ]]; then
		print_error "Source directory not found: $AGENTS_SOURCE_DIR"
		print_error "Make sure you're running this script from the repository root"
		print_error "or that .opencode/agent/ directory exists."
		exit 1
	fi
	
	# Check if source directory has agent files
	local agent_count=$(find "$AGENTS_SOURCE_DIR" -name "*.md" -type f | wc -l)
	if [[ $agent_count -eq 0 ]]; then
		print_error "No agent files (*.md) found in $AGENTS_SOURCE_DIR"
		exit 1
	fi
	
	print_verbose "Found $agent_count agent files in source directory"
}

# Create destination directory with proper permissions
create_agent_directory() {
	print_verbose "Creating destination directory..."
	
	if [[ "$DRY_RUN" == true ]]; then
		print_info "DRY RUN: Would create directory $AGENTS_DEST_DIR"
		return 0
	fi
	
	if [[ ! -d "$AGENTS_DEST_DIR" ]]; then
		if mkdir -p "$AGENTS_DEST_DIR"; then
			print_verbose "Created directory: $AGENTS_DEST_DIR"
		else
			print_error "Failed to create directory: $AGENTS_DEST_DIR"
			exit 1
		fi
	else
		print_verbose "Directory already exists: $AGENTS_DEST_DIR"
	fi
	
	# Check write permissions
	if [[ ! -w "$AGENTS_DEST_DIR" ]]; then
		print_error "No write permission to directory: $AGENTS_DEST_DIR"
		exit 1
	fi
}

# Detect file collisions
detect_agent_collisions() {
	print_verbose "Detecting file collisions..."
	
	local collisions=()
	
	for source_file in "$AGENTS_SOURCE_DIR"/*.md; do
		[[ -f "$source_file" ]] || continue
		
		local filename=$(basename "$source_file")
		local dest_file="$AGENTS_DEST_DIR/$filename"
		
		if [[ -f "$dest_file" ]]; then
			collisions+=("$filename")
		fi
	done
	
	if [[ ${#collisions[@]} -gt 0 ]]; then
		print_warning "Found ${#collisions[@]} file collision(s):"
		for collision in "${collisions[@]}"; do
			print_warning "  - $collision"
		done
		echo
	else
		print_verbose "No file collisions detected"
	fi
	
	echo "${collisions[@]}"
}

# Prompt user for collision resolution
prompt_user_collision() {
	local filename="$1"
	local choice=""
	
	if [[ "$BATCH_MODE" == true && -n "$BATCH_CHOICE" ]]; then
		echo "$BATCH_CHOICE"
		return 0
	fi
	
	while true; do
		echo -e "${YELLOW}File collision detected: $filename${NC}" >&2
		echo "Choose an action:" >&2
		echo "  s) Skip this file" >&2
		echo "  o) Overwrite existing file" >&2
		echo "  b) Backup existing file and install new one" >&2
		echo "  d) Show diff (if possible)" >&2
		echo "  q) Quit installation" >&2
		
		if [[ "$BATCH_MODE" == true ]]; then
			echo "  a) Apply choice to all remaining files" >&2
		fi
		
		echo -n "Choice [s/o/b/d/q$([ "$BATCH_MODE" = true ] && echo "/a")]: " >&2
		read choice
		
		case "$choice" in
			s|S)
				echo "skip"
				return 0
				;;
			o|O)
				if [[ "$BATCH_MODE" == true ]]; then
					BATCH_CHOICE="overwrite"
				fi
				echo "overwrite"
				return 0
				;;
			b|B)
				if [[ "$BATCH_MODE" == true ]]; then
					BATCH_CHOICE="backup"
				fi
				echo "backup"
				return 0
				;;
			d|D)
				show_file_diff "$filename"
				continue
				;;
			q|Q)
				echo "quit"
				return 0
				;;
			a|A)
				if [[ "$BATCH_MODE" == true ]]; then
					echo "Please choose the action to apply to all files:" >&2
					echo -n "Choice for all [s/o/b]: " >&2
					read choice
					case "$choice" in
						s|S) BATCH_CHOICE="skip" ;;
						o|O) BATCH_CHOICE="overwrite" ;;
						b|B) BATCH_CHOICE="backup" ;;
						*) 
							print_error "Invalid choice"
							continue
							;;
					esac
					echo "$BATCH_CHOICE"
					return 0
				fi
				;;
			*)
				print_error "Invalid choice. Please try again."
				continue
				;;
		esac
	done
}

# Show diff between source and destination files
show_file_diff() {
	local filename="$1"
	local source_file="$AGENTS_SOURCE_DIR/$filename"
	local dest_file="$AGENTS_DEST_DIR/$filename"
	
	echo -e "\n${CYAN}Showing differences for $filename:${NC}"
	echo "Source: $source_file"
	echo "Destination: $dest_file"
	echo "---"
	
	if command -v diff &> /dev/null; then
		diff -u "$dest_file" "$source_file" || true
	else
		print_warning "diff command not available, cannot show differences"
	fi
	
	echo "---"
}

# Backup existing file
backup_existing_file() {
	local dest_file="$1"
	local backup_file="${dest_file}.bak.$(date +%Y%m%d_%H%M%S)"
	
	if [[ "$DRY_RUN" == true ]]; then
		print_info "DRY RUN: Would backup $dest_file to $backup_file"
		return 0
	fi
	
	if cp "$dest_file" "$backup_file"; then
		print_verbose "Backed up to: $backup_file"
		return 0
	else
		print_error "Failed to backup file: $dest_file"
		return 1
	fi
}

# Copy agent files
copy_agents() {
	print_info "Installing OpenCode agents..."
	
	local collisions=($(detect_agent_collisions))
	local installed=0
	local skipped=0
	local failed=0
	
	for source_file in "$AGENTS_SOURCE_DIR"/*.md; do
		[[ -f "$source_file" ]] || continue
		
		local filename=$(basename "$source_file")
		local dest_file="$AGENTS_DEST_DIR/$filename"
		local action="install"
		
		print_info "Processing: $filename"
		
		# Check if file exists and determine action
		if [[ -f "$dest_file" ]]; then
			print_verbose "File exists: $dest_file"
			if [[ "$DRY_RUN" == true ]]; then
				action="overwrite"  # In dry-run, just show what would happen
				print_verbose "DRY_RUN mode: setting action to overwrite"
			elif [[ "$FORCE" == true ]]; then
				action="overwrite"
				print_verbose "FORCE mode: setting action to overwrite"
			elif [[ "$SKIP_EXISTING" == true ]]; then
				action="skip"
				print_verbose "SKIP_EXISTING mode: setting action to skip"
			elif [[ "$BACKUP" == true ]]; then
				action="backup"
				print_verbose "BACKUP mode: setting action to backup"
			elif [[ "$INTERACTIVE" == true ]]; then
				print_verbose "INTERACTIVE mode: prompting user"
				local user_choice=$(prompt_user_collision "$filename")
				print_verbose "User choice: $user_choice"
				case "$user_choice" in
					"skip") action="skip" ;;
					"overwrite") action="overwrite" ;;
					"backup") action="backup" ;;
					"quit") 
						print_info "Installation cancelled by user"
						exit 0
						;;
				esac
			else
				action="skip"
				print_verbose "Default: setting action to skip"
			fi
		fi
		
		# Execute action
		case "$action" in
			"skip")
				print_info "Skipping: $filename (already exists)"
				skipped=$((skipped + 1))
				;;
			"backup")
				if [[ "$DRY_RUN" == false ]]; then
					if backup_existing_file "$dest_file"; then
						if cp "$source_file" "$dest_file"; then
							print_success "Installed: $filename (existing file backed up)"
							installed=$((installed + 1))
						else
							print_error "Failed to copy: $filename"
							failed=$((failed + 1))
						fi
					else
						print_error "Failed to backup existing file: $filename"
						failed=$((failed + 1))
					fi
				else
					print_info "DRY RUN: Would backup and install $filename"
					installed=$((installed + 1))
				fi
				;;
			"overwrite"|"install")
				if [[ "$DRY_RUN" == false ]]; then
					if cp "$source_file" "$dest_file"; then
						if [[ "$action" == "overwrite" ]]; then
							print_success "Overwritten: $filename"
						else
							print_success "Installed: $filename"
						fi
						installed=$((installed + 1))
					else
						print_error "Failed to copy: $filename"
						failed=$((failed + 1))
					fi
				else
					print_info "DRY RUN: Would $action $filename"
					installed=$((installed + 1))
				fi
				;;
		esac
	done
	
	# Print summary
	echo
	print_info "Installation Summary:"
	print_info "  Installed: $installed"
	print_info "  Skipped: $skipped"
	if [[ $failed -gt 0 ]]; then
		print_error "  Failed: $failed"
	fi
	
	if [[ $failed -gt 0 ]]; then
		exit 1
	fi
}

# Validate installation
validate_installation() {
	if [[ "$DRY_RUN" == true ]]; then
		return 0
	fi
	
	print_verbose "Validating installation..."
	
	local expected_files=()
	local missing_files=()
	
	# Collect expected files
	for source_file in "$AGENTS_SOURCE_DIR"/*.md; do
		[[ -f "$source_file" ]] || continue
		expected_files+=($(basename "$source_file"))
	done
	
	# Check which files are missing
	for filename in "${expected_files[@]}"; do
		local dest_file="$AGENTS_DEST_DIR/$filename"
		if [[ ! -f "$dest_file" ]]; then
			missing_files+=("$filename")
		fi
	done
	
	if [[ ${#missing_files[@]} -eq 0 ]]; then
		print_success "All agent files are present in destination directory"
	else
		print_warning "Some files were not installed:"
		for missing in "${missing_files[@]}"; do
			print_warning "  - $missing"
		done
	fi
}

# Main function
main() {
	echo -e "${BLUE}OpenCode Agents Installation Script${NC}"
	echo "===================================="
	echo
	
	parse_args "$@"
	
	if [[ "$DRY_RUN" == true ]]; then
		print_info "DRY RUN MODE: No files will be modified"
		echo
	fi
	
	check_dependencies
	find_repo_root
	create_agent_directory
	copy_agents
	validate_installation
	
	echo
	if [[ "$DRY_RUN" == false ]]; then
		print_success "OpenCode agents installation completed!"
		print_info "Agents installed to: $AGENTS_DEST_DIR"
		print_info "You can now use these agents in OpenCode."
	else
		print_info "DRY RUN completed. Run without --dry-run to perform actual installation."
	fi
}

# Run main function with all arguments
main "$@"