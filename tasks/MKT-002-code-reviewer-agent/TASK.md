# Task MKT-002: Code Reviewer (Agent + Skill)

**Repo:** Cyotee Claude Plugins
**Status:** Ready
**Created:** 2026-01-14
**Dependencies:** None
**Worktree:** `feature/code-reviewer`

---

## Description

Create both a `code-reviewer` skill and `code-auditor` agent for the backlog plugin. The skill provides inline code review knowledge during normal work. The agent performs comprehensive automated reviews in isolated context, populating REVIEW.md with findings.

**Two Components:**
- **Skill (`code-reviewer`)**: Inline review standards, quick checks, review knowledge
- **Agent (`code-auditor`)**: Comprehensive review, REVIEW.md population, isolated analysis

## Dependencies

- None

## User Stories

### US-MKT-002.1: Inline Code Review Knowledge (Skill)

As a developer, I want Claude to automatically apply code review standards when I ask about code quality so that I get consistent feedback inline.

**Acceptance Criteria:**
- [ ] Skill triggers on "review this code", "check my implementation", "code quality"
- [ ] Skill provides review checklist and standards
- [ ] Skill works in shared conversation context
- [ ] Skill references detailed docs via progressive disclosure

### US-MKT-002.2: Requirements-Based Review (Agent)

As a developer, I want the agent to compare implementation against TASK.md requirements so that I know if acceptance criteria are met.

**Acceptance Criteria:**
- [ ] Agent reads TASK.md and extracts acceptance criteria
- [ ] Agent reads changed files in the worktree
- [ ] Agent checks each criterion against the implementation
- [ ] Agent reports which criteria are met/unmet

### US-MKT-002.3: Code Quality Analysis (Agent)

As a developer, I want the agent to identify potential issues so that bugs are caught before human review.

**Acceptance Criteria:**
- [ ] Agent identifies potential bugs and edge cases
- [ ] Agent checks for missing error handling
- [ ] Agent flags missing tests
- [ ] Agent notes security concerns if applicable

### US-MKT-002.4: Automated REVIEW.md Population (Agent)

As a developer, I want the agent to document findings in REVIEW.md so that the review is preserved.

**Acceptance Criteria:**
- [ ] Agent writes findings to REVIEW.md "Review Findings" section
- [ ] Agent writes suggestions to REVIEW.md "Suggestions" section
- [ ] Agent provides a summary and recommendation
- [ ] Agent outputs `<promise>REVIEW_COMPLETE</promise>` when done

## Technical Details

### Skill: `code-reviewer`

Location: `plugins/backlog/skills/code-reviewer/`

```
skills/code-reviewer/
├── SKILL.md              # Core review standards and triggers
├── checklist.md          # Detailed review checklist
└── patterns.md           # Common issues and anti-patterns
```

**Triggers:** "review this code", "check implementation", "code quality", "is this code ready"

### Agent: `code-auditor`

Location: `plugins/backlog/agents/code-auditor.md`

- YAML frontmatter: tools (Read, Glob, Grep, Bash), model (sonnet)
- System prompt describing comprehensive review methodology
- Instructions to read TASK.md, PROGRESS.md first
- Output format aligned with REVIEW.md structure

**Triggers:** "full code review", "audit implementation", "review all changes", "populate REVIEW.md"

## Files to Create/Modify

**New Files:**
- `plugins/backlog/skills/code-reviewer/SKILL.md` - Core review skill
- `plugins/backlog/skills/code-reviewer/checklist.md` - Detailed checklist
- `plugins/backlog/skills/code-reviewer/patterns.md` - Common issues
- `plugins/backlog/agents/code-auditor.md` - Comprehensive review agent

**Modified Files:**
- `plugins/backlog/commands/review.md` - Reference skill/agent options

## Inventory Check

Before starting, verify:
- [ ] `plugins/backlog/` directory exists
- [ ] `plugins/backlog/.claude-plugin/plugin.json` exists
- [ ] Understand REVIEW.md structure and sections
- [ ] Understand git diff commands for worktree analysis
- [ ] Review MKT-001 implementation pattern (task-reviewer skill + task-auditor agent)

## Completion Criteria

- [ ] Skill directory created with SKILL.md and supporting files
- [ ] Agent file created with proper frontmatter
- [ ] Skill triggers on inline review requests
- [ ] Agent produces findings in REVIEW.md format
- [ ] Agent checks acceptance criteria systematically
- [ ] Both tested with sample code

---

**When complete, output:** `<promise>TASK_COMPLETE</promise>`

**If blocked, output:** `<promise>TASK_BLOCKED: [reason]</promise>`
