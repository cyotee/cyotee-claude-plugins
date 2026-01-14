# Task MKT-001: Task Reviewer Agent

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/task-reviewer-agent`

---

## Description

Create a `task-reviewer` agent for the design plugin that autonomously scans task directories and analyzes TASK.md quality. This offloads context-heavy analysis from the main session and provides consistent, thorough review coverage.

## Dependencies

- None

## User Stories

### US-MKT-001.1: Autonomous Task Scanning

As a developer, I want an agent that automatically scans all task directories so that I don't have to manually read each file in the main session.

**Acceptance Criteria:**
- [ ] Agent scans all `tasks/` directories (excluding `archive/`)
- [ ] Agent reads TASK.md, PROGRESS.md, and REVIEW.md from each task
- [ ] Agent returns a structured report to the main session

### US-MKT-001.2: Quality Analysis

As a developer, I want the agent to analyze task quality against a checklist so that I receive consistent reviews.

**Acceptance Criteria:**
- [ ] Agent checks for required sections (Description, Dependencies, User Stories, etc.)
- [ ] Agent validates user story format ("As a... I want... so that...")
- [ ] Agent checks acceptance criteria are specific and testable
- [ ] Agent flags vague or incomplete sections

### US-MKT-001.3: INDEX.md Validation

As a developer, I want the agent to validate INDEX.md consistency so that orphaned or mismatched tasks are detected.

**Acceptance Criteria:**
- [ ] Agent compares INDEX.md entries against actual task directories
- [ ] Agent flags tasks missing from INDEX.md
- [ ] Agent flags INDEX.md entries without directories
- [ ] Agent checks status accuracy

## Technical Details

The agent should be defined in `plugins/design/agents/task-reviewer.md` with:
- YAML frontmatter specifying tools (Read, Glob, Grep)
- System prompt describing the review checklist
- Output format for the review report

The agent can optionally be invoked by `/design:review` to delegate the scanning work.

## Files to Create/Modify

**New Files:**
- `plugins/design/agents/task-reviewer.md` - Agent definition with system prompt and tools

**Modified Files:**
- `plugins/design/.claude-plugin/plugin.json` - Add agents directory reference
- `plugins/design/commands/review.md` - Optionally delegate to agent for bulk reviews

## Inventory Check

Before starting, verify:
- [ ] `plugins/design/` directory exists
- [ ] `plugins/design/.claude-plugin/plugin.json` exists
- [ ] Understand Claude Code agent definition format (YAML frontmatter + markdown)

## Completion Criteria

- [ ] Agent file created with proper frontmatter
- [ ] Agent can be invoked via Task tool
- [ ] Agent produces structured review report
- [ ] plugin.json updated if needed
- [ ] Tested with sample tasks

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
