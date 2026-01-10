---
description: Bootstrap context by reading CLAUDE.md and any referenced documentation
argument-hint: [plan|prompt]
---

# Context Bootstrap Command

Read and internalize the project's CLAUDE.md documentation to understand the codebase.

## Instructions

1. **Find CLAUDE.md**: Look for CLAUDE.md in the current working directory or repository root

2. **Read CLAUDE.md**: Read and understand the project instructions, architecture, and conventions

3. **Follow references**: If CLAUDE.md references other CLAUDE.md files (e.g., in submodules like `lib/daosys/lib/crane/CLAUDE.md`), read those as well

4. **Acknowledge**: After reading, briefly confirm what you learned:
   - Project name and purpose
   - Key architectural patterns
   - Important conventions or constraints
   - Any referenced documentation you also read

## Example Output

After reading, respond with something like:

```
Context loaded from CLAUDE.md:
- Project: [name] - [brief purpose]
- Architecture: [key patterns]
- Dependencies: [key libs/frameworks]
- Also read: [list of referenced CLAUDE.md files]

Ready to assist with this codebase.
```
