---
name: pr-document
description: >
  Generate a pull request description for the current branch's changes vs the base branch,
  following the repo's .github/PULL_REQUEST_TEMPLATE.md when present. Also proposes a
  conventional commit title suitable as the PR merge name.
---

# PR Document

Draft a complete PR description for the current branch.

## Gather context

1. Detect current branch and base branch:

```!
git rev-parse --abbrev-ref HEAD
```

```!
git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p' || echo main
```

2. Read the PR diff and list changed files (try `main` first, fall back to `master`):

```!
git diff main...HEAD 2>/dev/null || git diff master...HEAD
```

```!
git diff main...HEAD --name-only 2>/dev/null || git diff master...HEAD --name-only
```

3. Read the commit log on this branch for narrative cues:

```!
git log --oneline main..HEAD 2>/dev/null || git log --oneline master..HEAD
```

4. Read `.github/PULL_REQUEST_TEMPLATE.md` if it exists. If not, **use the Playtomic template below verbatim** — do not ask the user for it, do not invent a different structure.

5. Read the full content of changed files when the diff alone leaves intent unclear. Look at recent commits on the base branch for naming and tone conventions.

## Playtomic PR template

When the repo has no template file, fill this exactly:

````markdown
## Description

> Linear ticket: [`___`](https://linear.app/playtomic/issue/___/)
> Team: `___`

## 🧾 Changelog

- <!-- Provide a high-level bullet-point summary of the changes -->

## 💭 Motivation

<!-- Include relevant motivation and context. Not needed when obvious.  -->

## 🖥 Screenshots

| Before | After |
| ------ | ----- |
| image  | image |

<!---
Optional sections:
===============
## 📝 Todo
## 🚫 Blockers
## 🧾 Review
## 📖 Learnings
## 🌎 Globals
## 👨‍💻 Tech
## 🔎 Testing / QA
## 🤦‍♂️ Whoopsie
-->
````

## Extract metadata

- **Ticket ID** — parse the branch name for a `TEAM-123` pattern (e.g. `feature/web-121-...` → `WEB-121`, `refactor/web-112-...` → `WEB-112`). The ID always exists in the branch name for Playtomic web work; only fall back to `___` if the branch genuinely has no ticket prefix.
- **Team** — for `playtomic-web-app` and `playtomic-web-cms` the team is **always `Web`**. Don't ask, don't infer from paths — just write `Web`. For other repos, ask the user.
- **Ticket URL** — `https://linear.app/playtomic/issue/<ID>/` (no trailing slug needed).

## Draft the description

Fill the template:

- **Description** — ticket link + team. Use the resolved `WEB-XXX` ID and `Web` team.
- **🧾 Changelog** — bullet points of what actually changed, from the user's perspective. One bullet per meaningful unit of work. No implementation minutiae.
- **💭 Motivation** — why the change exists: the problem, the constraint, the outcome. Skip (delete the section's body, leave the heading + comment) only when the title makes intent self-evident.
- **🖥 Screenshots** — **always leave the `| image | image |` placeholder as-is**. The user provides screenshots themselves; never offer to capture or describe them.
- **Optional sections** — keep the HTML comment block at the bottom verbatim. Do not add a `## 🔎 Testing / QA` section unless there's something genuinely non-obvious to test (rare). If you do add it, it goes inline above the comment block.

Keep prose tight. Prefer verbs over adjectives. No marketing voice.

## Propose a merge commit name

Emit a single conventional-commit title that captures the whole PR. This is what lands on the base branch when the PR is squash-merged.

Rules:
- Format: `<type>(<scope>): <subject>` or `<type>: <subject>` when scope is ambiguous.
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `build`, `ci`, `style`.
- Match the repo's historical style — check recent merges on the base branch.
- Subject: imperative mood, lowercase start, no trailing period, ≤ 70 chars.
- No em dashes. No `Co-Authored-By` trailers.
- Scope should reflect the primary area touched (package name, app name, or feature), not every directory.

## Output format

Print two fenced blocks so the user can copy each independently.

**First** — the proposed merge title on its own line inside a plain fence:

````
feat(ui): add whatever
````

**Second** — the PR body as raw markdown inside a fenced block that uses more backticks than any fence inside the body (so inner code blocks survive copy-paste). Typically four backticks is enough.

No commentary around the blocks unless the user asks for justification. If the ticket ID or team could not be resolved, add a single line above the blocks noting which placeholder the user needs to fill in.
