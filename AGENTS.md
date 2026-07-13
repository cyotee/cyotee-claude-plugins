# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
If PROGRESS.md exists in the project root, read it for cross-session context before starting work.

## What This Is

A multi-harness plugin marketplace (`cyotee`): Claude Code is the **source of truth**; Codex dual-ship artifacts are **generated**. Plugins live under `plugins/` (often git submodules). Portable content is Agent Skills (`SKILL.md`).

## Repository Structure

```
plugins/                    # Plugin packages (many are git submodules)
  {name}/
    .claude-plugin/plugin.json   # Claude plugin metadata (SoT with marketplace)
    .codex-plugin/plugin.json    # GENERATED Codex plugin metadata
    commands/*.md                # Command definitions (YAML frontmatter + markdown)
    hooks/hooks.json             # Hook event registrations (Claude-first)
    hooks/*.sh                   # Hook implementations (bash)
    agents/*.md                  # Agent definitions (YAML frontmatter + markdown)
    skills/{name}/SKILL.md       # Portable Agent Skills
    scripts/*.sh                 # Utility scripts
    .opencode/                   # OpenCode-compatible mirrors of commands/agents/skills
    opencode.json                # OpenCode plugin config
tasks/                      # Task backlog (MKT-prefixed)
  INDEX.md                  # Task registry table
  {MKT-NNN-title}/          # Task directories with TASK.md, PROGRESS.md, REVIEW.md
  archive/                  # Completed tasks
.claude-plugin/marketplace.json  # Claude catalog (SOURCE OF TRUTH)
.agents/plugins/marketplace.json # GENERATED Codex catalog
scripts/generate-codex-marketplace.py  # Dual-ship generator
docs/MULTI_HARNESS.md       # Install matrix and authoring rules
design.yaml                 # Repo config (prefix: MKT, repo_name)
install-opencode.sh         # Cross-platform installer for OpenCode
```

## Multi-harness maintenance

After editing `.claude-plugin/marketplace.json` or plugin manifests:

```bash
python3 scripts/generate-codex-marketplace.py
python3 scripts/generate-codex-marketplace.py --check
```

See `docs/MULTI_HARNESS.md`.

## Core workflow plugin

**up** - Context bootstrap: `/up` reads CLAUDE.md, `/up:plan` adds PRD.md, `/up:prompt` loads PROMPT.md. Task design/backlog loop plugins (`design`, `backlog`, `pm`) are **not** listed in the marketplace; harness-native loops replace them.

## Plugin Component Formats

### Commands (`commands/*.md`)
```yaml
---
description: One-line description
argument-hint: <arg> [--flag]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---
# Markdown body with execution instructions
```
`$ARGUMENTS` is the placeholder for user-provided arguments.

### Hooks (`hooks/hooks.json` + `hooks/*.sh`)
Events: `SessionStart`, `PostToolUse` (with `matcher` regex), `Stop`. Scripts read JSON from stdin, output `{"decision": "approve|block", "reason": "...", "systemMessage": "..."}`. Use `${CLAUDE_PLUGIN_ROOT}` for paths.

### Agents (`agents/*.md`)
```yaml
---
name: agent-name
description: Trigger description for agent matching
tools: Read, Glob, Grep, Bash
model: haiku
---
# System prompt with step-by-step instructions and output format
```

### Skills (`skills/{name}/SKILL.md`)
YAML frontmatter with `name`, `description`, `metadata.short-description`. Supporting files (checklists, patterns, references) live alongside SKILL.md.

## Task System

Task IDs follow `{PREFIX}-{NNN}` format (e.g., `MKT-001`). Prefix comes from `design.yaml` (`repo_prefix` field). Tasks use `<promise>` tags for agent lifecycle control:
- `<promise>PHASE_DONE</promise>` or `<promise>TASK_COMPLETE</promise>` - allow exit
- `<promise>BLOCKED: reason</promise>` - allow exit with blocker
- `<promise>REVIEW_COMPLETE</promise>` - review agent finished

The Stop hook (`plugins/backlog/hooks/stop-hook.sh`) checks for `.claude/backlog-agent.local.md` state file and enforces a hard safety cap of 10 iterations even when unlimited.

## OpenCode Compatibility

Each plugin has an `.opencode/` directory mirroring its commands/agents/skills for OpenCode installation. Command names may differ slightly by harness (e.g. `plugin:command` vs `plugin-command`). The `install-opencode.sh` script copies files to `~/.config/opencode/`.

## Submodule Management

All 18 plugins are git submodules. After cloning:
```bash
git submodule update --init --recursive
```

To update a single plugin submodule:
```bash
cd plugins/{name}
git pull origin main
cd ../..
git add plugins/{name}
git commit -m "chore: update {name} plugin"
```

## Known Issue

The design plugin depends on backlog's `scripts/deps.sh` for dependency graph validation. This cross-plugin reference is fragile due to versioned plugin cache directories. See `TODO.md` for consolidation options - recommended approach is merging design into backlog.

## DeFi Protocol Skill Plugins

Plugins like `balancer-v3`, `aave-v3`, `uniswap-v4`, etc. are read-only skill collections providing progressive disclosure documentation for DeFi protocol integration. They contain only `skills/` directories with SKILL.md files and reference docs - no commands, hooks, or agents.
