# Task MKT-002: Code Reviewer Agent

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/code-reviewer-agent`

---

## Description

Create a `code-reviewer` agent for the backlog plugin that performs automated first-pass code reviews. The agent reads task requirements, analyzes changed files, checks acceptance criteria against implementation, and populates REVIEW.md with findings.

## Dependencies

- None (can be developed in parallel with MKT-001)

## User Stories

### US-MKT-002.1: Requirements-Based Review

As a developer, I want the agent to compare implementation against TASK.md requirements so that I know if acceptance criteria are met.

**Acceptance Criteria:**
- [ ] Agent reads TASK.md and extracts acceptance criteria
- [ ] Agent reads changed files in the worktree
- [ ] Agent checks each criterion against the implementation
- [ ] Agent reports which criteria are met/unmet

### US-MKT-002.2: Code Quality Analysis

As a developer, I want the agent to identify potential issues so that bugs are caught before human review.

**Acceptance Criteria:**
- [ ] Agent identifies potential bugs and edge cases
- [ ] Agent checks for missing error handling
- [ ] Agent flags missing tests
- [ ] Agent notes security concerns if applicable

### US-MKT-002.3: Automated REVIEW.md Population

As a developer, I want the agent to document findings in REVIEW.md so that the review is preserved.

**Acceptance Criteria:**
- [ ] Agent writes findings to REVIEW.md "Review Findings" section
- [ ] Agent writes suggestions to REVIEW.md "Suggestions" section
- [ ] Agent provides a summary and recommendation
- [ ] Agent outputs `<promise>REVIEW_COMPLETE</promise>` when done

### US-MKT-002.4: Model Configuration

As a developer, I want to optionally use a different model for review so that I get a fresh perspective.

**Acceptance Criteria:**
- [ ] Agent can be invoked with different model (haiku for speed, opus for depth)
- [ ] Default model is configurable in agent definition

## Technical Details

The agent should be defined in `plugins/backlog/agents/code-reviewer.md` with:
- YAML frontmatter specifying tools (Read, Glob, Grep, Bash for git diff)
- System prompt describing review methodology
- Instructions to read TASK.md, PROGRESS.md first
- Output format aligned with REVIEW.md structure

The `/backlog:review` command can optionally invoke this agent instead of just setting up review mode.

## Files to Create/Modify

**New Files:**
- `plugins/backlog/agents/code-reviewer.md` - Agent definition with system prompt and tools

**Modified Files:**
- `plugins/backlog/.claude-plugin/plugin.json` - Add agents directory reference
- `plugins/backlog/commands/review.md` - Optionally invoke agent for automated review

## Inventory Check

Before starting, verify:
- [ ] `plugins/backlog/` directory exists
- [ ] `plugins/backlog/.claude-plugin/plugin.json` exists
- [ ] Understand REVIEW.md structure and sections
- [ ] Understand git diff commands for worktree analysis

## Completion Criteria

- [ ] Agent file created with proper frontmatter
- [ ] Agent can be invoked via Task tool
- [ ] Agent produces findings in REVIEW.md format
- [ ] Agent checks acceptance criteria systematically
- [ ] plugin.json updated if needed
- [ ] Tested with a sample task in review mode

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
