---
description: Bootstrap context with CLAUDE.md AND read UNIFIED_PLAN.md for task context
---

# Context Bootstrap with Plan

Read project documentation AND the unified development plan.

## Instructions

1. **Read CLAUDE.md**: Find and read CLAUDE.md in the current working directory or repository root

2. **Follow references**: If CLAUDE.md references other CLAUDE.md files (e.g., in submodules), read those as well

3. **Read UNIFIED_PLAN.md**: Find and read UNIFIED_PLAN.md to understand:
   - Current tasks and their status
   - Task dependencies
   - Which tasks are ready for work
   - Overall project roadmap

4. **Summarize**: After reading, provide:
   - Brief project overview (from CLAUDE.md)
   - Current task status summary table
   - Recommended next tasks to work on

## Example Output

```
Context loaded:
- Project: [name] - [brief purpose]
- Architecture: [key patterns]

Task Status:
| Task | Title | Status |
|------|-------|--------|
| 1 | ... | Complete |
| 2 | ... | Ready |
...

Ready tasks: [list tasks ready for agent]
Blocked tasks: [list blocked tasks and why]

Ready to assist with this codebase.
```
