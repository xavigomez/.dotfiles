---
name: pr-review
description: >
  Adversarial multi-agent review of the current branch's changes vs the base branch.
  Fans out one subagent per review angle by default (solo only on explicit request),
  verifies findings, and returns a short bullet list of MAIN blocking issues only —
  no nitpicks, no praise. After the list, drills into each issue one at a time,
  waiting for the user between each.
---

# PR Review

Adversarial, multi-agent review of the current branch's changes. You are the orchestrator:
subagents find, you verify and judge.

## Gather context

1. Resolve the real base: the open PR's base branch if one exists (`gh pr view`); else the
   nearer of `git merge-base HEAD origin/develop` / `origin/main`; else ask. Never assume main.
2. Diff against that base. List changed files. Read the full changed files yourself — you
   will be verifying claims against them.
3. If a ticket is linked (Linear, PR body), fetch its acceptance criteria and any documented
   waivers (deliberate divergences are not findings).
4. Ask the user for known-and-tracked issues to exclude before launching anything.

## Review: fan out by default

Launch one subagent per angle, in parallel, on a cheaper model than your own (Opus unless
told otherwise). You write each brief; you never delegate the judging. Review inline WITHOUT
agents only when the user explicitly says so ("solo", "no agents", "inline") or the diff is
trivial (< ~50 lines) — say which mode you're using either way.

The six standard angles (add or drop per the user's ask):

1. **Security** — trust boundaries, credentials in logs/headers/caches, cookie attributes,
   injection, cache poisoning. Safety is never traded for simplicity.
2. **Correctness vs AC** — verdict table, one AC at a time, with quoted evidence.
3. **Code quality** — the ponytail ladder per symbol: does it need to exist → already in the
   codebase → stdlib → platform → installed dep → one line → minimum that works. Dead code
   claims require the grep that came up empty.
4. **Architecture** — judge ONLY what the diff introduces or touches, against the repo's own
   docs (architecture/debt/ADRs) if present; verify debt-doc edits for honesty.
5. **Bugs** — concrete failure scenarios, verified mechanically.
6. **Tests** — missing pins for load-bearing behavior, padded tests, false pins (a test that
   never reaches the guard it claims to cover). Run the suite.

Every brief includes: repo, branch, base SHA, changed-file list; the hunt list for its angle;
the exclusion list and waivers; and this output contract — per finding: `file:line` · claim ·
quoted evidence · concrete failure scenario · minimal fix · severity · confidence, plus a
"verified clean" list (negative results are findings too).

**Evidence rule (agents and you):** a claim about a dependency or framework's behavior must
cite its installed source (`node_modules`, a sibling repo checked out locally) or a live
repro. Training-memory folklore is not evidence.

## Judge (you, not the agents)

- Dedupe across angles; angles converge on real issues — that's signal, not repetition.
- Verify each surviving finding against the code yourself. Never relay an agent's severity:
  re-adjudicate at the layer where the behavior manifests.
- Ponytail filter: every finding carries its minimal fix (delete it / use the existing thing /
  one line / smallest change). A finding whose fix is heavier than the disease is dropped —
  except security, correctness at trust boundaries, and data loss, which are never dropped
  for cost.
- The bar: would a staff engineer block-or-fix before merge? No nitpicks, praise, style
  preferences without a written convention, hypotheticals, or pre-existing issues the diff
  doesn't worsen.

## Output

### Step 1: AC table (when a ticket exists), then bullets only

Per AC: met / partial / not met, with evidence. Then ONLY a short bullet list of the main
issues, most severe first, one line each, as Conventional Comments — `issue`/`todo`/`question`,
always `(blocking)` (the filter only lets blocking through). No file paths in bullets (they
become inline PR comments, already anchored). No preamble, no summary.

End with exactly: `Say "go" and I'll walk through them one at a time.`

If nothing survived, say so in one sentence and stop.

### Step 2: Drilldown, one at a time

On "go"/"next": one issue per message — the Conventional Comments header, the single
`path/to/file.ext:line` reference on its own line, then a few sentences: what's wrong, why it
matters, the concrete fix. Stop and wait.

Drilldown contract:

- "next"/"go" advances the EXPLANATION. It never applies anything.
- Applying a fix requires explicit per-item consent ("apply it", "do it"). Never batch-apply.
- Re-explain in plain language on request; repost earlier items instead of making the user
  scroll back.
- After each applied fix: format, lint, typecheck, affected tests — before moving on.
