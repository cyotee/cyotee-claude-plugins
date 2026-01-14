# Task MKT-006: PreToolUse Hook for Dangerous Operations

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/safety-guard-hook`

---

## Description

Add a PreToolUse hook that warns (but does not block) before dangerous operations like `git push --force`, `rm -rf`, or operations on the main branch. This provides visibility into potentially destructive actions without interrupting workflow.

## Dependencies

- None

## User Stories

### US-MKT-006.1: Force Push Warning

As a developer, I want to be warned before force pushing so that I'm aware I might overwrite remote history.

**Acceptance Criteria:**
- [ ] Hook detects `git push --force` or `git push -f` commands
- [ ] Hook detects `git push --force-with-lease` (with softer warning - this is safer)
- [ ] Hook outputs a visible warning message
- [ ] Hook allows command to proceed (warn-only, no blocking)

### US-MKT-006.2: Destructive Delete Warning

As a developer, I want to be warned before recursive deletions so that I'm aware of potentially destructive operations.

**Acceptance Criteria:**
- [ ] Hook detects `rm -rf` commands
- [ ] Hook detects `rm -r` commands
- [ ] Hook outputs warning with the target path
- [ ] Hook allows command to proceed (warn-only, no blocking)

### US-MKT-006.3: Main Branch Protection

As a developer, I want to be warned before operations on main/master so that I'm aware I might be modifying the main branch.

**Acceptance Criteria:**
- [ ] Hook detects `git checkout main` or `git checkout master`
- [ ] Hook detects `git switch main` or `git switch master`
- [ ] Hook warns and suggests using worktree workflow instead
- [ ] Hook allows command to proceed (warn-only, no blocking)

### US-MKT-006.4: Hard Reset Warning

As a developer, I want to be warned before hard resets so that I'm aware I might lose uncommitted changes.

**Acceptance Criteria:**
- [ ] Hook detects `git reset --hard` commands
- [ ] Hook outputs warning about potential data loss
- [ ] Hook allows command to proceed (warn-only, no blocking)

## Technical Details

The hook should be a prompt-based hook (`plugins/backlog/hooks/safety-guard.md`) that:
1. Matches PreToolUse events for Bash tool
2. Analyzes command for dangerous patterns
3. Outputs warning messages but always allows execution

**Behavior:** Warn-only (no blocking). The hook provides visibility but does not interrupt workflow.

Hook configuration:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "path": "${CLAUDE_PLUGIN_ROOT}/hooks/safety-guard.md"
          }
        ]
      }
    ]
  }
}
```

**Dangerous patterns to detect:**
- `git push --force`, `git push -f` (high warning)
- `git push --force-with-lease` (low warning - safer variant)
- `git reset --hard`
- `rm -rf`, `rm -r`
- `git checkout main`, `git checkout master`
- `git switch main`, `git switch master`

**Warning format example:**
```
⚠️  SAFETY WARNING: Force push detected
    Command: git push --force origin feature/my-branch
    This will overwrite remote history. Proceeding...
```

## Files to Create/Modify

**New Files:**
- `plugins/backlog/hooks/safety-guard.md` - Prompt-based hook for safety warnings

**Modified Files:**
- `plugins/backlog/hooks/hooks.json` - Add PreToolUse hook configuration

## Inventory Check

Before starting, verify:
- [ ] Understand PreToolUse hook event format
- [ ] Understand prompt-based hook response format
- [ ] Review existing hooks.json structure (already has SessionStart and Stop hooks)

## Completion Criteria

- [ ] Hook prompt file created with pattern detection
- [ ] hooks.json updated with PreToolUse configuration
- [ ] Hook outputs warnings for dangerous commands
- [ ] Hook does not block any commands (warn-only)
- [ ] Tested with various dangerous command patterns

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
