# Task MKT-005: PostToolUse Hook for Progress Logging

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/progress-logging-hook`

---

## Description

Add a PostToolUse hook that detects significant file changes (Write/Edit operations) and prompts or auto-appends progress to PROGRESS.md. This ensures agents maintain accurate checkpoint information throughout their work.

## Dependencies

- None

## User Stories

### US-MKT-005.1: File Change Detection

As a developer, I want the hook to detect when significant files are changed so that progress can be logged.

**Acceptance Criteria:**
- [ ] Hook triggers after Write and Edit tool uses
- [ ] Hook identifies the file path that was modified
- [ ] Hook filters out non-significant changes (e.g., temporary files)

### US-MKT-005.2: Progress Prompting

As a developer, I want the hook to remind agents to update PROGRESS.md so that checkpoints stay current.

**Acceptance Criteria:**
- [ ] Hook checks if PROGRESS.md exists in task directory
- [ ] Hook prompts agent to update progress after significant changes
- [ ] Hook suggests what to include in the progress update

### US-MKT-005.3: Checkpoint Tracking

As a developer, I want progress updates to maintain checkpoint format so that agents can resume after compaction.

**Acceptance Criteria:**
- [ ] Hook suggests updating "Current Checkpoint" section
- [ ] Hook recommends noting what was just completed
- [ ] Hook recommends noting what comes next

## Technical Details

The hook should be a prompt-based hook (`plugins/backlog/hooks/progress-logger.md`) that:
1. Matches PostToolUse events for Write and Edit tools
2. Checks if the changed file is in a task worktree
3. Provides a prompt suggesting PROGRESS.md updates

Hook configuration:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "path": "${CLAUDE_PLUGIN_ROOT}/hooks/progress-logger.md"
          }
        ]
      }
    ]
  }
}
```

## Files to Create/Modify

**New Files:**
- `plugins/backlog/hooks/progress-logger.md` - Prompt-based hook for progress logging

**Modified Files:**
- `plugins/backlog/hooks/hooks.json` - Add PostToolUse hook configuration

## Inventory Check

Before starting, verify:
- [ ] Understand PostToolUse hook event and matcher syntax
- [ ] Understand prompt-based hook format
- [ ] Understand PROGRESS.md structure and checkpoint format

## Completion Criteria

- [ ] Hook prompt file created
- [ ] hooks.json updated with PostToolUse configuration
- [ ] Hook triggers after Write/Edit operations
- [ ] Hook provides helpful progress update suggestions
- [ ] Tested in task implementation workflow

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
