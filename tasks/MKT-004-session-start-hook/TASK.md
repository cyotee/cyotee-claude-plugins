# Task MKT-004: SessionStart Hook for Worktree Context

**Repo:** Cyotee Claude Plugins
**Status:** Complete
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/session-start-hook`

---

## Description

Add a SessionStart hook to the backlog plugin that detects when Claude starts in a worktree and automatically suggests or runs `/up:prompt` to load context. This prevents agents from forgetting to load their task context.

## Dependencies

- None

## User Stories

### US-MKT-004.1: Worktree Detection

As a developer, I want Claude to detect when it starts in a worktree so that it can offer to load context automatically.

**Acceptance Criteria:**
- [ ] Hook runs on SessionStart event
- [ ] Hook detects if current directory is a git worktree
- [ ] Hook identifies the worktree branch name

### US-MKT-004.2: Context Loading Prompt

As a developer, I want Claude to remind me to load context so that I don't forget PROMPT.md exists.

**Acceptance Criteria:**
- [ ] Hook checks for PROMPT.md in current directory
- [ ] Hook suggests running `/up:prompt` if PROMPT.md exists
- [ ] Hook provides clear message about available context files

### US-MKT-004.3: Task Identification

As a developer, I want Claude to identify which task this worktree belongs to so that I have immediate context.

**Acceptance Criteria:**
- [ ] Hook extracts task ID from worktree branch name (e.g., `feature/task-reviewer-agent`)
- [ ] Hook displays task title if identifiable
- [ ] Hook notes related files (TASK.md, PROGRESS.md, REVIEW.md)

## Technical Details

The hook should be implemented as either:
1. A shell script (`plugins/backlog/hooks/session-start.sh`) that outputs suggestions
2. A prompt-based hook (`plugins/backlog/hooks/session-start.md`) that provides context

Hook configuration in `plugins/backlog/hooks/hooks.json`:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

## Files to Create/Modify

**New Files:**
- `plugins/backlog/hooks/session-start.sh` - Shell script for worktree detection

**Modified Files:**
- `plugins/backlog/hooks/hooks.json` - Add SessionStart hook configuration

## Inventory Check

Before starting, verify:
- [ ] Understand SessionStart hook event in Claude Code
- [ ] Understand `git worktree list` command output format
- [ ] Understand existing hooks.json structure in backlog plugin

## Completion Criteria

- [ ] Hook script created and executable
- [ ] hooks.json updated with SessionStart configuration
- [ ] Hook detects worktree correctly
- [ ] Hook suggests /up:prompt when PROMPT.md exists
- [ ] Tested in actual worktree environment

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
