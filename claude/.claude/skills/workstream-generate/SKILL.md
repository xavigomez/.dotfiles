---
name: workstream-generate
description: Orchestrate the full workstream-to-documents pipeline. Takes a product workstream and drives the complete process from analysis through epic and PRD creation. Runs /workstream-analyze first, then /epic-create for each agreed epic, then /prd-create for each epic. Asks for explicit approval at each phase transition. Use when you want the full end-to-end flow.
---

# Workstream Generate

You are orchestrating the full pipeline from a raw product workstream to
finished epic and PRD documents.

## The pipeline

```
Workstream document
  --> /workstream-analyze (Q&A until epics agreed)
    --> /epic-create (one document per epic)
      --> /prd-create (PRDs + tasks per epic)
        --> Final review
```

## How to run it

### Phase 1: Analyze

Follow the instructions in the `/workstream-analyze` skill:

1. Read the workstream document.
2. Explore the codebase to verify claims.
3. Ask questions one at a time until gaps are filled.
4. Propose epics.
5. Get explicit approval on the epic list.

**Gate:** Do not proceed to Phase 2 until the user explicitly approves the epic
list. Ask: "Epic list approved. Ready to start creating the epic documents?"

### Phase 2: Create epics

For each agreed epic, follow the instructions in the `/epic-create` skill:

1. Explore the codebase for the specific product area.
2. Write the epic document.
3. Ask for confirmation before moving to the next epic.

Process epics in the agreed order (first epic first). After each epic document
is written, ask: "Does this epic look right? Ready for the next one?"

**Gate:** Do not proceed to Phase 3 until all epic documents are written and
approved. Ask: "All epics created. Ready to start breaking them into PRDs?"

### Phase 3: Create PRDs and tasks

For each epic, follow the instructions in the `/prd-create` skill:

1. Read the epic document.
2. Propose a PRD breakdown.
3. Ask questions until each PRD's scope is clear.
4. Write PRDs with technical tasks.
5. Ask for confirmation before moving to the next epic's PRDs.

Process epics in order. After each epic's PRDs are written, ask: "PRDs for
[epic name] done. Ready for the next epic?"

**Gate:** Do not proceed to Phase 4 until all PRDs are written and approved.

### Phase 4: Final review

Present a summary of everything created:

```
## Summary

### Epics
- Epic 1: [Name] ([appetite]) - [file path]
  - PRD 1.1: [Name]
  - PRD 1.2: [Name]
  - [N] tasks
- Epic 2: ...

### Total appetite: [sum]

### Open items
- [Any unresolved discussions across all epics]
- [Any blockers that need external resolution]
- [Any backend confirmations still needed]

### Files created
- docs/epics/epic-1-[slug].md
- docs/epics/epic-2-[slug].md
- ...
- docs/epics/tasks.md
```

Ask: "Everything looks good? Any final changes?"

## Rules

1. **Phase gates are mandatory.** Never skip ahead. Each phase requires explicit
   user approval before the next one starts.

2. **Context carries forward.** Findings from Phase 1 inform Phase 2. Details
   from Phase 2 inform Phase 3. Don't re-explore code you already read.

3. **Sibling consistency across epics.** If you're creating multiple epics for
   similar products (e.g., three Academy product types), the documents should
   read like siblings. Same sections, same depth, same tone.

4. **One conversation.** The entire pipeline runs in a single conversation. If
   the user needs to stop and resume later, summarize where you are and what's
   been decided so far.

5. **Read the dedicated skill files.** At each phase, follow the detailed
   instructions in the corresponding skill file. This orchestrator defines the
   flow; the dedicated skills define the work.

## Repos to explore

At Playtomic, the full pipeline typically spans multiple repos:

- `playtomic-web-app`: Web application (payment flows, auth, checkout)
- `playtomic-web-cms`: Marketing/content site (cards, deep links, club pages)
- `packages/nemo`: API client and types (interface to the backend)

Ask the user which repos are relevant before starting codebase exploration.
Don't assume it's only one repo.
