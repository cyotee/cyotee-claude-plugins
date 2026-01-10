# cyotee-claude-plugins

A Claude Code plugin marketplace providing development workflow commands for managing complex projects with UNIFIED_PLAN.md task backlogs, git worktrees, and autonomous agent execution.

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
| `/up:plan` | Read CLAUDE.md + UNIFIED_PLAN.md to see project context and task status |
| `/up:prompt` | Read CLAUDE.md + PROMPT.md for agent worktree execution |

### design - Task Design

Interactive design sessions for creating and refining tasks with user stories.

| Command | Description |
|---------|-------------|
| `/design <feature>` | Start interactive design session to create a new task |
| `/design:task <feature>` | Same as `/design` - create task in UNIFIED_PLAN.md |
| `/design:review` | Review all tasks for completeness and quality |
| `/design:review <N>` | Review and refine a specific task |

### backlog - Task Management

Manage your UNIFIED_PLAN.md task backlog and git worktrees.

| Command | Description |
|---------|-------------|
| `/backlog` | Display task status summary table |
| `/backlog:status` | Same as `/backlog` - show all tasks |
| `/backlog:launch <N>` | Create git worktree and PROMPT.md for task N |
| `/backlog:complete [N]` | Rebase, merge to main, and prepare worktree cleanup |
| `/backlog:prune` | Archive completed tasks from UNIFIED_PLAN.md |

## Workflow

These plugins support a structured development workflow:

```
1. /up                    # Load project context
2. /design <feature>      # Design a new feature with user stories
3. /backlog               # View all tasks
4. /backlog:launch 5      # Create worktree for task 5
5. (work in worktree)     # Agent executes task
6. /backlog:complete 5    # Merge completed work
7. /backlog:prune         # Archive completed tasks
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

## Related Files

These commands work with standard project files:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project documentation, architecture, and conventions |
| `UNIFIED_PLAN.md` | Task backlog with user stories and completion criteria |
| `PROMPT.md` | Agent task instructions (created in worktrees by `/backlog:launch`) |

## Task Lifecycle

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  /design        │ ──▶ │  UNIFIED_PLAN.md │ ──▶ │  Ready for      │
│  <feature>      │     │  Task Created    │     │  Agent          │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │
                                                          ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  /backlog:      │ ◀── │  Agent Working   │ ◀── │  /backlog:      │
│  complete       │     │  in Worktree     │     │  launch <N>     │
└────────┬────────┘     └──────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│  /backlog:      │ ──▶ │  Archived        │
│  prune          │     │                  │
└─────────────────┘     └──────────────────┘
```

## Requirements

- **git-wt**: Git worktree helper (for `/backlog:launch`)
- **CLAUDE.md**: Project documentation file
- **UNIFIED_PLAN.md**: Task backlog (created by `/design` if missing)

## License

MIT
