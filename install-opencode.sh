#!/bin/bash
#
# OpenCode Plugin Installer
#
# Installs cyotee-claude-plugins commands, agents, and skills for OpenCode.
#
# Usage:
#   ./install-opencode.sh              # Install all plugins
#   ./install-opencode.sh up           # Install only /up plugin
#   ./install-opencode.sh backlog      # Install only /backlog plugin
#   ./install-opencode.sh --list       # List available plugins
#   ./install-opencode.sh --uninstall  # Remove installed files
#
# After cloning:
#   git clone https://github.com/cyotee/cyotee-claude-plugins.git
#   cd cyotee-claude-plugins
#   git submodule update --init --recursive
#   ./install-opencode.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_CONFIG="${HOME}/.config/opencode"
COMMANDS_DIR="${OPENCODE_CONFIG}/commands"
AGENTS_DIR="${OPENCODE_CONFIG}/agents"
SKILLS_DIR="${OPENCODE_CONFIG}/skills"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# All available plugins
ALL_PLUGINS=(
    "up"
    "design"
    "backlog"
    "foundry"
    "crane"
    "boardgame-io"
    "homunculus"
    "balancer-v3"
    "aave-v3"
    "aave-v4"
    "aerodrome"
    "aerodrome-slipstream"
    "compound-v3-comet"
    "euler-lending"
    "uniswap-v3"
    "uniswap-v4"
)

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

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# List available plugins
list_plugins() {
    print_header "Available Plugins"

    for plugin in "${ALL_PLUGINS[@]}"; do
        local plugin_dir="${SCRIPT_DIR}/plugins/${plugin}"
        local opencode_dir="${plugin_dir}/.opencode"

        if [[ -d "$plugin_dir" ]]; then
            local features=""
            [[ -d "${opencode_dir}/commands" ]] && features="${features} commands"
            [[ -d "${opencode_dir}/agents" ]] && features="${features} agents"
            [[ -d "${opencode_dir}/skills" ]] && features="${features} skills"
            [[ -f "${plugin_dir}/opencode.json" ]] && features="${features} config"

            if [[ -n "$features" ]]; then
                print_success "${plugin}:${features}"
            else
                print_warning "${plugin}: (no opencode support)"
            fi
        else
            print_error "${plugin}: (not found - run: git submodule update --init)"
        fi
    done

    echo ""
    exit 0
}

# Uninstall function
uninstall() {
    print_header "Uninstalling OpenCode Plugins"

    local removed=0

    # Remove commands
    if [[ -d "$COMMANDS_DIR" ]]; then
        echo "Checking commands..."
        for cmd in "$COMMANDS_DIR"/*.md; do
            [[ -f "$cmd" ]] || continue
            local basename=$(basename "$cmd")
            # Check if it's one of our commands
            for plugin in "${ALL_PLUGINS[@]}"; do
                if [[ "$basename" == "${plugin}"* ]] || [[ "$basename" == "up.md" ]] || [[ "$basename" == "plan.md" ]] || [[ "$basename" == "prd.md" ]] || [[ "$basename" == "prompt.md" ]]; then
                    rm "$cmd"
                    print_success "Removed command: $basename"
                    ((removed++))
                    break
                fi
            done
        done
    fi

    # Remove agents
    if [[ -d "$AGENTS_DIR" ]]; then
        echo ""
        echo "Checking agents..."
        for agent in "$AGENTS_DIR"/*.md; do
            [[ -f "$agent" ]] || continue
            rm "$agent"
            print_success "Removed agent: $(basename "$agent")"
            ((removed++))
        done
    fi

    # Remove skills directories
    if [[ -d "$SKILLS_DIR" ]]; then
        echo ""
        echo "Checking skills..."
        for plugin in "${ALL_PLUGINS[@]}"; do
            # Remove skills that match our plugin names
            for skill_dir in "$SKILLS_DIR"/*; do
                [[ -d "$skill_dir" ]] || continue
                local skill_name=$(basename "$skill_dir")
                # Check if skill belongs to one of our plugins
                if [[ "$skill_name" == "${plugin}"* ]] || [[ "$skill_name" == *"-${plugin}-"* ]]; then
                    rm -rf "$skill_dir"
                    print_success "Removed skill: $skill_name"
                    ((removed++))
                fi
            done
        done
    fi

    echo ""
    if [[ $removed -gt 0 ]]; then
        print_success "Uninstalled ${removed} items"
    else
        print_warning "No files found to uninstall"
    fi

    exit 0
}

# Copy a directory recursively
copy_dir() {
    local src="$1"
    local dest="$2"

    if [[ -d "$src" ]]; then
        cp -r "$src"/* "$dest"/ 2>/dev/null || true
    fi
}

# Install a single plugin
install_plugin() {
    local plugin="$1"
    local plugin_dir="${SCRIPT_DIR}/plugins/${plugin}"

    if [[ ! -d "$plugin_dir" ]]; then
        print_error "Plugin not found: ${plugin}"
        print_warning "Try: git submodule update --init plugins/${plugin}"
        return 1
    fi

    local opencode_dir="${plugin_dir}/.opencode"
    local has_content=false

    echo -e "${CYAN}Installing ${plugin}...${NC}"

    # Install commands
    if [[ -d "${opencode_dir}/commands" ]]; then
        local cmd_count=0
        for cmd in "${opencode_dir}/commands"/*.md; do
            [[ -f "$cmd" ]] || continue
            cp "$cmd" "${COMMANDS_DIR}/"
            ((cmd_count++))
        done
        if [[ $cmd_count -gt 0 ]]; then
            print_success "  Commands: ${cmd_count}"
            has_content=true
        fi
    fi

    # Install agents
    if [[ -d "${opencode_dir}/agents" ]]; then
        local agent_count=0
        for agent in "${opencode_dir}/agents"/*.md; do
            [[ -f "$agent" ]] || continue
            cp "$agent" "${AGENTS_DIR}/"
            ((agent_count++))
        done
        if [[ $agent_count -gt 0 ]]; then
            print_success "  Agents: ${agent_count}"
            has_content=true
        fi
    fi

    # Install skills (copy entire skill directories)
    if [[ -d "${opencode_dir}/skills" ]]; then
        local skill_count=0
        for skill_dir in "${opencode_dir}/skills"/*/; do
            [[ -d "$skill_dir" ]] || continue
            local skill_name=$(basename "$skill_dir")
            mkdir -p "${SKILLS_DIR}/${skill_name}"
            cp -r "$skill_dir"/* "${SKILLS_DIR}/${skill_name}/"
            ((skill_count++))
        done
        if [[ $skill_count -gt 0 ]]; then
            print_success "  Skills: ${skill_count}"
            has_content=true
        fi
    fi

    # Copy opencode.json if present
    if [[ -f "${plugin_dir}/opencode.json" ]]; then
        # OpenCode may use this for plugin metadata/LSP config
        print_info "  Config: opencode.json"
        has_content=true
    fi

    if [[ "$has_content" == false ]]; then
        print_warning "  No OpenCode content found"
    fi

    echo ""
}

# Show help
show_help() {
    cat << 'EOF'
OpenCode Plugin Installer

Installs cyotee-claude-plugins commands, agents, and skills for OpenCode.

Usage:
  ./install-opencode.sh              Install all plugins
  ./install-opencode.sh <plugin>     Install specific plugin(s)
  ./install-opencode.sh --list       List available plugins
  ./install-opencode.sh --uninstall  Remove installed files
  ./install-opencode.sh --help       Show this help

Examples:
  ./install-opencode.sh                        # Install everything
  ./install-opencode.sh up backlog design      # Install workflow plugins
  ./install-opencode.sh foundry crane          # Install Solidity plugins
  ./install-opencode.sh aave-v3 balancer-v3    # Install DeFi protocol skills

Available plugins:
  Workflow:    up, design, backlog, homunculus
  Solidity:    foundry, crane
  Games:       boardgame-io
  DeFi:        balancer-v3, aave-v3, aave-v4, aerodrome, aerodrome-slipstream,
               compound-v3-comet, euler-lending, uniswap-v3, uniswap-v4

Setup:
  git clone https://github.com/cyotee/cyotee-claude-plugins.git
  cd cyotee-claude-plugins
  git submodule update --init --recursive
  ./install-opencode.sh

EOF
    exit 0
}

# Main installation
main() {
    # Check for flags
    case "$1" in
        --help|-h)
            show_help
            ;;
        --uninstall|-u)
            uninstall
            ;;
        --list|-l)
            list_plugins
            ;;
    esac

    print_header "OpenCode Plugin Installer"

    echo "Source: ${SCRIPT_DIR}/plugins"
    echo "Target: ${OPENCODE_CONFIG}"
    echo ""

    # Create directories if needed
    for dir in "$COMMANDS_DIR" "$AGENTS_DIR" "$SKILLS_DIR"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_success "Created $dir"
        fi
    done

    echo ""

    # Determine which plugins to install
    local plugins=()

    if [[ $# -eq 0 ]]; then
        # Install all plugins
        plugins=("${ALL_PLUGINS[@]}")
    else
        # Install specified plugins
        plugins=("$@")
    fi

    # Install each plugin
    for plugin in "${plugins[@]}"; do
        install_plugin "$plugin"
    done

    print_header "Installation Complete"

    # Show installed commands
    echo "Installed commands:"
    if ls "${COMMANDS_DIR}"/*.md &>/dev/null; then
        ls -1 "${COMMANDS_DIR}"/*.md 2>/dev/null | xargs -I {} basename {} .md | sort | sed 's/^/  \//'
    else
        echo "  (none)"
    fi

    # Show installed agents
    echo ""
    echo "Installed agents:"
    if ls "${AGENTS_DIR}"/*.md &>/dev/null; then
        ls -1 "${AGENTS_DIR}"/*.md 2>/dev/null | xargs -I {} basename {} .md | sort | sed 's/^/  @/'
    else
        echo "  (none)"
    fi

    # Show installed skills
    echo ""
    echo "Installed skills:"
    if [[ -d "$SKILLS_DIR" ]] && ls "${SKILLS_DIR}"/*/ &>/dev/null; then
        ls -1d "${SKILLS_DIR}"/*/ 2>/dev/null | xargs -I {} basename {} | sort | sed 's/^/  /'
    else
        echo "  (none)"
    fi

    echo ""
    echo -e "${GREEN}You can now use these in OpenCode!${NC}"
    echo ""
    echo "Quick start:"
    echo "  /up              - Bootstrap context from CLAUDE.md"
    echo "  /backlog         - View task status"
    echo "  /design          - Create a new task"
    echo ""
    echo "To uninstall:"
    echo "  ./install-opencode.sh --uninstall"
    echo ""
}

main "$@"
