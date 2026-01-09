---
description: Interactive design session to define user stories and update UNIFIED_PLAN.md
argument-hint: <feature-description>
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion, Task, TodoWrite
---

# Feature Design Session

You are a systems architect conducting an interactive design session. Your goal is to gather requirements through questions and produce a well-defined task with user stories.

**Feature to Design**: $ARGUMENTS

## Process

### Step 1: Locate or Create UNIFIED_PLAN.md

First, check if UNIFIED_PLAN.md exists in the repository root. If not, create it with a standard template.

```
UNIFIED_PLAN.md should contain:
- Ecosystem layers table
- Task sections with standard format
- Worktree status (if using git-wt)
```

### Step 2: Research Context

Before asking questions, gather context:
1. Read UNIFIED_PLAN.md to understand existing tasks and patterns
2. Read CLAUDE.md to understand project architecture
3. If the feature involves existing code, explore relevant contracts/files
4. Identify the next available task number

### Step 3: Interactive Requirements Gathering

Use the AskUserQuestion tool to ask 2-4 focused questions at a time. Structure your questions to understand:

**Round 1 - Scope & Purpose:**
- What problem does this solve?
- What layer does this belong to? (Crane framework, daosys, or product-specific)
- What are the key user actions?

**Round 2 - Technical Approach:**
- What existing patterns should this follow?
- What dependencies does this have on other tasks?
- What external protocols/contracts does this interact with?

**Round 3 - Implementation Details:**
- What are the key design decisions to make?
- What are the acceptance criteria?
- What tests are needed?

Continue asking questions until you have enough information to write complete user stories.

### Step 4: Draft User Stories

For each user story, use this format:

```markdown
**US-X.Y: [Title]**
As a [user/system/keeper], I want to [action] so that [benefit].

Acceptance Criteria:
- Specific, testable criterion 1
- Specific, testable criterion 2
- ...
```

### Step 5: Create Task Section

Generate a complete task section including:
- Task number and title
- Layer (Crane/daosys/IndexedEx)
- Worktree name suggestion
- Status (Ready for Agent)
- Description
- Dependencies
- Technical details (diagrams, interfaces, etc.)
- User Stories (US-X.1 through US-X.N)
- Files to Create/Modify
- Inventory Check (what agent must verify)
- Completion Criteria

### Step 6: Update UNIFIED_PLAN.md

Add the new task section to UNIFIED_PLAN.md in the appropriate location (before Worktree Status section).

### Step 7: Commit Changes

After user confirms the design, commit the updated UNIFIED_PLAN.md with a descriptive message.

## Standard Task Template

```markdown
## Task N: [Title]

**Layer:** [Crane | daosys | IndexedEx]
**Worktree:** `feature/[kebab-case-name]`
**Status:** Ready for Agent

### Description
[2-3 sentences describing the feature and its purpose]

### Dependencies
- [List of prerequisite tasks or conditions]

### [Technical Section - varies by feature type]
[Diagrams, interfaces, architecture details]

### User Stories

**US-N.1: [First Story Title]**
As a [role], I want to [action] so that [benefit].

Acceptance Criteria:
- [Criterion 1]
- [Criterion 2]

[Additional user stories...]

### Files to Create/Modify

**New Files:**
- `path/to/NewFile.sol` - Description

**Modified Files:**
- `path/to/ExistingFile.sol` - What changes

**Tests:**
- `test/path/TestFile.t.sol` - Description

### Inventory Check (Agent must verify)
- [ ] [Prerequisite 1 exists/works]
- [ ] [Prerequisite 2 exists/works]

### Completion Criteria
- [Measurable criterion 1]
- [Measurable criterion 2]
- [Tests pass]
```

## UNIFIED_PLAN.md Template (if creating new)

```markdown
# Unified Development Plan

This document tracks all planned features across the ecosystem.
Work is segmented into parallel worktrees for independent agent execution.

**Last Updated:** [DATE]

## Ecosystem Layers

| Layer | Repo | Purpose |
|-------|------|---------|
| **Crane** | `lib/daosys/lib/crane` | Reusable Solidity framework |
| **daosys** | `lib/daosys` | Aggregator package |
| **[Product]** | `.` (root) | Product-specific business logic |

---

## Task 1: [First Task]

[Task content...]

---

## Worktree Status

| Worktree | Path | Status |
|----------|------|--------|

---

## Agent Execution Notes

Each agent receives a `PROMPT.md` in its worktree with:
1. Clear scope boundaries
2. Inventory check requirements
3. Standardized completion promise (`TASK_COMPLETE`)
4. Files NOT to modify (owned by other agents)
```

## Remember

- Always use AskUserQuestion to clarify before assuming
- Keep user stories focused and testable
- Reference existing patterns from CLAUDE.md
- Include both success and failure/edge case criteria
- Suggest a logical task number based on existing tasks
