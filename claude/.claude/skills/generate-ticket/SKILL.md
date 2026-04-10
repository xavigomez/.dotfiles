---
name: generate-ticket
description: >
  Generate a Linear-ready ticket from the current conversation context.
  Produces a title, context section, and numbered acceptance criteria.
---

# Generate Ticket

Generate a Linear-ready ticket from what has been discussed in the current conversation.

## Process

1. Review the conversation to identify the problem, background, and requirements.
2. Do not ask clarifying questions -- use your best judgement.

## Output format

Wrap the entire output in a markdown code block so the user can copy-paste it directly.

### Title

A short conventional-commit-style title (e.g. `fix: resolve duplicate React keys for private class cards`).

### ## Context

1-3 paragraphs explaining:
- The problem or need
- What prompted it (e.g. a review finding, a bug report, a refactor)
- Relevant technical details (file paths, code references)

### ## Acceptance criteria

A numbered list of concrete, verifiable outcomes. Describe what "done" looks like, not how to implement it.

## What NOT to include

- Implementation details or specific technical approaches in the AC
- Fluff, filler, or restating the obvious
- Estimates or priority suggestions
