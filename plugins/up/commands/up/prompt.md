---
description: Bootstrap context for agent execution - read CLAUDE.md AND PROMPT.md task instructions
---

# Agent Task Bootstrap

Read project documentation AND the current PROMPT.md task instructions. Use this when starting work in an agent worktree.

## Instructions

1. **Read CLAUDE.md**: Find and read CLAUDE.md in the current working directory or repository root

2. **Follow references**: If CLAUDE.md references other CLAUDE.md files (e.g., in submodules), read those as well

3. **Read PROMPT.md**: Find and read PROMPT.md in the current directory to understand:
   - The specific task you need to complete
   - Acceptance criteria
   - Files to create or modify
   - Inventory checks to perform
   - Completion criteria

4. **Acknowledge and Begin**: After reading, confirm:
   - What task you're working on
   - Key deliverables
   - The completion promise format you'll use

## Expected PROMPT.md Structure

PROMPT.md files contain:
- Task description and user stories
- Files to create/modify
- Inventory checks (prerequisites to verify)
- Completion criteria
- Promise format: `<promise>TASK_COMPLETE</promise>` or `<promise>TASK_BLOCKED: [reason]</promise>`

## Example Output

```
Context loaded:
- Project: [name]
- Task: [task number and title]

Assignment:
- [Key deliverable 1]
- [Key deliverable 2]
- ...

Inventory checks to perform:
- [ ] [Check 1]
- [ ] [Check 2]

Completion promise: TASK_COMPLETE

Beginning work...
```
