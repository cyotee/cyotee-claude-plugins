#!/bin/bash
#
# OpenCode Plugin Installer
#
# Installs cyotee-claude-plugins commands and agents for OpenCode.
#
# Usage:
#   ./install-opencode.sh              # Install all plugins
#   ./install-opencode.sh up           # Install only /up plugin
#   ./install-opencode.sh backlog      # Install only /backlog plugin
#   ./install-opencode.sh design       # Install only /design plugin
#   ./install-opencode.sh --uninstall  # Remove installed files
#
# After cloning:
#   git clone https://github.com/cyotee/cyotee-claude-plugins.git
#   cd cyotee-claude-plugins
#   ./install-opencode.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_CONFIG="${HOME}/.config/opencode"
COMMANDS_DIR="${OPENCODE_CONFIG}/commands"
AGENTS_DIR="${OPENCODE_CONFIG}/agents"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Uninstall function
uninstall() {
    print_header "Uninstalling OpenCode Plugins"

    local removed=0

    # List of files we installed
    local commands=(
        "up.md" "plan.md" "prd.md" "prompt.md"
        "backlog.md" "backlog-complete.md" "backlog-launch.md" "backlog-list.md"
        "backlog-prune.md" "backlog-read.md" "backlog-review.md" "backlog-work.md"
        "design.md" "design-init.md" "design-prd.md" "design-digest.md"
        "design-from-review.md" "design-review.md"
    )

    local agents=(
        "code-auditor.md" "dependency-analyzer.md" "task-auditor.md"
    )

    echo "Removing commands..."
    for cmd in "${commands[@]}"; do
        if [[ -f "${COMMANDS_DIR}/${cmd}" ]]; then
            rm "${COMMANDS_DIR}/${cmd}"
            print_success "Removed ${cmd}"
            ((removed++))
        fi
    done

    echo ""
    echo "Removing agents..."
    for agent in "${agents[@]}"; do
        if [[ -f "${AGENTS_DIR}/${agent}" ]]; then
            rm "${AGENTS_DIR}/${agent}"
            print_success "Removed ${agent}"
            ((removed++))
        fi
    done

    echo ""
    if [[ $removed -gt 0 ]]; then
        print_success "Uninstalled ${removed} files"
    else
        print_warning "No files found to uninstall"
    fi

    exit 0
}

# Install a single plugin
install_plugin() {
    local plugin="$1"
    local plugin_dir="${SCRIPT_DIR}/plugins/${plugin}"

    if [[ ! -d "$plugin_dir" ]]; then
        print_error "Plugin not found: ${plugin}"
        return 1
    fi

    local opencode_dir="${plugin_dir}/.opencode"

    if [[ ! -d "$opencode_dir" ]]; then
        print_error "No OpenCode files for plugin: ${plugin}"
        print_warning "This plugin may not have been converted for OpenCode yet."
        return 1
    fi

    echo "Installing ${plugin} plugin..."

    # Install commands
    if [[ -d "${opencode_dir}/commands" ]]; then
        local cmd_count=0
        for cmd in "${opencode_dir}/commands"/*.md; do
            [[ -f "$cmd" ]] || continue
            cp "$cmd" "${COMMANDS_DIR}/"
            print_success "  $(basename "$cmd")"
            ((cmd_count++))
        done
        echo "  Commands: ${cmd_count}"
    fi

    # Install agents
    if [[ -d "${opencode_dir}/agents" ]]; then
        local agent_count=0
        for agent in "${opencode_dir}/agents"/*.md; do
            [[ -f "$agent" ]] || continue
            cp "$agent" "${AGENTS_DIR}/"
            print_success "  $(basename "$agent")"
            ((agent_count++))
        done
        echo "  Agents: ${agent_count}"
    fi

    echo ""
}

# Show help
show_help() {
    echo "OpenCode Plugin Installer"
    echo ""
    echo "Installs cyotee-claude-plugins commands and agents for OpenCode."
    echo ""
    echo "Usage:"
    echo "  ./install-opencode.sh              Install all plugins"
    echo "  ./install-opencode.sh up           Install only /up plugin"
    echo "  ./install-opencode.sh backlog      Install only /backlog plugin"
    echo "  ./install-opencode.sh design       Install only /design plugin"
    echo "  ./install-opencode.sh --uninstall  Remove installed files"
    echo "  ./install-opencode.sh --help       Show this help"
    echo ""
    echo "After cloning:"
    echo "  git clone https://github.com/cyotee/cyotee-claude-plugins.git"
    echo "  cd cyotee-claude-plugins"
    echo "  ./install-opencode.sh"
    echo ""
    exit 0
}

# Main installation
main() {
    # Check for help flag
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
    fi

    # Check for uninstall flag
    if [[ "$1" == "--uninstall" ]] || [[ "$1" == "-u" ]]; then
        uninstall
    fi

    print_header "OpenCode Plugin Installer"

    echo "Source: ${SCRIPT_DIR}"
    echo "Target: ${OPENCODE_CONFIG}"
    echo ""

    # Create directories if needed
    if [[ ! -d "$COMMANDS_DIR" ]]; then
        mkdir -p "$COMMANDS_DIR"
        print_success "Created ${COMMANDS_DIR}"
    fi

    if [[ ! -d "$AGENTS_DIR" ]]; then
        mkdir -p "$AGENTS_DIR"
        print_success "Created ${AGENTS_DIR}"
    fi

    echo ""

    # Determine which plugins to install
    local plugins=()

    if [[ $# -eq 0 ]]; then
        # Install all plugins
        plugins=("up" "backlog" "design")
    else
        # Install specified plugins
        plugins=("$@")
    fi

    # Install each plugin
    for plugin in "${plugins[@]}"; do
        install_plugin "$plugin"
    done

    print_header "Installation Complete"

    echo "Installed commands:"
    ls -1 "${COMMANDS_DIR}"/*.md 2>/dev/null | xargs -I {} basename {} | sort | sed 's/^/  \//' | sed 's/\.md$//'

    echo ""
    echo "Installed agents:"
    ls -1 "${AGENTS_DIR}"/*.md 2>/dev/null | xargs -I {} basename {} | sort | sed 's/^/  @/' | sed 's/\.md$//'

    echo ""
    echo -e "${GREEN}You can now use these commands in OpenCode!${NC}"
    echo ""
    echo "Quick start:"
    echo "  /up          - Bootstrap context from CLAUDE.md"
    echo "  /backlog     - View task status"
    echo "  /design      - Create a new task"
    echo ""
    echo "To uninstall:"
    echo "  ./install-opencode.sh --uninstall"
    echo ""
}

main "$@"
