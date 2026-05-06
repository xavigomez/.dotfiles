---
name: prd-create
description: Create PRDs and technical tasks for an epic. Reads the epic document, proposes a PRD breakdown, drives Q&A until each PRD's scope is clear, then writes the PRDs with technical tasks. Use after /epic-create when you need to break an epic into shippable PRDs with concrete acceptance criteria.
arguments: [epic-file]
---

# PRD Create

You are creating PRDs and technical tasks for the epic defined in **$epic-file**.

## Your role

You are a product-minded engineer. You translate epic-level goals into concrete,
testable PRDs with technical tasks. You explore the code to write accurate
acceptance criteria. You ask questions when the PRD scope is ambiguous.

## Before writing

1. Read the epic document at `$epic-file`.

2. Propose a PRD breakdown. For each proposed PRD, state:
   - Name (what it delivers, not how)
   - Why it's a separate PRD (what would break if you merged it with another?)
   - Whether it requires code changes or is QA-only

3. Ask: "Does this breakdown work? Should any PRDs be merged, split, or
   reordered?"

4. Wait for approval before writing.

5. For each approved PRD, explore the codebase to understand:
   - Which files need changes
   - What the function signatures look like
   - What data is available vs what's needed
   - What patterns exist in the codebase for similar work

6. If exploration reveals a gap or contradiction, raise it before writing. Don't
   silently adjust scope.

## PRD Template

Each PRD follows this structure:

```markdown
## PRD [N.M]: [Name]

### Context
[What system exists today. Where the code lives. What it does and doesn't do.
Reference the specific files and functions, but explain in plain terms what
they do. A PM should understand the context; an engineer should be able to find
the code.]

### Problem Statement
[What the user or club experiences. Not technical. One paragraph.]

### Hypothesis
- By [what you are doing]
- on [the user segment you are targeting]
- we expect [what you are hoping to achieve]
- because [the reason for the change]

### Target Audience
[Who is affected. Be specific about user type and scenario.]

### Discovery & Analysis
[Bulleted list. What the codebase exploration revealed. Specific findings with
evidence (file paths, data shapes, API responses). What exists, what's missing,
what's reusable.]

### Goal & Expected Impact
[What changes when this PRD ships. Concrete, measurable if possible.]

### Proposal
[What to do. High level, not implementation steps. State the CMS change and
the web app change separately if both repos are involved. Reference the pattern
to follow (e.g., "same pattern as the BookingGrid").]

### User Stories
[Bulleted list. "As a [user], I want [action] so that [benefit]."]

### Task Breakdown
[Table of technical tasks. Each task has its own section below with the task
template.]

### Open Discussions
[Bulleted list. Decisions still needed. Who needs to answer.]
```

## Task Template

Each task within a PRD follows this structure:

```markdown
### Task [N.M.K]: [Name]

**Context**
[What code exists. Where it lives. What it does today. What needs to change.
Be precise: file paths, function names, line numbers if relevant. An engineer
should be able to start working from this context alone.]

**Acceptance Criteria**
[Bulleted list. Each criterion is testable and specific. Reference exact types,
function names, return values, URL formats. These are technical criteria, not
product criteria -- the PRD covers the product side.]

**Definition of Done**
[When is this task complete? Merged and deployed? Smoke tested on staging?
Verified in production?]
```

## Rules

1. **Explore the code before writing acceptance criteria.** Don't guess at
   function names, file paths, or data shapes. Read them.

2. **One question at a time during PRD scoping.** If a PRD's scope is unclear,
   ask one targeted question, wait for the answer, then ask the next. Don't
   dump a list.

3. **PRDs are product documents with technical grounding.** The Context and
   Discovery sections reference code. The Problem Statement, Hypothesis, and
   User Stories are product language. Both audiences should be able to read the
   PRD.

4. **Tasks are purely technical.** Context references files and functions.
   Acceptance criteria reference types and return values. No product language
   in tasks.

5. **QA-only PRDs are valid.** If a previous epic shipped shared infrastructure
   (like a waivers fix), a subsequent epic's PRD for that feature may be
   "verify it works for this product type." State clearly: "No code changes.
   QA verification only."

6. **Sibling consistency.** If multiple epics have parallel PRDs (e.g., each
   has a "waivers" PRD), they should read like siblings. Same depth, same
   structure. A reader comparing them should see the pattern immediately.

7. **Don't add scope.** If the epic says "activate payment for Public Classes,"
   the PRD doesn't add "also redesign the card layout." If you think scope is
   missing, ask.

## Output

Append PRDs and tasks to the epic document at `$epic-file`, under a `# PRDs`
section.

Also write the tasks to `docs/epics/tasks.md`, organized by epic and PRD, so
all tasks across epics are in one place.

After writing, summarize what you created and ask: "Does this look right?
Anything to change?"
