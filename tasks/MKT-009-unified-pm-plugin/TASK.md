# Task MKT-009: Unified PM Plugin

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-02-07
**Dependencies:** None
**Worktree:** `feature/MKT-009-unified-pm-plugin`

---

## Description

Create a new unified plugin named `pm` that consolidates the `design` (v4.0.1) and `backlog` (v5.4.1) plugins into a single project management plugin. The new plugin lives in its own repository (`cyotee/claude-pm-plugin.git`) as a submodule. It must be backwards compatible with the existing `tasks/` directory format, `INDEX.md` format, `design.yaml` configuration, and `TASK.md`/`PROGRESS.md`/`REVIEW.md` file structures. The old plugins remain installed as fallback until full deprecation.

## Dependencies

None

## User Stories

### US-MKT-009.1: Plugin Scaffolding

As a plugin developer, I want the `pm` plugin to follow the standard Claude Code plugin structure so that it installs and loads correctly.

**Acceptance Criteria:**
- [ ] `.claude-plugin/plugin.json` with name `pm`, version `1.0.0`, proper metadata
- [ ] Repository at `https://github.com/cyotee/claude-pm-plugin.git`
- [ ] Added as submodule at `plugins/pm` in the marketplace repo
- [ ] Entry added to `.claude-plugin/marketplace.json`
- [ ] OpenCode compatibility layer in `.opencode/` directory with `opencode.json`
- [ ] Build/translate scripts for OpenCode format conversion

### US-MKT-009.2: Dashboard Command (`/pm`)

As a user, I want to run `/pm` to see a dependency-aware task status dashboard so that I can quickly understand project state.

**Acceptance Criteria:**
- [ ] `commands/pm.md` — displays dashboard from `tasks/INDEX.md`
- [ ] Builds full dependency graph (including cross-repo submodule tasks)
- [ ] Computes effective status (Ready/Blocked cascading based on dependencies)
- [ ] Shows summary stats: Complete/In Progress/In Review/Ready/Blocked counts
- [ ] Supports `--graph` flag for ASCII dependency visualization
- [ ] Supports `--critical-path` flag for longest dependency chain
- [ ] Supports `--order` flag for topological sort / recommended task order
- [ ] Suggests status corrections when computed differs from stored

### US-MKT-009.3: Task List Command (`/pm:list`)

As a user, I want to run `/pm:list` to see a simple task inventory table so that I can see all tasks at a glance.

**Acceptance Criteria:**
- [ ] `commands/list.md` — displays task table with computed status and worktree info
- [ ] Default view: table + summary + next actions
- [ ] Supports `--worktrees-only` flag showing only active worktrees with paths and modes
- [ ] Uses `scripts/index-to-json.sh` and `scripts/format-task-list.sh` for rendering

### US-MKT-009.4: Help Command (`/pm:help`)

As a user, I want to run `/pm:help` to see all available commands with descriptions and flags so that I can discover plugin capabilities.

**Acceptance Criteria:**
- [ ] `commands/help.md` — static reference listing all commands
- [ ] Each command entry shows: name, description, arguments/flags, and brief example
- [ ] Organized into sections: Overview, Planning, Execution, Review, Maintenance
- [ ] Lists all available agents and skills with one-line descriptions

### US-MKT-009.5: Task Design Command (`/pm:design`)

As a user, I want to run `/pm:design <feature>` to interactively create a new task so that requirements are well-defined before implementation.

**Acceptance Criteria:**
- [ ] `commands/design.md` — interactive 4-round Q&A to gather requirements
- [ ] Reads `design.yaml` for repo prefix and name
- [ ] Auto-detects next task number from existing directories
- [ ] Creates task directory: `tasks/{PREFIX}-{NNN}-{kebab-name}/`
- [ ] Generates TASK.md with user stories, acceptance criteria, technical details, file lists
- [ ] Generates PROGRESS.md and REVIEW.md from templates
- [ ] Updates `tasks/INDEX.md` with new entry
- [ ] Validates dependencies using internal `scripts/deps.sh` (no cross-plugin reference)
- [ ] Detects and prevents circular dependencies

### US-MKT-009.6: Project Init Command (`/pm:init`)

As a user, I want to run `/pm:init` to set up task management in a new repository so that I can start using the PM workflow.

**Acceptance Criteria:**
- [ ] `commands/init.md` — creates `design.yaml`, `tasks/` directory, `INDEX.md`, `TEMPLATE.md`, `tasks/archive/`
- [ ] Asks user for repo prefix and name if `design.yaml` missing
- [ ] Idempotent — safe to run on already-initialized repos

### US-MKT-009.7: PRD Command (`/pm:prd`)

As a user, I want to run `/pm:prd` to interactively create a project-level PRD.md so that project context is documented.

**Acceptance Criteria:**
- [ ] `commands/prd.md` — 4-round interactive Q&A
- [ ] Generates PRD.md at repo root with vision, goals, features, constraints, milestones
- [ ] Offers to run `/pm:init` if task management not set up

### US-MKT-009.8: Document Digest Command (`/pm:digest`)

As a user, I want to run `/pm:digest <file>` to parse an existing document into tasks so that I can quickly populate a backlog from specs.

**Acceptance Criteria:**
- [ ] `commands/digest.md` — reads document, identifies tasks, creates them interactively
- [ ] Supports multi-repo/submodule task creation
- [ ] Maps cross-repo dependencies
- [ ] Gets user confirmation for each task before creation

### US-MKT-009.9: Task Read Command (`/pm:read`)

As a user, I want to run `/pm:read <task-id>` to view a task's full details so that I can understand requirements before working.

**Acceptance Criteria:**
- [ ] `commands/read.md` — displays TASK.md, PROGRESS.md, REVIEW.md for given task ID
- [ ] Read-only operation

### US-MKT-009.10: Launch Agent Command (`/pm:launch`)

As a user, I want to run `/pm:launch <task-id>` to create an isolated worktree with agent context so that tasks execute in clean environments.

**Acceptance Criteria:**
- [ ] `commands/launch.md` — creates git worktree and PROMPT.md for agent execution
- [ ] Validates task exists and checks dependency completion via `scripts/deps.sh`
- [ ] Blocks launch if dependencies incomplete (unless `--force`)
- [ ] Supports `--max-iterations N` flag for stop hook safety cap
- [ ] Branch format: `feature/{TASK_ID}-{kebab-name}`
- [ ] Runs `scripts/wt-create.sh` for worktree + submodule initialization
- [ ] Creates `.claude/backlog-agent.local.md` state file
- [ ] Updates INDEX.md to "In Progress"
- [ ] Outputs `<promise>BLOCKED: worktree_launched_start_new_session</promise>`

### US-MKT-009.11: In-Session Work Command (`/pm:work`)

As a user, I want to run `/pm:work <task-id>` to start working on a task without a worktree so that I can do quick tasks in the current session.

**Acceptance Criteria:**
- [ ] `commands/work.md` — sets up in-session task context on current branch
- [ ] Validates task status (must be Ready or In Progress)
- [ ] Creates PROMPT.md with task context
- [ ] Creates `.claude/backlog-agent.local.md` state file
- [ ] Updates INDEX.md to "In Progress"
- [ ] Initializes PROGRESS.md if needed

### US-MKT-009.12: Code Review Command (`/pm:review`)

As a user, I want to run `/pm:review <task-id>` to transition a task to code review mode so that implementation gets reviewed before completion.

**Acceptance Criteria:**
- [ ] `commands/review.md` — transitions task from implementation to code review
- [ ] Creates/updates REVIEW.md in task directory
- [ ] Updates PROMPT.md to review mode
- [ ] Updates state file mode to "review"
- [ ] Updates INDEX.md to "In Review"
- [ ] Outputs promise to exit and start new review session

### US-MKT-009.13: Task Design Review Command (`/pm:design-review`)

As a user, I want to run `/pm:design-review [task-id]` to audit task definitions for quality so that tasks are well-defined before implementation.

**Acceptance Criteria:**
- [ ] `commands/design-review.md` — audits task definitions (NOT code review)
- [ ] Without args: reviews all tasks and generates report
- [ ] With task ID: reviews specific task with interactive Q&A refinement
- [ ] Checks structure completeness, user story quality, acceptance criteria testability
- [ ] Reports issues with severity levels (Critical/Warning/Suggestion)

### US-MKT-009.14: From-Review Command (`/pm:from-review`)

As a user, I want to run `/pm:from-review <task-id>` to create follow-up tasks from code review suggestions so that review findings become tracked work.

**Acceptance Criteria:**
- [ ] `commands/from-review.md` — parses REVIEW.md suggestions, creates new tasks
- [ ] Gets user confirmation for each suggestion
- [ ] New tasks get dependency on parent task
- [ ] Updates original REVIEW.md to mark suggestions as converted

### US-MKT-009.15: Complete Command (`/pm:complete`)

As a user, I want to run `/pm:complete <task-id>` to finalize a task so that work is merged and archived.

**Acceptance Criteria:**
- [ ] `commands/complete.md` — supports both worktree and in-session workflows
- [ ] In-session: commits, rebases if needed, updates INDEX.md to Complete, cleans up
- [ ] Worktree Phase 1 (from task worktree): commits, rebases, sets "Pending Merge"
- [ ] Worktree Phase 2 (from main): fast-forward merges, updates INDEX.md, cascades dependency unblocking
- [ ] Supports `--push` flag
- [ ] Archives task to `tasks/archive/`
- [ ] Removes worktree and branch after merge

### US-MKT-009.16: Prune Command (`/pm:prune`)

As a user, I want to run `/pm:prune` to archive completed tasks so that the active task list stays clean.

**Acceptance Criteria:**
- [ ] `commands/prune.md` — moves completed task directories to `tasks/archive/`
- [ ] Updates INDEX.md with archive tracking
- [ ] Commits changes

### US-MKT-009.17: Stop Command (`/pm:stop`)

As a user, I want to run `/pm:stop` as an emergency escape when the stop hook is looping so that I can regain control.

**Acceptance Criteria:**
- [ ] `commands/stop.md` — creates `.claude/backlog-exit` flag
- [ ] Outputs `<promise>BLOCKED: user_forced_stop</promise>`

### US-MKT-009.18: Migrate Command (`/pm:migrate`)

As a user, I want to run `/pm:migrate` to rename worktree branches to the current naming convention so that existing worktrees match expected format.

**Acceptance Criteria:**
- [ ] `commands/migrate.md` — updates branch names to `feature/{TASK_ID}-{name}` format
- [ ] Supports `--dry-run` to preview changes
- [ ] Updates INDEX.md Worktree column
- [ ] Skips branches already in correct format

### US-MKT-009.19: Hooks

As a user, I want the plugin's hooks to manage agent lifecycle so that agents work autonomously and exit cleanly.

**Acceptance Criteria:**
- [ ] `hooks/hooks.json` registering all 4 hooks
- [ ] **SessionStart hook** (`hooks/session-start.sh`): detects worktrees, prompts agent to read PROMPT.md, verifies submodules
- [ ] **ProgressLogger hook** (`hooks/progress-logger.sh`): PostToolUse on Write|Edit, reminds agent to checkpoint PROGRESS.md every 4th change
- [ ] **ValidateIndex hook** (`hooks/validate-index-hook.sh`): PostToolUse on Write|Edit, validates INDEX.md format when modified
- [ ] **Stop hook** (`hooks/stop-hook.sh`): enforces promise-based exit protocol with iteration safety cap (10 default or user-specified)

### US-MKT-009.20: Scripts (Internal Utilities)

As a plugin developer, I want all utility scripts bundled internally so that there are no cross-plugin dependencies.

**Acceptance Criteria:**
- [ ] `scripts/deps.sh` — dependency graph management (build, validate, cycle detect, status compute, visualize, topological sort). Bash 3.2 compatible (file-per-key, no associative arrays)
- [ ] `scripts/format-task-list.sh` — terminal table formatting with emoji, box-drawing, color
- [ ] `scripts/index-to-json.sh` — INDEX.md + worktree state to JSON conversion
- [ ] `scripts/validate-index.sh` — comprehensive INDEX.md format validation
- [ ] `scripts/wt-create.sh` — worktree creation with CoW optimization and submodule init
- [ ] `scripts/wt-remove.sh` — worktree and branch cleanup
- [ ] `scripts/wt-migrate-prefix.sh` — branch name migration utility

### US-MKT-009.21: Skills

As a user, I want inline skills for quick task review so that I can check task quality without running full commands.

**Acceptance Criteria:**
- [ ] `skills/task-reviewer/SKILL.md` — quick review for specific tasks or small sets
- [ ] `skills/task-reviewer/checklist.md` — quality checklist
- [ ] `skills/task-reviewer/output-format.md` — report template with severity levels
- [ ] `skills/code-reviewer/SKILL.md` — inline code review skill (from backlog plugin)

### US-MKT-009.22: Agents

As a user, I want specialized agents for bulk operations so that expensive scans run in isolated context.

**Acceptance Criteria:**
- [ ] `agents/task-auditor.md` — comprehensive audit of ALL tasks in tasks/ directory (from design plugin)
- [ ] `agents/dependency-analyzer.md` — dependency graph analysis across repos and submodules (from backlog plugin)
- [ ] `agents/code-auditor.md` — comprehensive automated code review populating REVIEW.md (from backlog plugin)
- [ ] `agents/code-reviewer.md` — code review agent for individual task reviews (from backlog plugin)

### US-MKT-009.23: OpenCode Compatibility

As a user of OpenCode, I want the plugin to have an `.opencode/` translation so that commands work in both Claude Code and OpenCode.

**Acceptance Criteria:**
- [ ] `.opencode/` directory with translated commands and agents
- [ ] `opencode.json` configuration file
- [ ] `build/translate.sh` and `build/translate.ts` build scripts
- [ ] Command name translation: `/pm:launch` becomes `/pm-launch` in OpenCode

## Technical Details

### Plugin Structure
```
plugins/pm/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── pm.md              # Dashboard (/pm)
│   ├── list.md            # Task list (/pm:list)
│   ├── help.md            # Help reference (/pm:help)
│   ├── design.md          # Task creation (/pm:design)
│   ├── init.md            # Project init (/pm:init)
│   ├── prd.md             # PRD creation (/pm:prd)
│   ├── digest.md          # Document import (/pm:digest)
│   ├── read.md            # Task viewer (/pm:read)
│   ├── launch.md          # Agent worktree (/pm:launch)
│   ├── work.md            # In-session work (/pm:work)
│   ├── review.md          # Code review (/pm:review)
│   ├── design-review.md   # Task audit (/pm:design-review)
│   ├── from-review.md     # Review to tasks (/pm:from-review)
│   ├── complete.md        # Task completion (/pm:complete)
│   ├── prune.md           # Archive tasks (/pm:prune)
│   ├── stop.md            # Emergency exit (/pm:stop)
│   └── migrate.md         # Branch migration (/pm:migrate)
├── hooks/
│   ├── hooks.json
│   ├── session-start.sh
│   ├── progress-logger.sh
│   ├── validate-index-hook.sh
│   └── stop-hook.sh
├── scripts/
│   ├── deps.sh
│   ├── format-task-list.sh
│   ├── index-to-json.sh
│   ├── validate-index.sh
│   ├── wt-create.sh
│   ├── wt-remove.sh
│   └── wt-migrate-prefix.sh
├── skills/
│   ├── task-reviewer/
│   │   ├── SKILL.md
│   │   ├── checklist.md
│   │   └── output-format.md
│   └── code-reviewer/
│       └── SKILL.md
├── agents/
│   ├── task-auditor.md
│   ├── dependency-analyzer.md
│   ├── code-auditor.md
│   └── code-reviewer.md
├── build/
│   ├── translate.sh
│   └── translate.ts
├── .opencode/
│   ├── commands/
│   └── agents/
└── opencode.json
```

### Key Design Decisions

1. **No cross-plugin dependencies** — `deps.sh` and all scripts are internal. No path-walking through versioned cache directories.
2. **File format unchanged** — `tasks/INDEX.md`, `TASK.md`, `PROGRESS.md`, `REVIEW.md`, `design.yaml` all keep their current format for backwards compatibility.
3. **Promise protocol unchanged** — `<promise>PHASE_DONE</promise>`, `<promise>BLOCKED: reason</promise>`, etc. Same exit gating behavior.
4. **State files unchanged** — `.claude/backlog-agent.local.md` and `.claude/backlog-exit` keep their current format and names for compatibility with running agents.
5. **Branch naming unchanged** — `feature/{TASK_ID}-{kebab-name}` format preserved.
6. **Bash 3.2 compatibility** — all scripts use file-per-key patterns, no associative arrays (macOS default bash).
7. **CoW worktree optimization** — platform-specific copy-on-write (APFS `cp -c`, Btrfs/XFS `cp --reflink=auto`).

### Migration Path

1. Install `pm` plugin alongside existing `design` and `backlog` plugins
2. Test all commands work correctly with existing task directories
3. Disable `design` and `backlog` plugins when confident
4. Remove old plugins from marketplace when fully deprecated

## Files to Create/Modify

**New Files (in `plugins/pm/` submodule):**
- All files listed in the Plugin Structure above (17 commands, 4 hooks, 7 scripts, 3 skill files, 4 agents, 3 build files, OpenCode translations)

**Modified Files (in marketplace repo):**
- `.gitmodules` — add submodule entry for `plugins/pm`
- `.claude-plugin/marketplace.json` — add `pm` plugin entry

## Inventory Check

Before starting, verify:
- [ ] Git repo exists at `https://github.com/cyotee/claude-pm-plugin.git`
- [ ] Submodule can be added at `plugins/pm`
- [ ] Both `design` and `backlog` plugins are accessible for reference
- [ ] `design.yaml` and `tasks/INDEX.md` format is documented

## Completion Criteria

- [ ] All 23 user stories' acceptance criteria met
- [ ] All commands work with existing `tasks/` directory format
- [ ] All hooks fire correctly (SessionStart, PostToolUse, Stop)
- [ ] Dependency graph builds from INDEX.md (main + submodules)
- [ ] `/pm:help` accurately documents all commands
- [ ] OpenCode translations generated
- [ ] Plugin installs cleanly as submodule
- [ ] No cross-plugin dependencies remain

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
