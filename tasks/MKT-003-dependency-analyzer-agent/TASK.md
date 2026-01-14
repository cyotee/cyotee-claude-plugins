# Task MKT-003: Dependency Analyzer Agent

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/dependency-analyzer-agent`

---

## Description

Create a `dependency-analyzer` agent that builds and analyzes task dependency graphs across repos and submodules. The agent detects cycles, identifies orphaned tasks, computes accurate status based on dependencies, and suggests optimal task ordering.

## Dependencies

- None

## User Stories

### US-MKT-003.1: Cross-Repo Dependency Graph

As a developer, I want the agent to build a complete dependency graph so that I can see all task relationships.

**Acceptance Criteria:**
- [ ] Agent scans all `tasks/INDEX.md` files in repo and submodules
- [ ] Agent builds directed graph of task dependencies
- [ ] Agent handles cross-repo dependencies (e.g., MKT-001 depends on CRANE-005)
- [ ] Agent outputs graph in readable format

### US-MKT-003.2: Cycle Detection

As a developer, I want the agent to detect circular dependencies so that I can fix them before they cause issues.

**Acceptance Criteria:**
- [ ] Agent implements cycle detection algorithm (DFS-based)
- [ ] Agent reports full cycle path when detected
- [ ] Agent suggests which dependency to remove to break cycle

### US-MKT-003.3: Orphan Detection

As a developer, I want the agent to identify orphaned tasks so that INDEX.md stays consistent with actual directories.

**Acceptance Criteria:**
- [ ] Agent finds task directories not in INDEX.md
- [ ] Agent finds INDEX.md entries without directories
- [ ] Agent reports mismatches with suggested fixes

### US-MKT-003.4: Status Computation

As a developer, I want the agent to compute accurate task status so that blocked tasks are correctly identified.

**Acceptance Criteria:**
- [ ] Agent determines if task is blocked based on incomplete dependencies
- [ ] Agent identifies tasks that become ready when blockers complete
- [ ] Agent suggests cascade updates when dependencies change

### US-MKT-003.5: Optimal Ordering

As a developer, I want the agent to suggest task ordering so that I work efficiently.

**Acceptance Criteria:**
- [ ] Agent performs topological sort of dependency graph
- [ ] Agent lists tasks in optimal execution order
- [ ] Agent identifies parallelizable tasks (no shared dependencies)

## Technical Details

The agent should be defined in `plugins/backlog/agents/dependency-analyzer.md` with:
- YAML frontmatter specifying tools (Read, Glob, Grep, Bash)
- System prompt describing graph algorithms
- Instructions to scan INDEX.md files recursively
- Output format for dependency report

This agent can be invoked by both `/design` (for validation) and `/backlog` (for status analysis).

## Files to Create/Modify

**New Files:**
- `plugins/backlog/agents/dependency-analyzer.md` - Agent definition

**Modified Files:**
- `plugins/backlog/.claude-plugin/plugin.json` - Add agents reference
- `plugins/design/commands/design.md` - Optionally delegate dependency validation
- `plugins/backlog/commands/backlog.md` - Optionally delegate status analysis

## Inventory Check

Before starting, verify:
- [ ] Understand current `deps.sh` script in backlog plugin
- [ ] Understand INDEX.md format and status values
- [ ] Understand submodule path configuration in design.yaml

## Completion Criteria

- [ ] Agent file created with proper frontmatter
- [ ] Agent builds complete dependency graph
- [ ] Agent detects cycles and reports paths
- [ ] Agent identifies orphaned tasks
- [ ] Agent computes accurate status
- [ ] Agent suggests optimal task ordering
- [ ] Tested with multi-repo scenario

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
