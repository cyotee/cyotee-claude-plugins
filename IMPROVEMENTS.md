# Plugin Improvements Plan

This document tracks the planned architecture changes and improvements for the cyotee-claude-plugins marketplace.

**Created:** 2026-01-12
**Status:** Planning

---

## Table of Contents

1. [Target Architecture](#target-architecture)
2. [Issues to Fix](#issues-to-fix)
3. [Command Changes](#command-changes)
4. [New Features](#new-features)
5. [Documentation](#documentation)
6. [Implementation Order](#implementation-order)

---

## Target Architecture

### Overview

Replace the monolithic `UNIFIED_PLAN.md` with a segmented `tasks/` directory structure. This enables:
- Smaller files that agents can process efficiently
- PROMPT.md points to task files rather than copying content
- PROGRESS.md provides persistent memory across context compactions
- Integration with ralph-loop plugin and Stop hooks for autonomous agent loops

### Directory Structure

Each repo/submodule has its own `tasks/` directory with repo-specific task numbering:

```
indexedex/                              # Product repo (prefix: IDX)
├── CLAUDE.md
├── PRD.md
├── design.yaml                         # Repo config (prefix, submodules)
├── tasks/
│   ├── INDEX.md                        # Index for this repo's tasks
│   ├── TEMPLATE.md
│   ├── IDX-001-fee-collector/
│   │   ├── TASK.md                     # Requirements
│   │   ├── PROGRESS.md                 # Implementation log
│   │   └── REVIEW.md                   # Code review findings (after review)
│   ├── IDX-002-vault-registry/
│   │   ├── TASK.md
│   │   ├── PROGRESS.md
│   │   └── REVIEW.md
│   └── archive/
│
├── lib/daosys/                         # Submodule (prefix: DAO)
│   ├── CLAUDE.md
│   ├── tasks/
│   │   ├── INDEX.md                    # Index for daosys tasks
│   │   ├── DAO-001-aggregator/
│   │   └── DAO-002-utils/
│   │
│   └── lib/crane/                      # Nested submodule (prefix: CRANE)
│       ├── CLAUDE.md
│       ├── tasks/
│       │   ├── INDEX.md                # Index for crane tasks
│       │   ├── CRANE-001-diamond-factory/
│       │   ├── CRANE-002-facet-utils/
│       │   └── CRANE-003-uniswap-v4/
│       └── ...
└── ...
```

### Repo Prefixes

Task IDs are prefixed with a **repo identifier** to indicate which repository/submodule the task belongs to. Each repo:
- Has its own `tasks/` directory
- Has its own sequential numbering (001, 002, 003...)
- Uses a unique prefix (2-6 uppercase chars)

**Task ID format:** `{REPO}-{NNN}-{kebab-name}`
- `REPO` - Uppercase repo prefix identifying the submodule
- `NNN` - Zero-padded sequential number **within that repo**
- `kebab-name` - Descriptive name in kebab-case

### Configuration Files

**Public config** (`design.yaml` in repo root) - checked into git, shared with team:
```yaml
# design.yaml
repo_prefix: CRANE
repo_name: Crane Framework

# Optional: define known submodules (for root repo)
submodules:
  - prefix: DAO
    path: lib/daosys
    name: DAOsys
  - prefix: CRANE
    path: lib/daosys/lib/crane
    name: Crane Framework
```

**Local overrides** (`.claude/design.local.md` - gitignored, per-developer):
```yaml
---
# Override any settings from design.yaml
# Example: use different worktree base for this machine
worktree_base: /Users/me/worktrees/{repo}
---

# Optional markdown notes for local context
```

**Lookup order:**
1. `.claude/design.local.md` (highest priority, local overrides)
2. `design.yaml` (repo root, shared config)
3. Built-in defaults (if neither exists)

**Examples:**
- `CRANE-001-diamond-factory` → Task in crane repo
- `CRANE-015-uniswap-v4-utils` → Task 15 in crane repo
- `DAO-003-aggregator-logic` → Task 3 in daosys repo
- `IDX-007-fee-oracle` → Task 7 in indexedex repo

**Benefits:**
- Clear which repo a task belongs to
- Each repo manages its own task numbers
- Cross-repo dependencies are explicit (e.g., `IDX-007` depends on `CRANE-015`)
- Agents work in the correct submodule worktree

### INDEX.md Format

Each repo has its own `tasks/INDEX.md`. Example for the Crane repo (`lib/daosys/lib/crane/tasks/INDEX.md`):

```markdown
# Task Index: Crane Framework

**Repo:** CRANE
**Last Updated:** 2026-01-12

## Active Tasks

| ID | Title | Status | Dependencies | Worktree |
|----|-------|--------|--------------|----------|
| CRANE-001 | Diamond Factory | Complete | - | - |
| CRANE-002 | Slipstream Utils | Complete | - | - |
| CRANE-003 | Uniswap V4 Utils | Ready | - | - |
| CRANE-004 | Balancer V3 Router | In Progress | CRANE-001 | feature/balancer-v3 |
| CRANE-005 | Fee Utils | Blocked | CRANE-003 | - |

## Status Legend

- **Ready** - All dependencies met, can be launched with `/backlog:launch`
- **In Progress** - Implementation agent working (has worktree)
- **Review** - Implementation complete, ready for `/backlog:review`
- **In Review** - Review agent working (has review worktree)
- **Changes Requested** - Review found issues, needs fixes
- **Complete** - Review passed, ready to archive with `/backlog:prune`
- **Blocked** - Waiting on dependencies

## Quick Filters

### Ready for Agent
- CRANE-003: Uniswap V4 Utils

### Blocked
- CRANE-005: Fee Utils (waiting on CRANE-003)

## Cross-Repo Dependencies

Tasks in other repos that depend on this repo's tasks:
- IDX-007 (Fee Oracle) depends on CRANE-003
- IDX-012 (Slipstream Vault) depends on CRANE-002
```

Example for root repo (`tasks/INDEX.md`):

```markdown
# Task Index: IndexedEx

**Repo:** IDX
**Last Updated:** 2026-01-12

## Active Tasks

| ID | Title | Status | Dependencies | Worktree |
|----|-------|--------|--------------|----------|
| IDX-001 | Fee Collector | Complete | CRANE-001 | - |
| IDX-002 | Vault Registry | In Progress | IDX-001 | feature/vault-registry |
| IDX-003 | Protocol DETF | Blocked | IDX-002, CRANE-003 | - |

## Cross-Repo Dependencies

This repo depends on tasks in submodules:
- IDX-001 depends on CRANE-001 (Complete ✓)
- IDX-003 depends on CRANE-003 (Ready - not started)
```

### TASK.md Format

```markdown
# Task CRANE-003: Uniswap V4 Utils

**Repo:** CRANE (lib/daosys/lib/crane)
**Status:** Ready
**Created:** 2026-01-10
**Dependencies:** None
**Worktree:** `feature/uniswap-v4-utils`

---

## Description

[2-3 sentences explaining the feature and its purpose]

## User Stories

**US-CRANE-003.1: [Story Title]**
As a [role], I want to [action] so that [benefit].

Acceptance Criteria:
- [ ] Criterion 1
- [ ] Criterion 2

**US-CRANE-003.2: [Another Story]**
...

## Files to Create/Modify

**New Files:**
- `path/to/NewFile.sol` - Description

**Modified Files:**
- `path/to/Existing.sol` - What changes

**Tests:**
- `test/path/Test.t.sol` - Description

## Inventory Check

Before starting, verify:
- [ ] Prerequisite 1 exists
- [ ] Prerequisite 2 works

## Completion Criteria

- [ ] All user stories implemented
- [ ] All tests pass
- [ ] No compiler warnings
```

### Task Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Ready     │ ──▶ │ In Progress │ ──▶ │  In Review  │ ──▶ │  Complete   │
│             │     │             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
/backlog:launch     Agent works        /backlog:review     /backlog:complete
       │            TASK_COMPLETE      Updates PROMPT.md   /backlog:prune
       │                   │           Same worktree
       ▼                   ▼           New session              │
   Creates:            Writes:         Reviewer works           ▼
   - Worktree          PROGRESS.md     REVIEW_COMPLETE       Archive
   - PROMPT.md                               │
     (impl mode)            │                │
                            ▼                ▼
                      Exit session    /backlog:review
                                      updates PROMPT.md
                                      to review mode
```

**Single worktree, mode transitions via PROMPT.md updates:**
1. `/backlog:launch` → Creates worktree, PROMPT.md (implementation mode)
2. Agent completes → Writes PROGRESS.md, exits with TASK_COMPLETE
3. `/backlog:review` → Updates PROMPT.md to review mode (same worktree)
4. New session, reviewer works → Writes REVIEW.md, exits with REVIEW_COMPLETE
5. `/backlog:complete` → Merges to main, archives

### PROGRESS.md Format

Changelog-style with newest entries first. This file serves as **persistent memory** that survives context compaction.

```markdown
# Progress Log: CRANE-003

## 2026-01-12 14:30 - Context Reset

Resuming after context compaction.

**Completed so far:**
- US-CRANE-003.1 implemented in `src/utils/UniswapV4Utils.sol`
- Basic tests written

**Current focus:**
- US-CRANE-003.2 in progress
- Need to add edge case handling

**Blockers:**
- None

---

## 2026-01-12 12:00 - Initial Progress

Started implementation.

**Completed:**
- Created file structure
- Implemented core functions for US-CRANE-003.1

**Next:**
- Write tests for US-CRANE-003.1
- Begin US-CRANE-003.2

---

## 2026-01-12 10:00 - Task Started

Agent launched. Reading TASK.md and performing inventory checks.

**Inventory Results:**
- [x] Uniswap V4 interfaces available
- [x] Forge test framework ready
```

### PROMPT.md Format (in worktree)

PROMPT.md becomes a **pointer** to task files, not a copy of content:

```markdown
# Agent Task Assignment

**Task:** CRANE-003 - Uniswap V4 Utils
**Repo:** CRANE (lib/daosys/lib/crane)
**Task Directory:** tasks/CRANE-003-uniswap-v4-utils/

## Required Reading

1. `tasks/CRANE-003-uniswap-v4-utils/TASK.md` - Full requirements
2. `tasks/CRANE-003-uniswap-v4-utils/PROGRESS.md` - Prior work and current state

## Instructions

1. Read TASK.md to understand requirements
2. Read PROGRESS.md to see what's been done
3. Continue work from where you left off
4. **Update PROGRESS.md** as you work (newest entries first)
5. When complete, output: `<promise>TASK_COMPLETE</promise>`
6. If blocked, output: `<promise>TASK_BLOCKED: [reason]</promise>`

## On Context Compaction

If your context is compacted or you're resuming work:
1. Re-read this PROMPT.md
2. Re-read PROGRESS.md for your prior state
3. Continue from the last recorded progress

## Completion Checklist

Before marking complete, verify:
- [ ] All acceptance criteria in TASK.md are checked
- [ ] PROGRESS.md has final summary
- [ ] All tests pass
```

### Hook Integration

A **generic Stop hook** prevents premature exit and enables context recovery. The hook is completely task-agnostic - it only tells the agent to re-read PROMPT.md.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Agent works │ ──▶ │ Updates     │ ──▶ │ Tries to    │
│             │     │ PROGRESS.md │     │ complete    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
                                    ┌─────────────────────┐
                                    │ Stop Hook fires     │
                                    │ - PROMPT.md exists? │
                                    │ - Promise found?    │
                                    └──────────┬──────────┘
                                               │
                         ┌─────────────────────┴─────────────────────┐
                         ▼                                           ▼
              ┌─────────────────┐                         ┌─────────────────┐
              │ TASK_COMPLETE   │                         │ No promise      │
              │ promise found   │                         │ → Block exit    │
              │ → Allow exit    │                         └────────┬────────┘
              └─────────────────┘                                  │
                                                                   ▼
                                                        ┌─────────────────┐
                                                        │ Agent receives: │
                                                        │ "Read PROMPT.md │
                                                        │  and continue"  │
                                                        └────────┬────────┘
                                                                   │
                                                                   ▼
                                                        ┌─────────────────┐
                                                        │ Agent reads     │
                                                        │ PROMPT.md       │
                                                        └────────┬────────┘
                                                                   │
                                                                   ▼
                                                        ┌─────────────────┐
                                                        │ PROMPT.md says: │
                                                        │ Read TASK.md &  │
                                                        │ PROGRESS.md     │
                                                        └────────┬────────┘
                                                                   │
                                                                   ▼
                                                        ┌─────────────────┐
                                                        │ Agent continues │
                                                        │ from last       │
                                                        │ PROGRESS.md     │
                                                        └─────────────────┘
```

**Key principles:**
1. **PROMPT.md** is the single source of truth for task assignment
2. **PROGRESS.md** is the agent's persistent memory across context compactions
3. **Stop hook is generic** - knows nothing about specific tasks
4. **Subscription usage** - agents run in interactive Claude Code, not API

### REVIEW.md Format

Created by the review agent during code review. Lives in the task directory alongside TASK.md and PROGRESS.md.

```markdown
# Code Review: CRANE-003

**Reviewer:** Agent
**Review Started:** 2026-01-12 16:00
**Status:** In Progress | Complete | Blocked

---

## Clarifying Questions

Questions asked to understand review criteria:

### Q1: Test Coverage Expectations
**Question:** What level of test coverage is expected for utility functions?
**Answer:** Unit tests for all public functions, edge cases for math operations.

### Q2: Error Handling
**Question:** Should functions revert or return error codes?
**Answer:** Revert with descriptive messages for invalid inputs.

---

## Review Findings

### Finding 1: Missing Input Validation
**File:** `src/utils/UniswapV4Utils.sol:45`
**Severity:** Medium
**Description:** `calculateFee()` doesn't validate that `amount > 0`
**Status:** Open | Resolved | Won't Fix
**Resolution:** (filled in as reviewer reads more code or user responds)

### Finding 2: Uncovered Edge Case
**File:** `test/UniswapV4Utils.t.sol`
**Severity:** Low
**Description:** No test for zero liquidity scenario
**Status:** Open
**Resolution:**

---

## Suggestions

Actionable items for follow-up tasks:

### Suggestion 1: Add Input Validation
**Priority:** High
**Description:** Add require statements for zero-value checks in all calculation functions
**Affected Files:**
- `src/utils/UniswapV4Utils.sol`
**User Response:** Accepted | Rejected | Modified
**Notes:** (user can add notes explaining decision)

### Suggestion 2: Expand Test Coverage
**Priority:** Medium
**Description:** Add edge case tests for boundary conditions
**Affected Files:**
- `test/UniswapV4Utils.t.sol`
**User Response:**
**Notes:**

---

## Review Summary

**Findings:** 2 (1 medium, 1 low)
**Suggestions:** 2
**Recommendation:** Address findings before marking complete

---

## Review Complete

When review is done: `<promise>REVIEW_COMPLETE</promise>`
```

---

## Issues to Fix

### 1. Duplicate Command Files

**Priority:** High
**Plugins affected:** backlog, design

| Duplicate Pair | Issue |
|----------------|-------|
| `backlog/commands/status.md` & `backlog/commands/backlog.md` | Near-identical content |
| `design/commands/task.md` & `design/commands/design.md` | Exact duplicates |

**Fix:**
- Remove `status.md`, keep `backlog.md` as canonical
- Remove `task.md`, keep `design.md` as canonical

---

### 2. Version Mismatch

**Priority:** Medium
**Plugins affected:** backlog

**Issue:** `marketplace.json` shows backlog v1.0.0 but plugin.json has v1.1.0

**Fix:** Sync versions across all files

---

### 3. Project-Specific Coupling

**Priority:** High
**Plugins affected:** all

**Issues:**
- Templates hardcode "Crane/daosys/IndexedEx" layer names
- Worktree paths assume specific submodule structure

**Fix:**
- Remove all project-specific references
- Use generic templates
- Support `design.yaml` (shared) with `.claude/design.local.md` (local overrides)

---

### 4. Invalid Marketplace Source URLs

**Priority:** Medium

**Issue:** `marketplace.json` references non-existent GitHub repos

**Fix:** Update to correct source paths for this monorepo

---

## Command Changes

### `/design` (design plugin)

**Current:** Creates task section in UNIFIED_PLAN.md
**New behavior:**
1. Determine repo prefix from current directory (reads `design.yaml` or `.claude/design.local.md`)
2. Read `tasks/INDEX.md` to get next task number for this repo
3. Interactive design session to gather requirements
4. Create `tasks/{REPO}-{NNN}-kebab-name/TASK.md` from template
5. Create empty `tasks/{REPO}-{NNN}-kebab-name/PROGRESS.md`
6. Update `tasks/INDEX.md` with new task row

**Usage:**
```bash
cd lib/daosys/lib/crane
/design Add Uniswap V4 utils library
# Creates tasks/CRANE-003-uniswap-v4-utils/
```

---

### `/design:init` (design plugin)

**Current:** Does not exist
**New behavior:**
1. Create `tasks/` directory structure
2. Create `tasks/INDEX.md` with empty table
3. Create `tasks/TEMPLATE.md` with TASK.md template
4. Create `tasks/archive/` directory

---

### `/design:review` (design plugin)

**Current:** Reviews UNIFIED_PLAN.md
**New behavior:**
1. Scan `tasks/*/TASK.md` files
2. Check each for completeness and quality
3. Validate INDEX.md matches actual tasks
4. Report issues and recommendations

---

### `/design:digest <file>` (design plugin)

**Current:** Does not exist
**New behavior:**

Digest an existing design document (UNIFIED_PLAN.md, PRD.md, or any markdown file) into individual tasks.

**Process:**
1. Read the specified file
2. Determine repo prefix from current directory
3. Analyze content to identify potential tasks/features
4. For each identified task, ask clarifying questions:
   - Which repo does this belong to? (if task spans submodules)
   - What are the dependencies (including cross-repo)?
   - Are the acceptance criteria clear?
   - Any missing information or ambiguity?
5. Create task directories with TASK.md files in appropriate repo's tasks/
6. Update each repo's tasks/INDEX.md with new entries
7. Optionally archive the source document

**Interactive clarification examples:**
```
Found potential task: "Implement fee collection system"

Questions:
1. Repo: This task appears to involve:
   - Core fee utilities (would go in CRANE)
   - Fee collector contract (would go in IDX)
   Should I split this into two tasks?

2. The description mentions "configurable fees" but doesn't specify:
   - What fee types are supported?
   - Who can configure fees?
   - What are the fee limits?

3. Dependencies: Does this depend on any existing tasks?
   - Found CRANE-001 (Diamond Factory) - likely dependency?
```

**Usage:**
```bash
/design:digest UNIFIED_PLAN.md
/design:digest PRD.md
/design:digest docs/feature-spec.md
```

**Output:**
```
Digested 5 tasks from UNIFIED_PLAN.md:

In lib/daosys/lib/crane/tasks/:
- CRANE-004: Fee Utils Library
- CRANE-005: Oracle Integration Utils

In tasks/:
- IDX-003: Fee Collector Contract
- IDX-004: Admin Dashboard
- IDX-005: User Portfolio View

Updated INDEX.md in 2 repos.
```

---

### `/backlog` (backlog plugin)

**Current:** Parses UNIFIED_PLAN.md for status table
**New behavior:**
1. Read `tasks/INDEX.md`
2. Display formatted status table
3. Show ready vs blocked tasks
4. Recommend next task to launch

---

### `/backlog:read <ID>` (backlog plugin)

**Current:** Extracts task section from UNIFIED_PLAN.md
**New behavior:**
1. Find `tasks/{ID}-*/TASK.md` (e.g., `tasks/CORE-003-*/TASK.md`)
2. Display full task content
3. Also show latest PROGRESS.md entry if exists

**Usage:**
```bash
/backlog:read CORE-003
/backlog:read APP-001
```

---

### `/backlog:launch <ID>` (backlog plugin)

**Current:** Creates worktree, copies task content to PROMPT.md
**New behavior:**

**Phase 1: Prepare task files**
1. Find task directory `tasks/{ID}-*/`
2. Initialize PROGRESS.md with "Task Started" entry (if not exists)
3. **Commit task files** to ensure worktree will have them:
   ```bash
   git add tasks/{ID}-*/
   git commit -m "chore: prepare task {ID} for agent launch"
   ```

**Phase 2: Create worktree**
4. Determine worktree location based on repo config
5. Create worktree using scripts:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/wt-create.sh" <branch-name> <repo-root>
   ```
6. Initialize submodules in worktree:
   ```bash
   cd <worktree-path>
   git submodule update --init --recursive
   ```

**Phase 3: Setup agent environment**
7. Create PROMPT.md in worktree root that **points to** task files
8. Update `tasks/INDEX.md` status to "In Progress"

**Phase 4: Output launch instructions**
9. Output ready-to-use commands with absolute paths:

```
═══════════════════════════════════════════════════════════════════
 AGENT READY: CRANE-003 - Uniswap V4 Utils
═══════════════════════════════════════════════════════════════════

Task files committed and worktree created.

## Step 1: Open a new terminal and run:

cd /Users/you/repos/crane-wt/feature/uniswap-v4-utils

## Step 2: Start Claude Code in sandbox mode:

claude --dangerously-skip-permissions

## Step 3: Give Claude this prompt:

/up:prompt

This will read PROMPT.md which directs the agent to:
- tasks/CRANE-003-uniswap-v4-utils/TASK.md (requirements)
- tasks/CRANE-003-uniswap-v4-utils/PROGRESS.md (your progress log)

The Stop hook will prevent exit until task is complete.
Agent will use subscription usage, not API credits.

═══════════════════════════════════════════════════════════════════
```

**Usage:**
```bash
/backlog:launch CRANE-003
/backlog:launch CRANE-003 --max-iterations 20
```

**Arguments:**
| Argument | Description |
|----------|-------------|
| `<ID>` | Task ID to launch (e.g., CRANE-003) |
| `--max-iterations <N>` | Optional safety limit (default: 0 = unlimited) |

**Why commit before worktree?**
- Worktree is created from current HEAD
- If task files aren't committed, worktree won't have them
- Agent needs TASK.md and PROGRESS.md to exist in the worktree

---

### `/backlog:complete [N]` (backlog plugin)

**Current:** Rebases, merges, updates UNIFIED_PLAN.md
**New behavior:**

**Phase 1: Cleanup worktree-specific files**
1. Verify in feature worktree (not main)
2. Check PROGRESS.md has completion summary
3. **Delete worktree-specific files** (prevent polluting main):
   ```bash
   rm -f PROMPT.md
   rm -f .claude/backlog-agent.local.md
   git add -A
   git commit -m "chore: cleanup task files before merge"
   ```

**Phase 2: Merge to main**
4. Rebase onto local main: `git rebase main`
5. Fast-forward main: `git branch -f main HEAD`
6. Optionally push: `git push origin main` (if `--push` flag)

**Phase 3: Update task status**
8. Update `tasks/INDEX.md` status to "Complete"
9. Commit INDEX.md change to main

**Phase 4: Cleanup**
10. Output worktree deletion instructions (can't self-delete)

**Files removed before merge:**
| File | Reason |
|------|--------|
| `PROMPT.md` | Task-specific agent instructions |
| `.claude/backlog-agent.local.md` | Iteration state file |
| `.claude/` directory (if empty) | Clean up |

**Usage:**
```bash
/backlog:complete CRANE-003
/backlog:complete CRANE-003 --push
```

---

### `/backlog:review <ID>` (backlog plugin)

**Current:** Does not exist
**New behavior:**

Transition a task to review mode by updating PROMPT.md in the **existing worktree**.

**Prerequisites:**
- Task must have a worktree (created by `/backlog:launch`)
- Implementation should be complete (agent exited with TASK_COMPLETE)

**What it does:**
1. Find the existing worktree for task
2. Update PROMPT.md to review mode (replaces implementation instructions)
3. Create/initialize REVIEW.md template in task directory
4. Update INDEX.md status: "In Progress" → "In Review"
5. Update state file mode: "implementation" → "review"
6. Output instructions to start fresh session

**Output:**
```
═══════════════════════════════════════════════════════════════════
 REVIEW MODE: CRANE-003 - Uniswap V4 Utils
═══════════════════════════════════════════════════════════════════

PROMPT.md updated to review mode in existing worktree.

## Step 1: Exit current Claude session (if any)

## Step 2: Start fresh Claude session:

cd /Users/you/repos/crane-wt/feature/uniswap-v4-utils
claude --dangerously-skip-permissions

## Step 3: Give Claude this prompt:

/up:prompt

The reviewer will:
- Read PROMPT.md (now in review mode)
- Read TASK.md, PROGRESS.md for context
- Ask clarifying questions if needed (saved to REVIEW.md)
- Review code for correctness and completeness
- Document findings in REVIEW.md
- Output <promise>REVIEW_COMPLETE</promise> when done

TIP: You can use a different model for review!
     claude --model claude-sonnet-4-20250514 --dangerously-skip-permissions

═══════════════════════════════════════════════════════════════════
```

**Updated PROMPT.md (review mode):**
```markdown
# Agent Task Assignment

**Task:** CRANE-003 - Uniswap V4 Utils
**Mode:** Code Review
**Task Directory:** tasks/CRANE-003-uniswap-v4-utils/

## Required Reading

1. `tasks/CRANE-003-uniswap-v4-utils/TASK.md` - Requirements to verify
2. `PRD.md` - Project context and standards (if exists)
3. `tasks/CRANE-003-uniswap-v4-utils/PROGRESS.md` - Implementation notes
4. `tasks/CRANE-003-uniswap-v4-utils/REVIEW.md` - Your review document

## Review Instructions

1. Read TASK.md to understand what was required
2. Read PROGRESS.md to understand what was implemented

3. **If unclear on review criteria:**
   - Use AskUserQuestion to clarify expectations
   - Write questions and answers to REVIEW.md "Clarifying Questions" section

4. **Review the code:**
   - Check all acceptance criteria in TASK.md are met
   - Verify test coverage
   - Look for bugs, edge cases, security issues
   - Update REVIEW.md with findings as you go
   - Mark findings as Resolved if you answer your own questions

5. **Write suggestions:**
   - Document actionable improvements in REVIEW.md
   - Prioritize by severity
   - These will be used to create follow-up tasks

6. When review is complete: `<promise>REVIEW_COMPLETE</promise>`

## On Context Compaction

If context is compacted or you're resuming:
1. Re-read this PROMPT.md
2. Re-read REVIEW.md for your prior findings
3. Continue review from where you left off
```

**Why same worktree?**
- Reviewing the same files that were implemented
- No need to duplicate the environment
- User can choose different model for review (fresh perspective)
- Simpler workflow - just update PROMPT.md and start new session

---

### `/backlog:prune` (backlog plugin)

**Current:** Archives completed task sections
**New behavior:**
1. Find all tasks with "Complete" status in INDEX.md (must have passed review)
2. Move their directories to `tasks/archive/`
3. Remove from active section of INDEX.md
4. Add to archive section of INDEX.md

---

## New Features

### 1. `/backlog:list` - List Active Worktrees

**Priority:** High
**Plugin:** backlog

Show all active worktrees with their tasks:

```
Active Worktrees:

| Task | Branch | Path | Status |
|------|--------|------|--------|
| 003 | feature/uniswap-v4 | ../repo-wt/feature/uniswap-v4 | In Progress |
| 004 | feature/slipstream | ../repo-wt/feature/slipstream | Paused |

Total: 2 active worktrees
```

---

### 2. `/design:prd` - Create/Update PRD.md

**Priority:** Medium
**Plugin:** design

Interactive session to create Product Requirements Document at repo root. Separate from task management.

---

### 3. `/backlog:deps` - Dependency Graph

**Priority:** Low
**Plugin:** backlog

Visualize task dependencies:

```
Task Dependencies:

003: Uniswap V4 Utils
  └── (no dependencies) ✓ Ready

004: Slipstream Vault
  └── depends on: 002 (Complete ✓)
  └── ✓ Ready

005: Protocol DETF
  ├── depends on: 003 (Ready)
  └── depends on: 004 (In Progress)
  └── ✗ Blocked
```

---

### 4. Stop Hook for Completion Validation

**Priority:** High
**Plugin:** backlog

Create a **generic** Stop hook that works with any task. The hook knows nothing about specific task IDs - it only tells the agent to re-read PROMPT.md.

**Hook behavior:**
1. Check if PROMPT.md exists in current directory (indicates agent worktree)
2. If no PROMPT.md → allow exit (not an agent session)
3. Check agent's last output for `<promise>TASK_COMPLETE</promise>`
4. If found → allow exit
5. If not found → block exit with generic re-entry instructions

**Block response:**
```json
{
  "decision": "block",
  "reason": "Read PROMPT.md and continue from where you left off. Check PROGRESS.md for your prior work.",
  "systemMessage": "🔄 Task incomplete. If context is large, run /compact first. Then re-read PROMPT.md."
}
```

**Why generic?**
- PROMPT.md is the single source of truth for task assignment
- PROMPT.md points to specific TASK.md and PROGRESS.md files
- Hook doesn't need to know task IDs, repo structure, or file locations
- Same hook works for any task in any repo

**Flow:**
```
Agent tries to exit
    ↓
Stop hook checks for PROMPT.md
    ↓
Found? Check for <promise>TASK_COMPLETE</promise>
    ↓
┌─────────────────────────────────────┐
│ Promise found?                      │
├──────────────┬──────────────────────┤
│ YES          │ NO                   │
│ Allow exit   │ Block with:         │
│              │ "Read PROMPT.md"     │
└──────────────┴──────────────────────┘
    ↓ (if blocked)
Agent reads PROMPT.md
    ↓
PROMPT.md says: read TASK.md, PROGRESS.md
    ↓
Agent continues work
```

---

### 5. `/up:prompt` - Bootstrap for Agent Worktree (Update Existing)

**Priority:** High
**Plugin:** up

Update the existing `/up:prompt` command to fully bootstrap an agent in a worktree:

1. Read CLAUDE.md (project context)
2. Read PROMPT.md (task assignment)
3. Parse PROMPT.md to find task file paths
4. Read referenced TASK.md (requirements)
5. Read PROGRESS.md (prior work, if exists)
6. Output current state summary and begin work

**Output example:**
```
═══════════════════════════════════════════════════════════════════
 AGENT BOOTSTRAPPED
═══════════════════════════════════════════════════════════════════

Project: Crane Framework
Task: CRANE-003 - Uniswap V4 Utils

## Requirements (from TASK.md)
- US-CRANE-003.1: Core position utilities
- US-CRANE-003.2: Fee calculation helpers
- US-CRANE-003.3: Integration tests

## Prior Progress (from PROGRESS.md)
Last entry: 2026-01-12 14:30
- US-CRANE-003.1 complete
- US-CRANE-003.2 in progress

## Continuing from:
- Implement remaining fee calculation helpers
- Write tests for completed work

## Completion
When done: <promise>TASK_COMPLETE</promise>

═══════════════════════════════════════════════════════════════════

Beginning work...
```

**This is the command the user gives to the agent after starting Claude Code in the worktree.**

---

### 6. `/up:prompt` Handles Both Modes

**Priority:** High
**Plugin:** up

The `/up:prompt` command reads PROMPT.md and adapts based on the **Mode** field:

```markdown
**Mode:** Implementation  →  Bootstrap for coding
**Mode:** Code Review     →  Bootstrap for reviewing
```

No separate `/up:review` command needed. The PROMPT.md content determines behavior.

**Implementation mode output:**
```
═══════════════════════════════════════════════════════════════════
 AGENT BOOTSTRAPPED - Implementation
═══════════════════════════════════════════════════════════════════
Task: CRANE-003 - Uniswap V4 Utils
...
Completion: <promise>TASK_COMPLETE</promise>
═══════════════════════════════════════════════════════════════════
```

**Review mode output:**
```
═══════════════════════════════════════════════════════════════════
 AGENT BOOTSTRAPPED - Code Review
═══════════════════════════════════════════════════════════════════
Reviewing: CRANE-003 - Uniswap V4 Utils

## Implementation Summary (from PROGRESS.md)
- All user stories marked complete
- Tests written and passing

## Review Focus
- Verify acceptance criteria
- Check test coverage
- Look for bugs/edge cases

Completion: <promise>REVIEW_COMPLETE</promise>
═══════════════════════════════════════════════════════════════════
```

**Same command, mode-aware behavior.**

---

### 7. `/design:from-review <ID>` - Create Tasks from Review Suggestions

**Priority:** Medium
**Plugin:** design

Create new tasks from review suggestions:

1. Read `tasks/{ID}-*/REVIEW.md`
2. Parse suggestions section
3. For each accepted suggestion (User Response: Accepted or Modified):
   - Create a new task with the suggestion as the description
   - Link back to original task in dependencies
4. Update INDEX.md with new tasks

**Usage:**
```bash
/design:from-review CRANE-003
```

**Output:**
```
Created 2 tasks from CRANE-003 review suggestions:

- CRANE-004: Add Input Validation
  From: Suggestion 1 (Priority: High)

- CRANE-005: Expand Test Coverage
  From: Suggestion 2 (Priority: Medium)

Skipped 0 suggestions (rejected by user)
```

**This closes the loop:** Review findings become actionable tasks.

---

## Documentation

### 1. Architecture Documentation

**Priority:** High

Document the full `tasks/` directory architecture in README.md files.

---

### 2. ralph-loop Integration Guide

**Priority:** High

Document:
- How to use these plugins with ralph-loop
- Hook configuration for Stop events
- Context recovery pattern
- PROGRESS.md best practices

---

### 3. Migration Guide

**Priority:** Medium

Document how to migrate from UNIFIED_PLAN.md to tasks/ directory:
1. Run `/design:init`
2. For each task in UNIFIED_PLAN.md, run migration script
3. Verify INDEX.md is accurate
4. Archive UNIFIED_PLAN.md

---

## Implementation Order

### Phase 1: Core Architecture
1. **Create `/design:init`** - Foundation for new architecture (creates tasks/ structure)
2. **Update `/design`** - Create tasks with repo-prefixed IDs
3. **Create `/design:digest`** - Parse existing docs into tasks
4. **Update `/backlog`** - Read from tasks/INDEX.md
5. **Update `/backlog:read`** - Read from task directories

### Phase 2: Agent Launch
6. **Update `/backlog:launch`** - Commit files, create worktree, init submodules, output instructions
7. **Update `/up:prompt`** - Bootstrap implementation agent
8. **Create Stop hook** - Generic hook for task completion
9. **Fix duplicate files** - Remove status.md, task.md

### Phase 3: Review Workflow
10. **Create `/backlog:review`** - Update PROMPT.md to review mode (same worktree)
11. **Update `/up:prompt`** - Mode-aware bootstrap (implementation vs review)
12. **Create `/design:from-review`** - Create tasks from review suggestions

### Phase 4: Task Completion
13. **Update `/backlog:complete`** - Handle new structure (after review passes)
14. **Update `/backlog:prune`** - Move to archive/
15. **Add `/backlog:list`** - Show worktrees across repos

### Phase 5: Polish
16. **Update all documentation** - Architecture, workflow guides
17. **Fix marketplace.json** - Correct versions and sources
18. **Remove project-specific references** - Generic templates with configurable repo prefixes

---

## Hook Implementation Plan

Based on analysis of the official ralph-loop plugin, here's the implementation plan for our Stop hook.

### File Structure

```
plugins/backlog/
├── hooks/
│   ├── hooks.json              # Hook registration
│   └── stop-hook.sh            # Hook script
├── scripts/
│   ├── wt-create.sh            # (existing)
│   └── wt-remove.sh            # (existing)
└── commands/
    └── ...
```

### hooks/hooks.json

```json
{
  "description": "Backlog plugin stop hook for task completion validation",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### State File: .claude/backlog-agent.local.md

Optional state file created by `/backlog:launch` to track iterations:

```markdown
---
active: true
iteration: 1
max_iterations: 0
started_at: "2026-01-12T10:00:00Z"
task_id: "CRANE-003"
mode: "implementation"
---
```

- `max_iterations: 0` means unlimited (default)
- `max_iterations: 20` stops after 20 iterations
- File is created by `/backlog:launch` with user-specified limit
- File is deleted when task completes or limit reached

### hooks/stop-hook.sh

```bash
#!/bin/bash

# Backlog Stop Hook
# Generic hook that keeps agents working until task/review is complete
# Supports optional iteration limits for safety

set -euo pipefail

# Read hook input from stdin (provides transcript_path)
HOOK_INPUT=$(cat)

# Check if PROMPT.md exists (indicates we're in an agent worktree)
if [[ ! -f "PROMPT.md" ]]; then
  # Not an agent worktree - allow exit
  exit 0
fi

# State file for iteration tracking (optional)
STATE_FILE=".claude/backlog-agent.local.md"

# Default values if no state file
ITERATION=1
MAX_ITERATIONS=0
MODE="implementation"

# Read state file if exists
if [[ -f "$STATE_FILE" ]]; then
  FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
  ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' || echo "1")
  MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//' || echo "0")
  MODE=$(echo "$FRONTMATTER" | grep '^mode:' | sed 's/mode: *//' | tr -d '"' || echo "implementation")

  # Validate numeric fields
  if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
    ITERATION=1
  fi
  if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=0
  fi
fi

# Check if max iterations reached
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "🛑 Max iterations ($MAX_ITERATIONS) reached."
  echo "   Task did not complete within iteration limit."
  echo "   Check PROGRESS.md for current state."
  [[ -f "$STATE_FILE" ]] && rm "$STATE_FILE"
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "⚠️  Backlog hook: Transcript file not found" >&2
  exit 0
fi

# Check if there are any assistant messages
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  exit 0
fi

# Extract last assistant message
LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

# Check for completion promises
PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g' 2>/dev/null || echo "")

if [[ "$PROMISE_TEXT" = "TASK_COMPLETE" ]]; then
  echo "✅ Task complete - implementation finished"
  [[ -f "$STATE_FILE" ]] && rm "$STATE_FILE"
  exit 0
fi

if [[ "$PROMISE_TEXT" = "REVIEW_COMPLETE" ]]; then
  echo "✅ Review complete - code review finished"
  [[ -f "$STATE_FILE" ]] && rm "$STATE_FILE"
  exit 0
fi

if [[ "$PROMISE_TEXT" = "TASK_BLOCKED" ]] || [[ "$PROMISE_TEXT" == TASK_BLOCKED:* ]]; then
  echo "⚠️  Task blocked - agent reported blocker"
  [[ -f "$STATE_FILE" ]] && rm "$STATE_FILE"
  exit 0
fi

# Not complete - increment iteration and block exit
NEXT_ITERATION=$((ITERATION + 1))

# Update state file if exists
if [[ -f "$STATE_FILE" ]]; then
  TEMP_FILE="${STATE_FILE}.tmp.$$"
  sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$TEMP_FILE"
  mv "$TEMP_FILE" "$STATE_FILE"
fi

# Determine promise type based on mode
if [[ "$MODE" = "review" ]]; then
  PROMISE="REVIEW_COMPLETE"
else
  PROMISE="TASK_COMPLETE"
fi

# Build iteration info for system message
if [[ $MAX_ITERATIONS -gt 0 ]]; then
  ITER_INFO="Iteration $NEXT_ITERATION of $MAX_ITERATIONS"
else
  ITER_INFO="Iteration $NEXT_ITERATION (no limit)"
fi

jq -n \
  --arg mode "$MODE" \
  --arg promise "$PROMISE" \
  --arg iter "$ITER_INFO" \
  '{
    "decision": "block",
    "reason": "Read PROMPT.md and continue from where you left off. Check PROGRESS.md for your prior work.",
    "systemMessage": ("🔄 " + $iter + " | " + $mode + " incomplete. If context is large, run /compact first. Then re-read PROMPT.md. Complete with <promise>" + $promise + "</promise>")
  }'

exit 0
```

### Key Design Decisions

1. **Generic by design** - Hook only checks for PROMPT.md, knows nothing about task IDs
2. **Multiple promise types** - Supports TASK_COMPLETE, REVIEW_COMPLETE, and TASK_BLOCKED
3. **Mode detection** - Checks state file or PROMPT.md to determine implementation vs review
4. **Blocked handling** - Allows exit when agent reports TASK_BLOCKED (user intervention needed)
5. **Optional iteration limits** - State file only created if `--max-iterations` specified
6. **Two exit safety valves:**
   - `TASK_BLOCKED` - Agent explicitly reports it's stuck
   - `--max-iterations` - Hard limit on loop iterations

### Context Management

**Limitation accepted:** Hooks cannot force context clear or start new sessions. Context accumulates across iterations within a session.

**User options for context control:**

| Strategy | How | When to use |
|----------|-----|-------------|
| Let it accumulate | Default behavior | Short tasks, sufficient context window |
| Suggest /compact | Hook suggests, agent decides | Medium tasks, reduce context |
| Single iteration | `--max-iterations 1` | Force exit after each iteration, user restarts |
| Low iterations | `--max-iterations 3` | Periodic forced exits for fresh sessions |
| Manual reset | User runs `/clear` then `/up:prompt` | Mid-session reset without exiting |

**Manual context reset within session:**
```bash
# User can reset context without exiting:
/clear
/up:prompt
# Agent starts fresh but in same session
```

**Periodic fresh sessions:**
```bash
# Launch with low iteration limit
/backlog:launch CRANE-003 --max-iterations 3

# Agent runs 3 iterations, hook allows exit
# User starts fresh session:
claude --dangerously-skip-permissions
/up:prompt
# Repeat until TASK_COMPLETE
```

This approach gives users full control over the context/iteration tradeoff.

### Differences from ralph-loop

| Aspect | ralph-loop | Our hook |
|--------|------------|----------|
| State file | `.claude/ralph-loop.local.md` (required) | `.claude/backlog-agent.local.md` (optional) |
| Iteration tracking | Always | Optional (only if max set) |
| Max iterations | Required param | Optional (`--max-iterations`) |
| Prompt source | Stored in state file | Fixed message → PROMPT.md |
| Promise types | Single user-configurable | Fixed: TASK_COMPLETE, REVIEW_COMPLETE, TASK_BLOCKED |
| Blocked handling | No special handling | TASK_BLOCKED allows exit |
| Mode awareness | No | Detects implementation vs review |

### Testing the Hook

```bash
# Test 1: Not in worktree (no PROMPT.md)
cd /tmp && echo '{}' | ./stop-hook.sh
# Expected: exit 0 (allow)

# Test 2: In worktree, no completion
cd /path/to/worktree  # has PROMPT.md
echo '{"transcript_path": "/path/to/transcript.jsonl"}' | ./stop-hook.sh
# Expected: JSON with decision=block

# Test 3: In worktree, with TASK_COMPLETE
# (transcript contains <promise>TASK_COMPLETE</promise>)
# Expected: exit 0 (allow)
```

### Integration with Existing Scripts

The hook uses the same patterns as ralph-loop:
- `jq` for JSON parsing
- `perl` for multiline regex (promise extraction)
- Reads transcript from path provided in hook input
- Outputs JSON to control Claude Code behavior

---

## Open Questions

1. ~~**Task numbering:** Use sequential (001, 002) or date-based (2026-01-12-feature)?~~
   - **Resolved:** Sequential with zero-padding, prefixed by repo identifier

2. **INDEX.md machine parsing:** Add YAML frontmatter for programmatic access?
   - **Recommendation:** Yes, include frontmatter with repo prefix, task count, last updated

3. **Archive retention:** Keep archived tasks forever or prune after N days?
   - **Recommendation:** Keep forever, let users manually clean if needed

4. **Hook plugin:** Bundle hooks with backlog or create separate plugin?
   - **Recommendation:** Separate `hooks` plugin for flexibility

5. **Cross-repo task dependencies:** How to validate cross-repo dependencies?
   - Should `/design:digest` check if dependency tasks exist in submodule?
   - Should `/backlog` show cross-repo dependency status?
   - **Recommendation:** Yes to both - validate deps exist, show their status

6. **Repo prefix detection:** How to auto-detect repo prefix?
   - Option A: Read from `design.yaml` (shared) or `.claude/design.local.md` (override)
   - Option B: Derive from git remote name
   - Option C: Require explicit configuration
   - **Recommendation:** Option A with fallback to asking user

7. **Submodule worktree handling:** When launching a task in a submodule, where to create worktree?
   - Create worktree at submodule level (e.g., `crane-wt/feature/...`)
   - **Recommendation:** Yes, each repo manages its own worktrees
