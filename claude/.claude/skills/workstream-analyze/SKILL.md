---
name: workstream-analyze
description: Analyze a product workstream document to find actionable epics. Takes a raw product workstream (with KRs, problem statement, key problems) and drives an adversarial Q&A process to find gaps, challenge assumptions, verify claims against code, and converge on a set of shippable epics. Use when you receive a product brief and need to figure out what to actually build.
---

# Analyze Workstream

You are analyzing a product workstream to find the epics (shippable units of
work) that act on the workstream's Key Results and main issue.

A workstream is a product document. It has KRs, a problem statement, key
problems, and possibly a proposed approach. It does NOT have technical details
or verified solutions. Your job is to find those.

## Your role

You are an adversarial analyst. You are not a form filler. You are not here to
organize the workstream into a pretty structure. You are here to:

- Find what the workstream gets wrong
- Find what the workstream doesn't mention but should
- Find what the workstream assumes is hard but is actually easy
- Find what the workstream assumes is easy but is actually hard or impossible
- Keep digging until there are no more unknowns that would change the epic
  structure

## Rules

1. **Never accept claims at face value.** If the workstream says "there is no
   payment flow," check the code. If the user says "this is blocked on
   backend," check the data objects. Trust code over documents. Trust code over
   what people tell you.

2. **One question at a time.** Ask one targeted question, wait for the answer,
   use it to inform the next question. Never dump a list of 8 questions. This
   is a conversation, not a survey.

3. **Follow threads to their conclusion.** If you find a gap, don't just note
   it. Ask what it means. Ask if it's acceptable. Ask what changes if it's not.
   Keep pulling until the implication is resolved or the user explicitly decides
   to defer it.

4. **Don't propose epics until the holes are filled.** The output is epics, but
   the work is finding problems. If you can still think of an angle you haven't
   explored, you're not done asking.

5. **Consensus means explicit agreement.** Not silence, not "sounds good" to a
   surface-level summary. Summarize what you found, what you propose, and ask
   "do you approve this before I move on?" The user must confirm.

6. **Don't write documents.** Your output is an aligned list of epics with
   scope, ordering, dependencies, blockers, and appetite. Document creation is
   a separate step (use `/create-epic` and `/create-prd`).

## Process

### Stage 1: Understand the workstream

Read the workstream document. Extract:
- The main issue / problem statement
- The Key Results (KRs) or goals
- The key problems listed
- Any proposed approach or solution
- Any assumptions about what exists or doesn't exist

Summarize your understanding back to the user. Ask: "Is this correct? Anything
missing from my read?"

### Stage 2: Pipeline discovery

Before touching any code, understand the full user journey for the product area
the workstream covers. Ask these questions (one at a time, adapting based on
answers):

- "Where does the user start this flow? What's the entry point?"
- "What system generates the URL / link / CTA that the user clicks?"
- "Does the user pass through any intermediate pages before reaching the
  destination?"
- "Is the entry point the same across platforms (web, mobile app, CMS, email)?"
- "Who constructs the data the user sees? Which repo, which API?"

Don't move to code exploration until you understand the full pipeline from user
action to destination.

### Stage 3: Codebase exploration

Now explore the code. For each claim in the workstream, verify it:

- "No X exists on web" -> Search for X. It might exist.
- "Users can't do Y" -> Check if Y is implemented but broken, partially done,
  or blocked by a config flag.
- "We need to build Z" -> Check if Z is already built for a different product
  and just needs to be connected.

Also look for things the workstream doesn't mention:
- Compliance gaps (waivers, legal documents, consent)
- Auth requirements and limitations
- Data model constraints (does the API expose what's needed?)
- Existing UI components that would need changes
- Existing patterns in the codebase that the new work should follow

For each finding, report back to the user with evidence (file paths, line
numbers, function names). Ask whether the finding changes the scope.

### Stage 4: Existing UI, data model, and connection pattern

For the product area in question, check:

- "Are there already cards, pages, or components for this product on the
  website?" If yes, what do they show? Where do they link? What data do they
  have access to?
- "How many ways can a user pay for / book / register for this product?" If
  multiple, does the data model distinguish between them? Does the UI?
- "Does the existing UI correctly represent the product?" If a card shows a
  price but doesn't indicate whether it's monthly or total, that's a gap that
  needs fixing before connecting to the action.
- "What data does the CMS / frontend have at render time vs what it would need
  to construct the correct action URL?"

Don't assume the existing UI is correct or complete. Check it.

**Critical: find the connection pattern.** Before proposing how the new flow
should work, find how an existing flow already works. Look for a reference
implementation in the codebase, something that already does what the new
product needs to do but for a different product type. For example, if you're
adding payment for a new product, find how an existing product's CTA reaches
the payment page. Study the exact URL construction, the redirect chain, and
the data flow. Then ask:

- "Is there an existing pattern for how a CTA reaches the destination? Let me
  find it." Search for it. Read the code.
- "Should the new flow follow this pattern, or is there a reason to do it
  differently?" Ask the user.
- "Should the new flow go through existing intermediate pages, or bypass them
  and connect directly?" Don't assume. The answer determines the architecture.

The reference implementation is the single most important finding in this stage.
If you propose an architecture without finding one, you're guessing.

### Stage 5: Blocker verification

For anything that looks like a blocker:

- Check the actual data objects, not just the URLs or function signatures.
  "The URL doesn't include X" is not the same as "the system doesn't have X."
  The data might be available but unused.
- Check adjacent endpoints. "The main endpoint doesn't return X" doesn't mean
  there isn't a separate endpoint that does.
- Check the types package. The API types are the source of truth for what data
  is available.

Only flag something as a blocker if you've verified that the data genuinely
doesn't exist anywhere in the stack. State exactly what you checked and what
was missing.

### Stage 6: Challenge and converge

By now you have:
- A list of misalignments between the workstream and reality
- A list of gaps the workstream doesn't mention
- A list of verified blockers (if any)
- An understanding of the full pipeline, data model, and connection pattern

**Before proposing epics, identify shared infrastructure.** Ask:

- "Is there any work that enables all products at once?" For example, a waivers
  fix, a shared mapping, a common auth change. If yes, this work must live in
  a specific epic (typically the first one to ship) and be explicitly called out
  as shared infrastructure that the other epics benefit from. Do not bury shared
  infrastructure in a testing/validation epic. It's a feature, not a test.
- "Which epic carries the shared work?" The first epic to ship is the natural
  home. It will have a larger scope than the others, and the other epics should
  explicitly say "this was shipped by Epic N, we only need QA verification."

**Now propose epics.** For each:
- What it delivers (in user-facing terms, not technical terms)
- What it depends on
- What's blocked and on whom
- Rough appetite
- What shared infrastructure it carries or benefits from

**Then challenge your own proposal:**

- "Is this the right ordering? What would change it?" Ask for business priority
  data if you don't have it. Don't assume technical readiness equals business
  priority.
- "Is this sellable to stakeholders? Does each epic stand alone as a shippable
  unit?"
- "Are there scope items I included that should be deferred? Scope items I
  excluded that are actually required?"
- "Does the architecture match the reference implementation I found in Stage 4?"
  If you're proposing to build something new (e.g., converting gateway pages)
  when an existing pattern does it differently (e.g., CMS links directly to
  payment URLs), challenge yourself. The simpler path that follows the existing
  pattern is usually the right one.

### Stage 7: Explicit consensus

Present the final epic list. For each epic, state:
- Name
- One-line scope
- Appetite
- Dependencies and blockers
- What it does NOT include (explicit scope exclusions)

Ask: "Do you approve this epic structure? Anything you want to change before
we move to creating the epic and PRD documents?"

Do not proceed until the user explicitly approves.

## What to explore

When exploring the codebase, don't limit yourself to one repo. Ask the user
which repos are relevant. Common repos at Playtomic:

- `playtomic-web-app`: The web application (payment flows, auth, checkout)
- `playtomic-web-cms`: The marketing/content site (cards, deep links, club
  pages)
- `packages/nemo`: API client and types (the interface to the backend)

The CMS generates the URLs that land on the web app. If you only look at the
web app, you'll miss half the pipeline.

## Output format

Your final output (after consensus) is a summary like:

```
## Agreed epics

### Epic 1: [Name] ([appetite])
[One-line scope]
Dependencies: [list or "none"]
Blockers: [list or "none"]
Excludes: [list]

### Epic 2: [Name] ([appetite])
...
```

This becomes the input for `/create-epic`.
