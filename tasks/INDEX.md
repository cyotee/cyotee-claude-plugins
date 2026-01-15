# Task Index: Cyotee Claude Plugins

**Repo:** MKT
**Last Updated:** 2026-01-14 (MKT-008 created)

## Active Tasks

| ID | Title | Status | Dependencies | Worktree |
|----|-------|--------|--------------|----------|
| MKT-001 | Task Reviewer Agent | In Progress | - | - |
| MKT-002 | Code Reviewer Agent | Ready | - | - |
| MKT-003 | Dependency Analyzer Agent | Ready | - | - |
| MKT-004 | SessionStart Hook | Complete | - | - |
| MKT-005 | PostToolUse Hook for Progress Logging | Ready | - | - |
| MKT-006 | PreToolUse Hook for Dangerous Operations | Ready | - | - |
| MKT-007 | Review Command Naming Clarity | Ready | - | - |
| MKT-008 | In-Session Task Workflow | Complete | - | - |

## Status Legend

- **Ready** - All dependencies met, can be launched with `/backlog:launch`
- **In Progress** - Implementation agent working (has worktree)
- **In Review** - Implementation complete, awaiting code review
- **Changes Requested** - Review found issues, needs fixes
- **Complete** - Review passed, ready to archive with `/backlog:prune`
- **Blocked** - Waiting on dependencies

## Quick Filters

### Ready for Agent

- MKT-001: Task Reviewer Agent (High priority)
- MKT-002: Code Reviewer Agent (High priority)
- MKT-003: Dependency Analyzer Agent (Medium priority)
- MKT-005: PostToolUse Hook for Progress Logging (Medium priority)
- MKT-006: PreToolUse Hook for Dangerous Operations (Low priority, Low effort)
- MKT-007: Review Command Naming Clarity (Low priority, Low effort)

### Complete

- MKT-004: SessionStart Hook

### Blocked

(none)

## Suggested Order

Based on priority and effort, suggested implementation order:
1. MKT-007 (Low effort, quick win for clarity)
2. MKT-006 (Low effort, safety improvement)
3. MKT-001 (High priority agent)
4. MKT-002 (High priority agent)
5. MKT-005 (Medium effort hook)
6. MKT-003 (High effort, but valuable)

## Cross-Repo Dependencies

Tasks in other repos that depend on this repo's tasks:
- (none yet)
