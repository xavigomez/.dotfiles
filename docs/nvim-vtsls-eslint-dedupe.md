# Neovim: vtsls/eslint unused-variable dedupe

## The problem

In TypeScript buffers, unused variables were reported twice as virtual text:

```text
● eslint: 'foo' is assigned a value but never used.   (Warning)
● ts: 'foo' is declared but its value is never read.  (Hint)
```

Two independent tools implement the same "unused variable" check and neither
knows about the other:

- **vtsls** (the TS server used by LazyVim's `lang.typescript` extra) publishes
  tsserver's "unnecessary" suggestions as Hint-severity diagnostics (code 6133
  and friends).
- **eslint** (via the `linting.eslint` extra) reports the same variable through
  `@typescript-eslint/no-unused-vars`.

Every project involved has eslint configured, so the duplicate showed up
everywhere.

## Why not fix it per project?

Turning off tsserver's `noUnusedLocals` in each tsconfig only works where the
flag is set, and the hint shows up regardless of it. A dotfiles-level fix
applies to all projects at once.

## Why not disable vtsls when eslint is present?

Eslint only lints. vtsls provides completions, go-to-definition, rename, hover
types, imports — losing all of that in eslint projects would trade one cosmetic
duplication for real functionality.

## The fix

`nvim/.config/nvim/lua/plugins/lsp.lua` overrides vtsls's
`textDocument/publishDiagnostics` handler:

- If an **eslint client is attached to the same buffer**, drop tsserver's
  unused-variable diagnostic codes (`6133`, `6192`, `6196`, `6198`) before
  passing the batch to the default handler. Eslint's report is the one kept,
  since it is the more configurable of the two (`varsIgnorePattern: '^_'`,
  `ignoreRestSiblings`, per-line disables).
- **Otherwise, nothing is filtered** — in a project without eslint, the TS
  hint still shows, so no signal is ever lost.
- All other diagnostics (TS errors, eslint rules, other LSPs) pass through
  untouched.

## Verification

- In a project with eslint: only the eslint `no-unused-vars` warning appears;
  the `ts:` hint is gone; other TS diagnostics still come through.
- Syntax and server attachment checked headlessly (`vtsls` + `eslint` both
  attach without errors).
