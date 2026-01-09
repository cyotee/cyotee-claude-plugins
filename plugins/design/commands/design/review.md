---
description: Review and refine tasks in UNIFIED_PLAN.md
argument-hint: [<task-number>]
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Task, TodoWrite
---

# Task Review Session

Review and refine tasks in UNIFIED_PLAN.md. You can review all tasks or focus on a specific task.

**Arguments received:** $ARGUMENTS

## Command Dispatch

### If no arguments: Review All Tasks

1. **Read UNIFIED_PLAN.md** and analyze each task for:
   - Completeness (all required sections present)
   - Clarity (unambiguous requirements)
   - User story quality (testable acceptance criteria)
   - Dependencies (correctly identified and up-to-date)
   - Status accuracy (does status reflect actual state?)

2. **Generate a review report:**

```
# Task Review Report

## Summary
| Task | Title | Issues Found | Recommendation |
|------|-------|--------------|----------------|
| 1    | ...   | None         | Ready          |
| 2    | ...   | Missing deps | Needs update   |

## Detailed Findings

### Task N: [Title]
- **Status:** [Current status]
- **Issues:**
  - [Issue 1]
  - [Issue 2]
- **Recommendations:**
  - [Action 1]
  - [Action 2]
```

3. **Ask user** which tasks they want to address, then update UNIFIED_PLAN.md accordingly.

### If task number provided: Review Specific Task

1. **Read UNIFIED_PLAN.md** and find the specified task.

2. **Analyze the task** for:
   - **Description clarity:** Is the purpose clear?
   - **User stories:** Are they complete and testable?
   - **Acceptance criteria:** Specific and measurable?
   - **Dependencies:** Still accurate? Any new blockers?
   - **Files to create/modify:** Complete list?
   - **Inventory checks:** All prerequisites listed?
   - **Completion criteria:** How do we know it's done?

3. **Interactive refinement:** Use AskUserQuestion to:
   - Clarify any ambiguous requirements
   - Identify missing user stories
   - Update outdated information
   - Add newly discovered dependencies

4. **Update the task** in UNIFIED_PLAN.md with refinements.

5. **Commit changes** with descriptive message.

## Review Checklist

For each task, verify:

### Structure
- [ ] Has Description section
- [ ] Has Dependencies section (even if "None")
- [ ] Has User Stories (at least one)
- [ ] Has Files to Create/Modify section
- [ ] Has Inventory Check section
- [ ] Has Completion Criteria section

### Quality
- [ ] Description explains "what" and "why"
- [ ] Each user story follows "As a... I want... so that..." format
- [ ] Acceptance criteria are testable (not vague)
- [ ] Dependencies reference specific task numbers
- [ ] File paths are accurate and complete
- [ ] Inventory checks are verifiable

### Consistency
- [ ] Task number matches position in document
- [ ] Status reflects actual progress
- [ ] Layer (Crane/daosys/product) is correct
- [ ] Worktree branch name follows convention

## Common Issues to Flag

1. **Vague acceptance criteria:** "Works correctly" → Should be specific
2. **Missing error cases:** Only happy path covered
3. **Stale dependencies:** Completed tasks still listed as blockers
4. **Incomplete file lists:** Tests or interfaces missing
5. **No inventory checks:** Agent won't verify prerequisites
6. **Status mismatch:** Marked "Ready" but has unmet dependencies
