# cyotee-claude-plugins

A Claude Code plugin marketplace providing development workflow commands for managing complex projects with directory-based task management, git worktrees, and autonomous agent execution.

## Installation

```bash
# Add this marketplace (one-time)
/plugin marketplace add cyotee/cyotee-claude-plugins

# Install individual plugins
/plugin install up@cyotee
/plugin install design@cyotee
/plugin install backlog@cyotee

# Or browse available plugins
/plugin
```

## Plugins

### up - Context Bootstrap

Commands for loading project context from documentation files.

| Command | Description |
|---------|-------------|
| `/up` | Read CLAUDE.md and referenced documentation to understand the codebase |
| `/up:plan` | Read CLAUDE.md + PRD.md for project requirements and task overview |
| `/up:prd` | Alias for `/up:plan` |
| `/up:prompt` | Read CLAUDE.md + PROMPT.md for agent worktree execution |

### design - Task Design

Interactive design sessions for creating and refining tasks with user stories.

| Command | Description |
|---------|-------------|
| `/design <feature>` | Start interactive design session to create a new task |
| `/design:task <feature>` | Same as `/design` - create task in tasks/ directory |
| `/design:init` | Initialize tasks/ directory structure in a repository |
| `/design:prd` | Interactive PRD creation for project-level requirements |
| `/design:review` | Review all tasks for completeness and quality |
| `/design:review <N>` | Review and refine a specific task |

### backlog - Task Management

Manage your tasks/ directory backlog and git worktrees.

| Command | Description |
|---------|-------------|
| `/backlog` | Display task status summary table |
| `/backlog:status` | Same as `/backlog` - show all tasks |
| `/backlog:read <ID>` | View detailed task information (PRD, progress, review) |
| `/backlog:launch <ID>` | Create git worktree and launch agent for task |
| `/backlog:complete [ID]` | Rebase, merge to main, and prepare for review |
| `/backlog:prune [ID]` | Archive completed/reviewed tasks |

## Task ID Format

Tasks use layer-prefixed IDs. Layers are detected dynamically:

1. Scan for `tasks/` directories in the repository
2. Read `tasks/INDEX.md` for layer name and prefix
3. If not found, auto-detect from directory/repo name
4. Prefix is first letter of layer name (uppercase)

Examples: `P-5`, `M-3`, `L-1` (prefixes depend on your project names)

## Workflow

These plugins support a structured development workflow:

```
1. /up                    # Load project context
2. /design:init           # Create tasks/ structure (first time)
3. /design <feature>      # Design a new feature with user stories
4. /backlog               # View all tasks
5. /backlog:launch P-5    # Create worktree for task P-5
6. (work in worktree)     # Agent executes task
7. /backlog:complete P-5  # Rebase and request review
8. /backlog:prune P-5     # Archive after review passes
```

### Agent Worktree Execution

For autonomous agent execution in worktrees:

```bash
# After /backlog:launch creates the worktree
cd <worktree-path>
claude --dangerously-skip-permissions

# In Claude, start the agent loop
/ralph-loop:ralph-loop "Read PROMPT.md and execute the task." --completion-promise "TASK_COMPLETE"
```

## Task Directory Structure

Each task is a directory containing:

```
tasks/
├── [P]-1/
│   ├── PRD.md        # Requirements and acceptance criteria
│   ├── PROGRESS.md   # Reverse-chronological progress log
│   └── REVIEW.md     # Review findings and verdict
├── [P]-2/
│   └── ...
├── archive/          # Completed tasks moved here
└── INDEX.md          # Task index with status overview
```

## Related Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project documentation, architecture, and conventions |
| `PRD.md` | Global product requirements document |
| `tasks/INDEX.md` | Task index with status table |
| `tasks/[ID]/PRD.md` | Task-specific requirements and acceptance criteria |
| `tasks/[ID]/PROGRESS.md` | Agent progress log (reverse chronological) |
| `tasks/[ID]/REVIEW.md` | Review findings and verdict |
| `PROMPT.md` | Agent task instructions (created in worktrees) |

## Task Lifecycle

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  /design        │ ──▶ │  tasks/[ID]/     │ ──▶ │  🆕 pending     │
│  <feature>      │     │  PRD.md created  │     │                 │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │
                        ┌──────────────────┐              ▼
                        │  Agent Working   │     ┌─────────────────┐
                        │  in Worktree     │ ◀── │  /backlog:      │
                        │  🚀 in_progress  │     │  launch <ID>    │
                        └────────┬─────────┘     └─────────────────┘
                                 │
                                 ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Different      │ ◀── │  /backlog:       │ ◀── │  🚀 in_progress │
│  Agent Reviews  │     │  complete <ID>   │     │  Work done      │
│  📋 review      │     │  📋 review       │     │                 │
└────────┬────────┘     └──────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│  /backlog:      │ ──▶ │  tasks/archive/  │
│  prune <ID>     │     │  ✅ complete     │
└─────────────────┘     └──────────────────┘
```

## Task States

| State | Icon | Description |
|-------|------|-------------|
| pending | 🆕 | Ready to start, dependencies met |
| in_progress | 🚀 | Agent actively working |
| review | 📋 | Work complete, awaiting review |
| complete | ✅ | Reviewed and approved |
| blocked | ❌ | Waiting on dependencies |

## Requirements

- **git-wt** or **wt-create.sh**: Git worktree helper (for `/backlog:launch`)
- **CLAUDE.md**: Project documentation file
- **tasks/**: Task directory (created by `/design:init` if missing)

## License

MIT
