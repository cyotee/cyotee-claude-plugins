# Plugin Marketplace Review

**Reviewer:** Claude Opus 4.5
**Review Date:** 2026-01-14
**Status:** In Progress

---

## Current Architecture Summary

The marketplace has **3 plugins** with well-structured commands but **no agents defined yet**:

| Plugin | Commands | Agents | Skills | Hooks |
|--------|----------|--------|--------|-------|
| design | 6 | 0 | 1 (SKILL.md) | 0 |
| backlog | 7 | 0 | 1 (SKILL.md) | 1 (Stop) |
| up | 3 | 0 | 1 (SKILL.md) | 0 |

### Key Patterns

- Commands use YAML frontmatter + Markdown
- SKILL.md files for Codex integration
- Stop hook validates task completion promises
- Two-phase completion workflow (worktree → main)
- Dependency graph with cycle detection

---

## Improvement Suggestions

### 1. Task Reviewer Agent

**Plugin:** design
**Priority:** High
**Effort:** Medium

**Problem:** The `/design:review` command runs synchronously, reading many files and analyzing task quality. This blocks the main session and uses context for repetitive file scanning.

**Suggestion:** Create a `task-reviewer` agent that:
- Runs autonomously to scan all task directories
- Analyzes TASK.md quality (completeness, user story format, acceptance criteria clarity)
- Validates INDEX.md consistency
- Generates a comprehensive report
- Returns a summary to the main session

**Benefits:**
- Offloads context-heavy analysis
- Can run in background while user does other work
- Provides consistent, thorough review checklist

**Files to Create:**
- `plugins/design/agents/task-reviewer.md`

**Files to Modify:**
- `plugins/design/.claude-plugin/plugin.json` (add agents reference)
- `plugins/design/commands/review.md` (optionally delegate to agent)

---

### 2. Code Reviewer Agent

**Plugin:** backlog
**Priority:** High
**Effort:** Medium

**Problem:** Currently `/backlog:review` only *transitions* a task to review mode - it sets up files and tells the user to start a new session. The actual code review is manual.

**Suggestion:** Create a `code-reviewer` agent that:
- Reads TASK.md requirements
- Analyzes changed files in the worktree
- Checks acceptance criteria against implementation
- Identifies potential bugs, edge cases, missing tests
- Populates REVIEW.md with findings
- Uses a different model for fresh perspective (configurable)

**Benefits:**
- Automated first-pass code review
- Consistent review quality
- Documents findings automatically

**Files to Create:**
- `plugins/backlog/agents/code-reviewer.md`

**Files to Modify:**
- `plugins/backlog/.claude-plugin/plugin.json` (add agents reference)
- `plugins/backlog/commands/review.md` (optionally invoke agent)

---

### 3. Dependency Analyzer Agent

**Plugin:** backlog (or shared)
**Priority:** Medium
**Effort:** High

**Problem:** Dependency validation logic in `/design` and `/backlog` is complex with cycle detection, cross-repo support, and cascade updates. Currently embedded in commands.

**Suggestion:** Create a `dependency-analyzer` agent that:
- Builds the full dependency graph across all repos/submodules
- Detects cycles and reports paths
- Identifies orphaned tasks
- Computes accurate status based on dependency state
- Suggests optimal task ordering

**Benefits:**
- Reusable across commands
- Can visualize dependency graphs
- Better error messages for complex scenarios

**Files to Create:**
- `plugins/backlog/agents/dependency-analyzer.md`

**Files to Modify:**
- `plugins/backlog/.claude-plugin/plugin.json`
- `plugins/design/commands/design.md` (delegate validation)
- `plugins/backlog/commands/backlog.md` (delegate analysis)

---

### 4. SessionStart Hook for Worktree Context

**Plugin:** backlog
**Priority:** Medium
**Effort:** Low

**Problem:** When an agent starts in a worktree, it must manually run `/up:prompt` to load context. This is easy to forget.

**Suggestion:** Add a `SessionStart` hook that:
- Detects if current directory is a worktree (via `git worktree list`)
- Auto-suggests or auto-runs `/up:prompt`
- Reminds about PROMPT.md and PROGRESS.md

**Files to Create:**
- `plugins/backlog/hooks/session-start.sh` (or prompt-based hook)

**Files to Modify:**
- `plugins/backlog/hooks/hooks.json` (add SessionStart hook)

---

### 5. PostToolUse Hook for Progress Logging

**Plugin:** backlog
**Priority:** Medium
**Effort:** Medium

**Problem:** Agents should update PROGRESS.md as they work, but this is manual and often forgotten.

**Suggestion:** Add a `PostToolUse` hook (triggered after Write/Edit) that:
- Detects significant file changes
- Prompts or auto-appends to PROGRESS.md
- Maintains accurate checkpoint information

**Files to Create:**
- `plugins/backlog/hooks/progress-logger.md` (prompt-based hook)

**Files to Modify:**
- `plugins/backlog/hooks/hooks.json` (add PostToolUse hook)

---

### 6. PreToolUse Hook for Dangerous Operations

**Plugin:** backlog
**Priority:** Low
**Effort:** Low

**Problem:** No guardrails against accidentally destructive operations (e.g., force push, deleting wrong files in worktree).

**Suggestion:** Add a `PreToolUse` hook that:
- Warns before `git push --force` or `rm -rf`
- Validates operations are within expected worktree scope
- Prevents accidental operations on `main`

**Files to Create:**
- `plugins/backlog/hooks/safety-guard.md` (prompt-based hook)

**Files to Modify:**
- `plugins/backlog/hooks/hooks.json` (add PreToolUse hook)

---

### 7. Review Command Naming Clarity

**Plugin:** design, backlog
**Priority:** Low
**Effort:** Low

**Problem:** Having `/design:review` (task quality) and `/backlog:review` (code review transition) is potentially confusing - both contain "review".

**Options:**
1. Rename `/design:review` → `/design:audit` or `/design:validate`
2. Keep as-is but add clearer skill descriptions distinguishing them
3. Merge into a unified `/review` command with mode flags

**Recommendation:** Option 2 - improve descriptions in SKILL.md and command frontmatter to clarify the distinction.

**Files to Modify:**
- `plugins/design/commands/review.md` (update description)
- `plugins/design/SKILL.md` (clarify)
- `plugins/backlog/commands/review.md` (update description)
- `plugins/backlog/SKILL.md` (clarify)

---

## Priority Summary

| # | Improvement | Impact | Effort | Status |
|---|-------------|--------|--------|--------|
| 1 | Task Reviewer Agent | High | Medium | Pending |
| 2 | Code Reviewer Agent | High | Medium | Pending |
| 3 | Dependency Analyzer Agent | Medium | High | Pending |
| 4 | SessionStart Hook | Medium | Low | Pending |
| 5 | PostToolUse Hook | Medium | Medium | Pending |
| 6 | PreToolUse Hook | Low | Low | Pending |
| 7 | Review Command Naming | Low | Low | Pending |

---

## Next Steps

Use `/design:digest REVIEW.md` to convert these suggestions into individual tasks in the `tasks/` directory, then work through them sequentially using the existing plugin commands.

---

**When review complete, output:** `<promise>REVIEW_COMPLETE</promise>`
