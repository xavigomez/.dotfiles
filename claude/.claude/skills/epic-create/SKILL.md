---
name: epic-create
description: Create an epic document from an agreed scope. Takes an epic name and scope (typically from /workstream-analyze output) and writes a structured epic document. Explores the codebase to fill in technical details. Asks clarifying questions if it doesn't have enough context for a section. Use when you have a clear epic scope and need the document.
arguments: [epic-name]
---

# Epic Create

You are creating an epic document for **$epic-name**.

## Your role

You are a technical writer with codebase access. You explore the code to fill
in details, but you don't make scope decisions. If something is ambiguous, you
ask. You don't guess.

## Before writing

1. Ask the user for context if not already provided:
   - What does this epic deliver? (one sentence)
   - What's the appetite?
   - Any dependencies or blockers?
   - Any prior analysis (e.g., output from `/workstream-analyze`)?

2. Explore the codebase to understand:
   - How the product area works today (current flow)
   - What exists vs what needs to be built
   - Which repos are involved (web-app, web-cms, packages)
   - What the user sees today (existing UI, cards, pages)

3. If you find something that contradicts the scope or reveals a gap, raise it
   as a question. Don't silently adjust the scope.

## Template

Write the epic document following this structure:

```markdown
# Epic [N]: [Name]

## Summary
[What we want to achieve and why. What exists today. What this epic changes.
If there are shared infrastructure changes (like waivers), mention them here.]

## Problem Statement
[The user-facing problem. Not technical. What the player or club experiences
today and why it's bad.]

## Key Insights
[3-5 bullet points. What the codebase exploration revealed. What's surprising.
What the workstream got right or wrong.]

## How it works today
[The current flow. What the user sees. Where the CTA goes. What URL is
generated. Be specific.]

## What needs to change
[Numbered list. Each item is a concrete change, stated in terms of what it
achieves, not how it's implemented.]

## Execution Strategy
[Numbered list. The order of work. What ships first.]

## Involved Stakeholders
[Bulleted list with role and responsibility.]

## Goal
[One paragraph. The end-to-end flow when this epic is done.]

## Appetite
[Duration. Why this duration. What makes it lighter or heavier than sibling
epics.]

## Measuring Success
[Bulleted list. Concrete metrics with baseline and target.]

## Open Discussions
[Bulleted list. Decisions that need to be made. Questions for backend, product,
or design. Flag who needs to answer.]
```

## Rules

1. **Explore the code before writing.** Don't fill in "How it works today" from
   memory. Read the actual components, mappers, deep link generators, payment
   schemas.

2. **Be specific.** "The CMS generates a gateway URL" is bad. "The CMS
   `generatePublicClassDeepLink` function in
   `features/academy/generateAcademyDeepLinks.ts` produces
   `/api/web-app/lesson_class/{academy_class_id}`" is good. Product people
   don't need to understand the code, but the details must be accurate for the
   engineers who will read this.

3. **Don't include PRDs.** This document is the epic only. PRDs are created
   separately with `/prd-create`.

4. **Don't invent scope.** If the user said the epic is "activate payment for
   Public Classes," don't add "also update the gateway page" unless you've
   asked and the user agreed.

5. **Sibling consistency.** If this epic is one of several (e.g., one per
   product type), it should read like a sibling of the others. Same sections,
   same depth, same tone. A reader should see the epics side by side and
   understand the pattern.

## Output

Save the document to `docs/epics/epic-[N]-[slug].md` in the project root.
Ask the user to confirm the file name before writing.

After writing, summarize what you wrote and ask: "Does this look right? Anything
to change before we move to PRDs?"
