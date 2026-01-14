# Task MKT-008: In-Session Task Workflow

**Repo:** Cyotee Claude Plugins
**Status:** Complete
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/in-session-task-workflow`

---

## Description

Add a `/backlog:work` command that enables implementing tasks directly in the current session without creating a worktree. This supports quick, simple tasks that don't need the overhead of worktree management. The workflow uses PROMPT.md for context and extends `/backlog:complete` to handle in-session completion with proper rebasing and cleanup.

## Dependencies

- None

## User Stories

### US-MKT-008.1: Start In-Session Task

As a developer, I want to start working on a task in my current session so that I can implement quick tasks without worktree overhead.

**Acceptance Criteria:**
- [ ] `/backlog:work <task-id>` command starts a task in current session
- [ ] Command creates PROMPT.md with task context (like `/backlog:launch` does)
- [ ] Command updates INDEX.md status to "In Progress"
- [ ] Command checks if task already has active worktree - if so, warns and aborts
- [ ] Command checks if another task is already in progress in this session
- [ ] If on main branch, creates a feature branch automatically

### US-MKT-008.2: In-Session Completion on Feature Branch

As a developer, I want to complete an in-session task from a feature branch so that changes are properly rebased onto main.

**Acceptance Criteria:**
- [ ] `/backlog:complete <task-id>` detects in-session mode (no worktree, has PROMPT.md)
- [ ] Command rebases current branch onto main
- [ ] Command switches to main and fast-forward merges
- [ ] Command deletes the feature branch after merge
- [ ] Command deletes PROMPT.md to keep main clean
- [ ] Command updates INDEX.md status to "Complete"

### US-MKT-008.3: In-Session Completion on Main Branch

As a developer, I want to complete an in-session task directly on main so that simple tasks don't need branches.

**Acceptance Criteria:**
- [ ] If already on main, skip rebase/merge steps
- [ ] Delete PROMPT.md to keep main clean
- [ ] Update INDEX.md status to "Complete"
- [ ] Warn if there are uncommitted changes

### US-MKT-008.4: Conflict Detection

As a developer, I want the system to prevent conflicts with worktree-based workflows so that I don't accidentally work on the same task twice.

**Acceptance Criteria:**
- [ ] `/backlog:work` checks `git worktree list` for existing task worktrees
- [ ] If task has a worktree, abort with message: "Task has active worktree at {path}"
- [ ] `/backlog:work` checks for existing PROMPT.md in current directory
- [ ] If PROMPT.md exists for different task, abort with message about existing work

## Technical Details

### New Command: `/backlog:work`

**File:** `plugins/backlog/commands/work.md`

**Workflow:**
1. Validate task exists and is Ready
2. Check for conflicts (existing worktree, existing PROMPT.md)
3. If on main, optionally create feature branch
4. Generate PROMPT.md (same format as `/backlog:launch`)
5. Update INDEX.md status to "In Progress"
6. Output instructions to start working

**PROMPT.md format:** Same as worktree PROMPT.md, enables `/up:prompt` to work.

### Extended Command: `/backlog:complete`

**File:** `plugins/backlog/commands/complete.md` (modify existing)

**Mode Detection:**
- If `git worktree list` shows current dir is a worktree → existing worktree flow
- If PROMPT.md exists and not in worktree → in-session flow
- Otherwise → error

**In-Session Flow:**
```bash
# If not on main:
git fetch origin main
git rebase origin/main
git checkout main
git merge --ff-only <feature-branch>
git branch -d <feature-branch>

# Always:
rm PROMPT.md
# Update INDEX.md status to Complete
```

### Branch Naming

When `/backlog:work` creates a branch:
- Use `feature/{kebab-task-name}` pattern (same as worktree)
- Example: `feature/review-command-clarity` for MKT-007

## Files to Create/Modify

**New Files:**
- `plugins/backlog/commands/work.md` - New command for in-session task start

**Modified Files:**
- `plugins/backlog/commands/complete.md` - Add in-session completion mode
- `plugins/backlog/SKILL.md` - Document new `/backlog:work` command

## Inventory Check

Before starting, verify:
- [ ] `plugins/backlog/commands/` directory exists
- [ ] `plugins/backlog/commands/complete.md` exists (to extend)
- [ ] Understand PROMPT.md format from `/backlog:launch`
- [ ] Understand current `/backlog:complete` two-phase workflow

## Completion Criteria

- [ ] `/backlog:work` command created and functional
- [ ] `/backlog:complete` extended with in-session mode detection
- [ ] PROMPT.md properly created and cleaned up
- [ ] INDEX.md status updates work correctly
- [ ] Conflict detection works for worktrees and existing sessions
- [ ] Branch rebase flow works correctly
- [ ] SKILL.md updated with new command

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
