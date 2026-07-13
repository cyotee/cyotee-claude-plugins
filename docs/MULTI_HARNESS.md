# Multi-harness distribution

This marketplace ships **Agent Skills** and plugins for several coding agents from one source tree.

## Source of truth

| Artifact | Role |
|----------|------|
| `plugins/<name>/` | Plugin content (skills, commands, agents, hooks) |
| `.claude-plugin/marketplace.json` | **Claude Code** catalog (primary registry) |
| `plugins/<name>/.claude-plugin/plugin.json` | Claude per-plugin manifest |

**Do not hand-edit Codex registries.** Generate them:

```bash
python3 scripts/generate-codex-marketplace.py
python3 scripts/generate-codex-marketplace.py --check   # CI / pre-commit drift check
```

## Generated (Codex dual-ship)

| Artifact | Role |
|----------|------|
| `.agents/plugins/marketplace.json` | Codex repo marketplace |
| `plugins/<name>/.codex-plugin/plugin.json` | Codex per-plugin manifest |

Pattern matches common multi-harness publishers: small committed registries + shared `skills/` trees.

## Capability matrix (honest)

| Layer | Claude Code | Grok Build | Codex CLI | OpenCode |
|-------|-------------|------------|-----------|----------|
| Skills (`SKILL.md`) | ✅ | ✅ | ✅ | ✅ (bridge / install script) |
| Marketplace install | ✅ native | ✅ Claude-compatible | ✅ via `.agents/plugins` | Bridge (`opencode-marketplace`) |
| Slash commands | ✅ | Partial | Often as skills only | Partial (translated) |
| Agents | ✅ | Partial | Different format | Partial |
| Hooks | ✅ | Partial (compat env) | Different trust/schema | Needs TS plugin adaption |
| MCP in plugin | ✅ | Partial | ✅ if bundled | Partial |

**Skills are the portable product.** Hooks and harness-specific automation may be Claude-first.

## Install

### Claude Code

```bash
/plugin marketplace add cyotee/cyotee-claude-plugins
/plugin install crane@cyotee
/plugin install defi-ui-testing@cyotee
```

### Codex CLI

```bash
# After cloning with submodules (plugins live under ./plugins/)
git clone --recurse-submodules https://github.com/cyotee/cyotee-claude-plugins.git
cd cyotee-claude-plugins
git submodule update --init --recursive

codex plugin marketplace add .
# or after publish:
# codex plugin marketplace add cyotee/cyotee-claude-plugins

# Interactive: /plugins → select marketplace → install
```

Codex loads skills from each plugin’s `skills/` via `.codex-plugin/plugin.json`.

### Grok Build

```bash
grok plugin marketplace add cyotee/cyotee-claude-plugins
# or local path
grok plugin marketplace add ./cyotee-claude-plugins
```

Grok also discovers skills under `.claude/skills` and project skill dirs.

### OpenCode

```bash
# Marketplace bridge (this monorepo’s sibling / package)
# or:
./install-opencode.sh crane foundry defi-ui-testing playwright
```

### Skills-only escape hatch (any Agent Skills client)

```bash
# Example: copy one plugin’s skills into Codex/agents skill root
cp -R plugins/crane/skills/* ~/.agents/skills/
# or project-local:
mkdir -p .agents/skills
cp -R plugins/defi-ui-testing/skills/* .agents/skills/
```

## Authoring rules

1. Add/update skills under `plugins/<name>/skills/<skill>/SKILL.md` (agentskills.io shape).
2. Register the plugin in **Claude** `.claude-plugin/marketplace.json` if new.
3. Run `python3 scripts/generate-codex-marketplace.py`.
4. Commit Claude SoT **and** generated Codex files together.
5. Document Claude-only behavior (hooks) in the plugin README when relevant.

## Regenerating after marketplace edits

```bash
# Edit Claude catalog or plugin manifests, then:
python3 scripts/generate-codex-marketplace.py
python3 scripts/generate-codex-marketplace.py --check
```

Root-level `plugins/<name>/SKILL.md` files (legacy single-skill plugins) are promoted into `skills/<name>/SKILL.md` by the generator when no skill packages exist yet.
