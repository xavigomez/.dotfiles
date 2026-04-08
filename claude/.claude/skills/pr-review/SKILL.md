---
name: pr-review
description: >
  Conduct a staff-level code review of the current branch's changes vs the base branch.
  Produces feedback using conventional comments format (issue, nitpick, question, praise).
  Focuses on bugs, convention violations, performance, and security.
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

2. Read the PR diff:

```!
base=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null) && git diff "$base"...HEAD
```

3. List changed files:

```!
base=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null) && git diff "$base"...HEAD --name-only
```

4. Read the full content of each changed file to understand context beyond the diff.
5. Read any CLAUDE.md files in the repo root and `.claude/` directory to learn project-specific conventions.

## Review process

Analyze the changes with these lenses:

### Correctness
- Logic errors, off-by-one, null/undefined risks
- Missing error handling at system boundaries
- Race conditions or state management issues

### Conventions
- Does the code follow patterns established in CLAUDE.md and the rest of the codebase?
- Import ordering, naming, file organization
- Are existing utilities reused instead of reinvented?

### Performance
- Unnecessary re-renders, missing memoization where it matters
- N+1 queries, unbounded lists, missing pagination
- Bundle size impact (large new dependencies)

### Security
- Injection risks (XSS, SQL, command)
- Sensitive data exposure
- Auth/authz gaps

### What NOT to flag
- Pre-existing issues not introduced by this PR
- Style preferences not backed by project conventions
- Hypothetical future problems ("what if someone later...")

## Output format

Use **conventional comments** for each finding. Valid labels:

- **praise:** -- something done well
- **issue:** -- a problem that should be fixed (add `(blocking)` or `(non-blocking)`)
- **nitpick:** -- trivial preference, take it or leave it
- **question:** -- something you don't understand or want clarified
- **suggestion:** -- an alternative approach worth considering
- **thought:** -- an observation that doesn't require action

Format each comment as:

```
### filename.ext

**label: Short summary**

L12-25: Detailed explanation of the finding.
Include code suggestions when relevant.
```

## Structure the review as

1. **One-line overall impression** (e.g. "Clean change, two issues to address before merge")
2. **Findings** grouped by file, using conventional comments
3. **Pre-existing issues** -- brief list of things noticed but NOT introduced by this PR (keep short)

Wrap the entire review output in a markdown code block so the user can copy-paste it directly.
