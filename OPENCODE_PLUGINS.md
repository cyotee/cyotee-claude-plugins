# OpenCode Plugin Compatibility Guide

This document analyzes the feasibility of making Claude Code plugins compatible with [OpenCode](https://opencode.ai/), enabling plugins to work in both environments.

## Executive Summary

**Compatibility Level: High**

OpenCode and Claude Code share remarkably similar architectures for commands and agents (both use markdown files with YAML frontmatter). OpenCode also has **native support for CLAUDE.md files**, making cross-compatibility very achievable with minor adaptations.

---

## Architecture Comparison

### Plugin Discovery

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| **Manifest** | `.claude-plugin/plugin.json` | `opencode.json` |
| **Plugin Location** | `plugins/` directory | `.opencode/` or `~/.config/opencode/` |
| **NPM Support** | No | Yes (`"plugin": ["package-name"]`) |

### Commands

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| **Location** | `commands/*.md` | `.opencode/commands/*.md` |
| **Format** | Markdown + YAML frontmatter | Markdown + YAML frontmatter |
| **Invocation** | `/command-name` | `/command-name` |
| **Arguments** | `argument-hint` field | `$ARGUMENTS`, `$1`, `$2` in template |
| **Tool Restriction** | `allowed-tools: Read, Write` | Not in frontmatter (uses agent config) |
| **Model Override** | `model: sonnet` | `model: provider/model-id` |
| **Agent Assignment** | N/A | `agent: agent-name` |

**Key Differences:**
- OpenCode supports shell injection with `` !`command` `` syntax
- OpenCode has `subtask` option for specialized execution contexts
- Claude Code restricts tools per-command; OpenCode restricts per-agent

### Agents

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| **Location** | `agents/*.md` | `.opencode/agents/*.md` |
| **Format** | Markdown + YAML frontmatter | Markdown + YAML frontmatter |
| **Name Field** | `name: agent-name` | Filename becomes name |
| **Description** | `description:` | `description:` (required) |
| **Tools** | `tools: Read, Glob, Grep` | `tools: { read: true, glob: true }` |
| **Model** | `model: sonnet` | `model: provider/model-id` |
| **Mode** | Implicit (all are subagents) | `mode: primary\|subagent` |
| **Temperature** | Not supported | `temperature: 0.0-1.0` |
| **Max Steps** | Not supported | `maxSteps: N` |

**OpenCode-Only Features:**
- `temperature` control
- `maxSteps` limit for agentic iterations
- `taskPermissions` to control subagent invocation
- Primary vs subagent distinction

### Rules/Instructions

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| **Project File** | `CLAUDE.md` | `AGENTS.md` (falls back to `CLAUDE.md`) |
| **Global File** | `~/.claude/CLAUDE.md` | `~/.config/opencode/AGENTS.md` |
| **Skills Directory** | `~/.claude/skills/` | Supported via compatibility layer |

**Native Compatibility:** OpenCode reads `CLAUDE.md` files if no `AGENTS.md` exists.

### Hooks

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| **Definition** | `hooks/hooks.json` + shell scripts | JavaScript/TypeScript modules |
| **Events** | `SessionStart`, `PostToolUse`, `Stop`, etc. | `session.created`, `tool.execute.before`, etc. |
| **Execution** | Shell commands | Async JavaScript functions |

**Event Mapping:**

| Claude Code Event | OpenCode Equivalent |
|-------------------|---------------------|
| `SessionStart` | `session.created` |
| `PostToolUse` | `tool.execute.after` |
| `PreToolUse` | `tool.execute.before` |
| `Stop` | `session.idle` or custom |
| `PreCompact` | `experimental.session.compacting` |

### Tools

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| **Built-in Tools** | ~15 tools | 13 tools |
| **Custom Tools** | Not directly supported | TypeScript/Zod definitions |
| **Permissions** | Per-command frontmatter | Global config (`allow`/`deny`/`ask`) |
| **MCP Support** | Yes | Yes |

**Common Built-in Tools:** `bash`, `edit`, `write`, `read`, `grep`, `glob`, `todowrite`, `webfetch`

**OpenCode Additions:** `list`, `lsp`, `patch`, `skill`, `question`, `todoread`

---

## Compatibility Matrix

| Component | Compatibility | Effort Required |
|-----------|---------------|-----------------|
| CLAUDE.md / AGENTS.md | Native | None |
| Commands | High | Frontmatter translation |
| Agents | High | Frontmatter translation |
| Bash Scripts | Native | None |
| Hooks | Low | Rewrite in JavaScript |
| Custom Tools | Low | Rewrite in TypeScript |
| Skills | Medium | Path/structure adaptation |

---

## Recommended Dual-Format Structure

```
plugins/{plugin-name}/
├── .claude-plugin/
│   └── plugin.json              # Claude Code manifest
├── .opencode/
│   ├── commands/                # OpenCode-format commands
│   │   └── {command}.md
│   └── agents/                  # OpenCode-format agents
│       └── {agent}.md
├── commands/                    # Claude Code commands (source of truth)
│   └── {command}.md
├── agents/                      # Claude Code agents (source of truth)
│   └── {agent}.md
├── hooks/
│   ├── hooks.json               # Claude Code hooks
│   └── *.sh                     # Shared shell scripts
├── opencode-hooks/              # OpenCode JavaScript hooks
│   └── index.ts
├── scripts/                     # Shared utilities (both platforms)
│   └── *.sh
└── build/
    └── translate.ts             # Build script for translation
```

---

## Translation Examples

### Command Translation

**Claude Code (`commands/backlog.md`):**
```yaml
---
description: Display task status summary from tasks/INDEX.md
argument-hint: [--graph] [--critical-path] [--order]
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Bash, TodoWrite
model: sonnet
---
```

**OpenCode (`.opencode/commands/backlog.md`):**
```yaml
---
description: Display task status summary from tasks/INDEX.md
agent: backlog-agent
model: anthropic/claude-sonnet
---
```

Note: OpenCode tool restrictions go on the agent, not the command.

### Agent Translation

**Claude Code (`agents/code-auditor.md`):**
```yaml
---
name: code-auditor
description: Comprehensive automated code review that populates REVIEW.md
tools: Read, Glob, Grep, Bash
model: sonnet
---
```

**OpenCode (`.opencode/agents/code-auditor.md`):**
```yaml
---
description: Comprehensive automated code review that populates REVIEW.md
mode: subagent
model: anthropic/claude-sonnet
tools:
  read: true
  glob: true
  grep: true
  bash: true
  write: false
  edit: false
---
```

### Hook Translation

**Claude Code (`hooks/hooks.json`):**
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
      }]
    }]
  }
}
```

**OpenCode (`opencode-hooks/index.ts`):**
```typescript
import { execSync } from 'child_process'

export const BacklogPlugin = async ({ directory }) => {
  return {
    'session.created': async () => {
      execSync('./hooks/session-start.sh', { cwd: directory })
    }
  }
}
```

---

## Implementation Approach

### Phase 1: Shared Content (Low Effort)
1. Keep `CLAUDE.md` as the single source - OpenCode reads it natively
2. Share all bash scripts in `scripts/` - work identically in both
3. Document command/agent equivalents

### Phase 2: Build Tooling (Medium Effort)
1. Create a translation script that:
   - Reads Claude Code command/agent markdown
   - Transforms frontmatter fields
   - Outputs to `.opencode/` directories
2. Add to CI/CD or pre-commit hooks

### Phase 3: Hook Adaptation (Higher Effort)
1. Create JavaScript wrappers that call existing shell scripts
2. Map Claude Code events to OpenCode events
3. Package as OpenCode plugin module

### Phase 4: NPM Distribution (Optional)
1. Package adapted plugins for npm
2. Users install via `opencode.json`: `"plugin": ["@cyotee/backlog-plugin"]`

---

## OpenCode-Specific Features to Consider

Features available in OpenCode that could enhance plugins:

1. **LSP Integration** - Code intelligence (go-to-definition, references)
2. **Temperature Control** - Fine-tune agent creativity
3. **Max Steps** - Limit agentic iterations
4. **Patch Tool** - Apply unified diffs
5. **Question Tool** - Structured user prompts
6. **Session Compaction Hooks** - Inject context during summarization

---

## Environment Variables

OpenCode respects these for Claude Code compatibility:

```bash
# Disable CLAUDE.md reading
OPENCODE_DISABLE_CLAUDE_MD=1

# Disable global Claude config
OPENCODE_DISABLE_CLAUDE_GLOBAL=1

# Disable Claude skills directory
OPENCODE_DISABLE_CLAUDE_SKILLS=1
```

---

## References

- [OpenCode Plugins Documentation](https://opencode.ai/docs/plugins/)
- [OpenCode Tools Documentation](https://opencode.ai/docs/tools/)
- [OpenCode Commands Documentation](https://opencode.ai/docs/commands/)
- [OpenCode Rules Documentation](https://opencode.ai/docs/rules/)
- [OpenCode Agents Documentation](https://opencode.ai/docs/agents/)
- [OpenCode Custom Tools Documentation](https://opencode.ai/docs/custom-tools/)

---

## Unconvertible Features

The following Claude Code plugin features could not be directly converted to OpenCode:

### 1. Hooks System

**Claude Code:**
```json
{
  "hooks": {
    "SessionStart": [{ "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh" }],
    "PostToolUse": [{ "matcher": "Write|Edit", "command": "..." }],
    "Stop": [{ "command": "..." }]
  }
}
```

**Why not convertible:**
- OpenCode uses JavaScript event handlers, not shell commands
- Different event model (`session.created` vs `SessionStart`)
- Requires rewriting hooks as TypeScript modules

**Workaround:** Create `opencode-hooks/index.ts` that wraps existing shell scripts:
```typescript
import { execSync } from 'child_process'
export const Plugin = async ({ directory }) => ({
  'session.created': () => execSync('./hooks/session-start.sh', { cwd: directory })
})
```

### 2. `${CLAUDE_PLUGIN_ROOT}` Variable

**Claude Code:** Commands reference scripts via `${CLAUDE_PLUGIN_ROOT}/scripts/deps.sh`

**Why not convertible:**
- OpenCode has no equivalent plugin root variable
- Scripts need to be either:
  - Installed to a known location
  - Referenced by absolute path
  - Bundled with npm package

**Workaround:** Use relative paths or install scripts globally.

### 3. Plugin Namespacing

**Claude Code:** `/backlog:launch`, `/design:init` (plugin:command format)

**OpenCode:** `/backlog-launch`, `/design-init` (flat namespace by filename)

**Why not convertible:**
- OpenCode commands are identified by filename
- No built-in plugin namespace mechanism
- Cross-references need different syntax

**Workaround:** Use hyphenated names (`/backlog-launch` instead of `/backlog:launch`).

### 4. `allowed-tools` Per-Command

**Claude Code:**
```yaml
---
allowed-tools: Read, Write, Edit, Grep, Glob
---
```

**OpenCode:** Tool restrictions are per-agent, not per-command.

**Workaround:** Create dedicated agents with restricted tool access for sensitive commands.

### 5. Skills Directory Structure

**Claude Code:**
```
skills/
  code-reviewer/
    SKILL.md
    checklist.md
    patterns.md
```

**OpenCode:** Skills are loaded via the `skill` tool with different structure.

**Workaround:** Adapt SKILL.md files to OpenCode's expected format.

### 6. Prompt-Based Hooks

**Claude Code:** `PreToolUse` and `PostToolUse` hooks with `matcher` patterns and prompt-based responses.

**OpenCode:** Uses `tool.execute.before` and `tool.execute.after` with JavaScript handlers.

**Why not convertible:**
- Claude Code hooks can return natural language prompts
- OpenCode hooks return programmatic results

### 7. Stop Hook with Promise Tags

**Claude Code:** Stop hook checks for `<promise>TASK_COMPLETE</promise>` tags.

**OpenCode:** No equivalent mechanism for preventing session exit based on content.

**Workaround:** Use session management differently or implement custom validation.

---

## Migration Checklist

When migrating a Claude Code plugin to OpenCode:

- [x] Commands (`.md` files) - Translate frontmatter, update cross-references
- [x] Agents (`.md` files) - Translate frontmatter, add `mode` field
- [x] `opencode.json` manifest - Create from `plugin.json`
- [ ] Hooks - Rewrite as TypeScript event handlers
- [ ] Skills - Adapt to OpenCode skill format
- [ ] Scripts - Update paths, remove `${CLAUDE_PLUGIN_ROOT}`
- [ ] Cross-references - Update `/plugin:command` to `/plugin-command`
