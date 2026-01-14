# Task MKT-007: Review Command Naming Clarity

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/review-command-clarity`

---

## Description

Improve the descriptions of `/design:review` and `/backlog:review` commands to clearly distinguish their purposes. Currently both contain "review" which can be confusing - one reviews task definitions (design quality) while the other transitions tasks to code review mode.

## Dependencies

- None

## User Stories

### US-MKT-007.1: Clear Command Descriptions

As a developer, I want command descriptions to clearly distinguish review types so that I invoke the correct command.

**Acceptance Criteria:**
- [ ] `/design:review` description emphasizes "task definition quality review"
- [ ] `/backlog:review` description emphasizes "code review mode transition"
- [ ] Descriptions are concise but unambiguous

### US-MKT-007.2: SKILL.md Clarity

As a developer, I want SKILL.md files to clearly explain when to use each review command so that Codex integration works correctly.

**Acceptance Criteria:**
- [ ] design/SKILL.md clarifies `/design:review` is for task quality
- [ ] backlog/SKILL.md clarifies `/backlog:review` is for code review transition
- [ ] Keywords/triggers are distinct between the two

### US-MKT-007.3: Help Text Improvement

As a developer, I want the command help text to explain the difference so that I understand before running.

**Acceptance Criteria:**
- [ ] Command frontmatter description is clear
- [ ] First paragraph of command file explains purpose
- [ ] Example usage shows appropriate scenarios

## Technical Details

Update the following files with clearer descriptions:

**design plugin:**
- `commands/review.md` frontmatter: `description: Audit task definitions for quality and completeness`
- `SKILL.md`: Emphasize task definition review, not code review

**backlog plugin:**
- `commands/review.md` frontmatter: `description: Transition task to code review mode in worktree`
- `SKILL.md`: Emphasize code review transition, not task quality

Suggested terminology:
- `/design:review` → "task audit", "definition review", "quality check"
- `/backlog:review` → "code review transition", "review mode", "implementation review"

## Files to Create/Modify

**Modified Files:**
- `plugins/design/commands/review.md` - Update description and intro text
- `plugins/design/SKILL.md` - Clarify review purpose
- `plugins/backlog/commands/review.md` - Update description and intro text
- `plugins/backlog/SKILL.md` - Clarify review purpose

## Inventory Check

Before starting, verify:
- [ ] Read current `/design:review` description and content
- [ ] Read current `/backlog:review` description and content
- [ ] Read both SKILL.md files for current wording

## Completion Criteria

- [ ] Command descriptions are clearly distinct
- [ ] SKILL.md files use different keywords
- [ ] No confusion between task review and code review
- [ ] Documentation is consistent across files

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
