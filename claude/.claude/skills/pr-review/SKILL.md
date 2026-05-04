---
name: pr-review
description: >
  Conduct a staff-level code review of the current branch's changes vs the base branch.
  Returns a short bullet list of MAIN issues only — no nitpicks, no praise, no "non-blocking" caveats.
  After the list, drills into each issue one at a time, waiting for the user between each.
---

# PR Review

Review the code changes on the current branch as a staff-level engineer.

## Gather context

1. Detect the base branch and current branch:

```!
git rev-parse --abbrev-ref HEAD
```

```!
git log --oneline --merges -1 --format=%P HEAD | head -1 || echo "main"
```

2. Read the PR diff (try `main` first, fall back to `master`):

```!
git diff main...HEAD 2>/dev/null || git diff master...HEAD
```

3. List changed files:

```!
git diff main...HEAD --name-only 2>/dev/null || git diff master...HEAD --name-only
```

4. Read the full content of each changed file to understand context beyond the diff.
5. Read any CLAUDE.md files in the repo root and `.claude/` directory to learn project-specific conventions.
6. Read related files the diff touches transitively: helpers/utilities the changed code calls, callers of changed exports, and any skill/rule files referenced by `.claude/skills/`. The goal is to evaluate the change in the context of the system, not in isolation.

## Review process

Be extra thorough. The output is short — that means the analysis behind it has to be deep, not lazy. Skim once for orientation, then go through each changed file deliberately with these lenses:

### Correctness
- Logic errors, off-by-one, null/undefined risks, type-coercion surprises (e.g. `String(null)` becoming `"null"`).
- Missing error handling at system boundaries (network, parse, user input).
- Race conditions, ordering assumptions, double-firing, missed cleanup.
- Comments or docstrings that contradict the code — these mislead future maintainers and count as real issues.

### Architecture & conventions
- Violations of patterns established in CLAUDE.md, project skills (`.claude/skills/*/rules/*.md`), and the rest of the codebase.
- Reinventing utilities that already exist; abstractions added "just in case" with no second caller; layering breaks (e.g. importing client-only code from a server module).
- Public API shape: prop names, exported types, event/action names that will be painful to rename later.

### Performance
- N+1 queries, unbounded lists, missing pagination, blocking I/O on the render path.
- Bundle-size impact: large new dependencies, accidental client-bundling of server-only code.
- Re-render hot paths: missing memoization where it actually matters (not speculative).

### Security
- Injection risks (XSS, SQL, command, prototype pollution).
- Sensitive data exposure: PII, credentials, tokens, payment-card data leaking into logs/analytics/URLs.
- Auth/authz gaps, missing CSRF/SSRF defenses, unsafe redirects, weakened crypto.

### What does NOT make the list
The output is for the **author at the keyboard**, not a thoroughness performance. Filter out:

- **Nitpicks** — naming, comment wording, formatting, "consider renaming the variable", "spell out the acronym".
- **Praise** — what was done well.
- **Style preferences** not backed by a written convention.
- **Hypothetical future problems** ("what if someone later adds a child that…").
- **Pre-existing issues** the PR did not introduce. Mention them only if the PR makes them materially worse.
- **"Non-blocking" caveats, suggestions, questions, thoughts** — if it isn't a real issue worth fixing, drop it. If you find yourself softening a finding with "minor" or "trivial", that's a sign it shouldn't be on the list at all.

The bar: would a staff engineer block-or-fix on this before merge? If no, leave it out.

## Output format

### Step 1: Bullet list only

Output ONLY a short bullet list of the main issues. One line per issue. Each bullet is a short, specific noun phrase that names the problem and points at the file. No labels, no severity tags, no preamble, no closing summary.

Format:

```
- <Short problem statement> — `path/to/file.ext:Lline`
- <Short problem statement> — `path/to/file.ext:Lline`
```

Then end with exactly one line:

```
Say "go" and I'll walk through them one at a time.
```

If there are no real issues, say so in one sentence and stop. Do not pad.

### Step 2: Drilldown (only after the user says go)

When the user signals to continue ("go", "ok", "next", "first one", etc.), discuss issues one at a time:

- Pick the first unaddressed issue from the list.
- Explain it in a few sentences: what's wrong, why it matters, where exactly (file + lines), and a concrete suggested fix or two.
- Stop. Wait for the user to respond — they may want to discuss, push back, ask for an alternative, or move on.
- When they signal continue, move to the next issue.

Do NOT dump all the details up front. Do NOT batch multiple issues into one message during drilldown. The whole point is one-at-a-time so the user can think about each one without a wall of text.
