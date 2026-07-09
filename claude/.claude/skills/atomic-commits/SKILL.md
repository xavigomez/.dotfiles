---
name: atomic-commits
description: Take an accumulated set of changes in the working tree and turn them into a series of atomic, conventional commits where each intermediate state builds clean. Use this whenever the user asks to "split this into commits", "atomic commits", "incremental atomic commits", "commit this work as a series", or anything similar — typically after a long working session where multiple logical changes have piled up in the same working tree. Make sure to use this skill when the user wants the git history to read like a story rather than a single "WIP" dump, even if they don't use the exact words "atomic" or "incremental". Do NOT use this for one-off commits where a single message captures the whole change — this is specifically for cases where the work is a logical sequence (e.g. refactor → feature → polish) that deserves separate commits.
---

# Atomic Commits

Turn a soup of working-tree changes into a clean, story-shaped commit series.

## Why this skill exists

When you accumulate several logical changes in one session, the lazy default is to dump them into one big commit. That commit is hard to review, hard to revert selectively, and tells no story. The opposite extreme — one tiny commit per file edit — is just noise.

The sweet spot is **atomic commits**: each commit is one logical idea, builds independently, and reads well in `git log`. This skill executes that turn-by-turn so you can ship a clean history without losing work along the way.

## Goal

Each commit should:
1. Tell ONE logical story (refactor X, add feature Y, fix bug Z).
2. Build cleanly on its own — type-check, lint, tests pass at every commit.
3. Match the repo's existing message conventions (don't impose a style).

The result is a `git log` that reads like a documentary instead of a "WIP" dump.

## Workflow

### 1. Survey

Run these in parallel (single message, multiple Bash calls):

- `git status` — what's modified, what's new
- `git diff --stat HEAD` — scope at a glance
- `git log --oneline -15` — read the repo's commit message style

Match what's already there. If recent commits use `feat(scope): subject`, use that. If they're plain `fix: ...`, match that. **Don't impose conventional commits if the repo doesn't use them.** Mirror the existing tone — sentence case vs lowercase, imperative vs past tense, scopes vs no scopes.

### 2. Plan

Group the changes into atomic commits. Each commit should be defensible as a standalone unit: "if I revert this commit, the world makes sense at the previous one."

Common groupings:
- A refactor (extract utility, move file, rename) is its own commit
- Each net-new feature is its own commit
- Each bug fix is its own commit
- Visual / UI tweaks can be grouped if they belong to one feature
- Pure formatting / lint fixups are their own commit (so reviewers can skip them)

**Present the plan to the user before executing.** Show:
- Each commit's subject (matching repo style)
- A bullet list of files / changes in scope
- Any heads-up about coupling — e.g. "commit 3 modifies file X, which commit 5 also modifies; commit 3 will need an intermediate state of that file"

Wait for approval. The user might rearrange, merge, or split commits.

### 3. Execute

This is the hard part: the working tree has all final states mixed together, but each commit needs an INTERMEDIATE state. Strategy:

1. **Capture finals.** Read every file you'll modify, so you have its final state in your context. (You'll need it later when rebuilding forward.)
2. **Reset to HEAD.** `git restore <files>` for modified files, `rm <files>` for new files. Verify with `git status` — should be clean.
3. **For each commit, in order:**
   - Write the intermediate state of each file involved in this commit. The intermediate reflects everything from commits 1..N applied, but nothing from N+1 onward.
   - Run type-check / build / lint as appropriate (e.g. `npm run typecheck`, `cargo check`, `pytest`). Every commit must pass.
   - `git add <specific files>` — avoid `git add -A` so the staging stays intentional.
   - `git commit -m "subject"` — single-line subject only.
4. **After the last commit**, the working tree should match what you started with. `git status` clean.

### 4. Verify

- `git status` clean (no leftover untracked files)
- `git log --oneline` shows your story top-down, in order
- Final code matches the pre-reset working tree (you can sanity check with `git diff <pre-reset-sha> HEAD` — should be empty)

## Conventions

- **Single-line subjects.** No body unless the user explicitly asks for one. The subject should stand on its own.
- **No Co-Authored-By trailer.** Don't add it — not for Claude, not for any automated agent.
- **Conventional types** (`feat`, `refactor`, `fix`, `chore`, `docs`, `style`, `test`, `perf`) — but **only if the repo uses them**. If recent commits don't use this style, don't introduce it.
- **Imperative mood**: "add X", not "added X" or "adds X" — but again, match what the repo uses.

## Common gotchas

**File "modified since read" errors after `git restore`.** The Write tool tracks file mtimes. After `git restore` changes a file, you need to `Read` it again before you can `Write` it. (`Edit` for partial changes doesn't have this issue — only full-file `Write`.)

**Typos sneaking into intermediate states.** When manually rebuilding intermediate file states, it's easy to introduce stray characters or whitespace. Type-checking at every commit catches these. **If type-check fails, fix the typo before staging — never commit broken intermediate states.** A single broken intermediate ruins the "every commit builds" guarantee, which is the whole point.

**Coupling across commits.** When commit N and commit N+2 both modify the same file, the intermediate at commit N is *not* the final state. Plan carefully — write the file as it should look *after commit N is applied but before N+1 starts*. This is where having the final state captured in step 1 helps: you can mentally subtract the later changes.

**Repos without a typecheck.** If there's no fast verification step (e.g., dynamic language with no type-check script), at minimum run a lint. If there's truly nothing fast, accept that intermediate verification is skipped — flag this risk to the user before executing.

**Long-lived edits in `Edit` tool memory.** If you `Read` a file early and don't re-read after a `git restore`, subsequent `Edit` calls might use stale line numbers. Re-read after any external file change.

## Example flow

User: "Let's commit all this work as incremental atomic commits."

1. Survey: `git status`, `git diff --stat HEAD`, `git log --oneline -15`. Repo uses conventional commits with scopes (`feat(rankings): …`).
2. Identify 7 logical groups (URL refactor → backlink removal → layout wrap → loading-state polish → status badge → quiet loader → scroll-on-done). Draft titles in repo style. Present plan.
3. User approves.
4. Read all final file states. Reset working tree to HEAD. For each of the 7 commits: write intermediate state, run `npm run typecheck`, `git add <files>`, `git commit -m "<subject>"`.
5. After the last commit: `git status` clean, `git log` shows the 7-commit story, branch is N commits ahead of origin.

End state: branch carries 7 atomic commits, each independently buildable, history reads like a narrative.

## When to skip this skill

- The user asks for a single commit ("commit this", "commit my changes") — just commit.
- The work is genuinely one logical change touching multiple files (e.g. a single rename across the codebase). One commit is correct.
- The user has already split their work via stash/branch and just wants help with the message.
