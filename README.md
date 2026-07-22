# cyotee-claude-plugins

A multi-harness plugin marketplace: **Agent Skills** and workflow plugins for Claude Code, Codex CLI, Grok Build, and OpenCode. Claude-format catalog is the source of truth; Codex artifacts are generated.

**Audience:** developers and agents **building and testing** smart contracts (architecture, Foundry, protocol deep-dives). For on-chain *operations* (cast/Bankr runbooks), use sibling marketplace **[defi-agent-skills](https://github.com/cyotee/defi-agent-skills)**.

**Flagship:** the **`crane`** plugin for the [Crane](https://github.com/cyotee/crane) Diamond-first (ERC-2535) Solidity framework — docs at [cyotee.github.io/crane](https://cyotee.github.io/crane/).

Portable unit: `skills/*/SKILL.md` ([agentskills.io](https://agentskills.io)). Hooks and some commands remain harness-specific — see [docs/MULTI_HARNESS.md](docs/MULTI_HARNESS.md).

> **Disclaimer:** Protocol skills document third-party systems (Aave, Uniswap, Balancer, etc.) for engineering education. They are **not** official products of those teams unless stated otherwise.

## Installation

### Claude Code

```bash
# Add this marketplace (one-time)
/plugin marketplace add cyotee/cyotee-claude-plugins

# Install individual plugins
/plugin install up@cyotee
/plugin install crane@cyotee
/plugin install defi-ui-testing@cyotee

# Or browse available plugins
/plugin
```

### Codex CLI

Codex reads the dual-ship registry at `.agents/plugins/marketplace.json` and each plugin’s `.codex-plugin/plugin.json` (generated from Claude SoT).

```bash
git clone --recurse-submodules https://github.com/cyotee/cyotee-claude-plugins.git
cd cyotee-claude-plugins
git submodule update --init --recursive

codex plugin marketplace add .
# after push to GitHub:
# codex plugin marketplace add cyotee/cyotee-claude-plugins

# Then in Codex: /plugins → install crane, foundry, playwright, etc.
```

Regenerate Codex artifacts after editing the Claude catalog:

```bash
python3 scripts/generate-codex-marketplace.py
python3 scripts/generate-codex-marketplace.py --check
```

### Grok Build

```bash
grok plugin marketplace add cyotee/cyotee-claude-plugins
# or a local checkout
grok plugin marketplace add /path/to/cyotee-claude-plugins
```

### OpenCode

These plugins are also compatible with [OpenCode](https://opencode.ai/). To install:

```bash
# Clone the repository
git clone --recurse-submodules https://github.com/cyotee/cyotee-claude-plugins.git
cd cyotee-claude-plugins
git submodule update --init --recursive

# Install all plugins
./install-opencode.sh

# Or install specific plugins
./install-opencode.sh up
./install-opencode.sh defi-ui-testing playwright synpress

# To uninstall
./install-opencode.sh --uninstall
```

See [OPENCODE_PLUGINS.md](OPENCODE_PLUGINS.md) and [docs/MULTI_HARNESS.md](docs/MULTI_HARNESS.md) for full compatibility details.

## Plugins

### up - Context Bootstrap

Commands for loading project context from documentation files.

| Command | Description |
|---------|-------------|
| `/up` | Read CLAUDE.md and referenced documentation to understand the codebase |
| `/up:plan` | Read CLAUDE.md + PRD.md for project requirements and task overview |
| `/up:prd` | Alias for `/up:plan` |
| `/up:prompt` | Read CLAUDE.md + PROMPT.md for agent worktree execution |

### Crane & Solidity tooling

| Plugin | Description |
|--------|-------------|
| `crane` | Diamond (ERC-2535) framework — architecture, testing, deployment, DeFi integrations, Chainlink VRF |
| `foundry` | Forge, cast, anvil, signing cheatcodes, Supersim Superchain local testing |

### DeFi protocol skills

| Plugin | Description |
|--------|-------------|
| `aave-v3` / `aave-v4` | Aave lending protocol |
| `aerodrome` / `aerodrome-slipstream` | Aerodrome ve(3,3) AMM and concentrated liquidity |
| `balancer-v3` | Balancer V3 Vault, pools, hooks |
| `chainlink` | Chainlink VRF and local testing |
| `compound-v3-comet` | Compound V3 Comet money market |
| `euler-lending` | Euler EVC/EVK lending |
| `permit2` | Uniswap Permit2 signature approvals |
| `reliquary` | Maturity-based Relic NFT incentives |
| `resupply` | Resupply protocol |
| `uniswap-v3` / `uniswap-v4` | Uniswap concentrated liquidity and hooks |

### TypeScript / frontend Ethereum

| Plugin | Description |
|--------|-------------|
| `tevm` | Browser EVM for local testing and debugging |
| `voltaire-effect` | Effect.ts + Voltaire typed Ethereum primitives |
| `wagmi` | React/vanilla Ethereum hooks and connectors |

### DeFi UI E2E testing

| Plugin | Description |
|--------|-------------|
| `playwright` | Browser E2E runner, fixtures, webServer orchestration |
| `synpress` | Web3 E2E with MetaMask wallet setup caching |
| `metamask` | Wallet domain knowledge: networks, txs, approvals |
| `defi-ui-testing` | Method A (Wagmi mock + Anvil) and Method B (Synpress + MetaMask) playbooks |

## Related

| Resource | Link |
|----------|------|
| Crane framework | [github.com/cyotee/crane](https://github.com/cyotee/crane) · [docs](https://cyotee.github.io/crane/) |
| Ops marketplace | [defi-agent-skills](https://github.com/cyotee/defi-agent-skills) |
| Multi-harness notes | [docs/MULTI_HARNESS.md](docs/MULTI_HARNESS.md) |

Agent loops and task orchestration are left to each harness’s built-in features (Claude, Codex, Grok, OpenCode). This marketplace focuses on **skills and domain plugins**.

## License

MIT — see [LICENSE](LICENSE). Individual plugins may note additional terms in their manifests.
