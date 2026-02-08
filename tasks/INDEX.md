# Task Index: Cyotee Claude Plugins

**Repo:** MKT
**Last Updated:** 2026-02-07 (Added MKT-009 Unified PM Plugin)

## Active Tasks

| ID | Title | Status | Dependencies | Worktree |
|----|-------|--------|--------------|----------|
| MKT-001 | Task Reviewer (Agent + Skill) | Complete | - | - |
| MKT-002 | Code Reviewer (Agent + Skill) | Complete | - | - |
| MKT-003 | Dependency Analyzer (Agent Only) | Complete | - | - |
| MKT-004 | SessionStart Hook | Complete | - | - |
| MKT-005 | Progress Logging Hook (PostToolUse) | Complete | - | - |
| MKT-006 | Safety Guard Hook (PreToolUse) | Ready | - | - |
| MKT-007 | Review Command Naming Clarity | Complete | - | - |
| MKT-008 | In-Session Task Workflow | Complete | - | - |
| MKT-009 | Unified PM Plugin | In Progress | - | - |

## Component Types

| Type | Purpose | Example Tasks |
|------|---------|---------------|
| **Agent + Skill** | Both comprehensive (agent) and inline (skill) | MKT-001, MKT-002 |
| **Agent Only** | Computational/algorithmic, bulk operations | MKT-003 |
| **Hook** | Event-triggered automation | MKT-004, MKT-005, MKT-006 |
| **Documentation** | Update existing files | MKT-007 |
| **Plugin** | Full plugin consolidation | MKT-009 |

## Status Legend

- **Ready** - All dependencies met, can be launched with `/backlog:launch`
- **In Progress** - Implementation agent working (has worktree)
- **In Review** - Implementation complete, awaiting code review
- **Changes Requested** - Review found issues, needs fixes
- **Complete** - Review passed, ready to archive with `/backlog:prune`
- **Blocked** - Waiting on dependencies

## Quick Filters

### Ready to Start

- MKT-002: Code Reviewer (Agent + Skill) - High priority
- MKT-003: Dependency Analyzer (Agent Only) - Medium priority
- MKT-005: Progress Logging Hook - Medium priority
- MKT-006: Safety Guard Hook - Low priority, Low effort
- MKT-007: Review Command Naming Clarity - Low priority, Low effort
- MKT-009: Unified PM Plugin - High priority, High effort

### Complete

- MKT-001: Task Reviewer (Agent + Skill)
- MKT-004: SessionStart Hook
- MKT-008: In-Session Task Workflow

### Blocked

(none)

## Suggested Order

Based on priority and effort, suggested implementation order:
1. MKT-007 (Low effort, quick win for clarity)
2. MKT-006 (Low effort, safety improvement)
3. MKT-002 (High priority, follows MKT-001 pattern)
4. MKT-005 (Medium effort hook)
5. MKT-003 (High effort, but valuable)

## Cross-Repo Dependencies

Tasks in other repos that depend on this repo's tasks:
- (none yet)
