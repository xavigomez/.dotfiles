# helix Cheatsheet

Quick reference for [helix](https://helix-editor.com) coming from nvim + LazyVim, focused on where the motions differ. Helix takes its editing model from [Kakoune](https://kakoune.org): **selection → action** instead of vim's action → motion.

Config lives in `helix/.config/helix/` (see the README's helix section). The vim → helix rows below were checked by driving a live `hx` 25.07.1, not just the docs. `:tutor` inside `hx` is the built-in hands-on tutorial.

## The model

- A cursor is a 1-character selection. Every motion **replaces** the selection with the text it moved over.
- The action comes second and acts on whatever is selected: `d`, `c`, `y`, `r`, `>`, `~`…
- There is no operator-pending mode, so no `dd`, `cc`, `yy`, `>>`. Select the line first (`x`), then act.
- You see what you are about to change before you change it. That's the trade for typing the keys in the other order.

## Motions select — what that changes

**The cursor sits at the end of the selection.** After `w` from `alpha beta`, the selection is `alpha ` and the cursor is on the space, not on the `b`. The next `w` selects `beta `.

**`v` extends from the anchor, not the cursor.** After `w`, `vgld` deletes `alpha` too, because the anchor is still at the start of `alpha`. Collapse first with `;` when you want to start fresh from the cursor.

**Counts move, they don't grow.** `3w` selects only the 3rd word. To cover 3 words, extend: `v3w`.

**`f` / `t` cross lines.** They search the whole buffer, not just the current line.

**`;` and `,` don't repeat `f`.** Repeat the last `f`/`t`/`[`/`]` motion with `Alt-.`. The new selection runs from the previous match to the next.

| Key | Selection effect |
|-----|------------------|
| `;` | Collapse to a single cursor (at the head) |
| `Alt-;` | Flip: swap cursor and anchor |
| `,` | Keep only the primary selection (multi-cursor) |
| `v` | Toggle select mode: motions extend instead of replace |
| `Esc` | Back to normal mode (leaves the selection in place) |

## vim → helix

### Words and characters

| vim | helix | Note |
|-----|-------|------|
| `dw` | `wd` | Both eat the trailing space |
| `cw` | `ec` | Vim special-cases `cw` to behave like `ce`; helix doesn't, so `wc` would eat the space |
| `d3w` | `v3wd` | `3wd` deletes only the 3rd word |
| `ciw` | `miwc` | Works from anywhere in the word |
| `x` | `d` | Cursor is already a 1-char selection |
| `s` | `c` | Same reason |
| `r{c}` | `r{c}` | Replaces **every** char in the selection: `er x` turns `alpha` into `xxxxx` |
| `~` | `~` | Case-switches the whole selection; `` ` `` lower, `` Alt-` `` upper |

### Lines

| vim | helix | Note |
|-----|-------|------|
| `dd` | `xd` | `x` selects the line, `x` again extends down |
| `3dd` | `3xd` | |
| `yy` | `xy` | |
| `cc` | `x_c` | `_` trims the selection's whitespace, so the indent survives. `xc` works but drops the indent |
| `D` | `t⏎d` | `t` + Enter: till end of line. `vgld` also works from a bare cursor |
| `C` | `t⏎c` | |
| `>>` `<<` | `>` `<` | Single key, acts on all selected lines |
| `J` | `J` | Same |
| `gcc` | `Ctrl-c` | Or `space c`. Toggles comments on the selection |
| `V` | `x` / `X` | `X` snaps an existing selection to whole lines |

### Moving around

| vim | helix | Note |
|-----|-------|------|
| `0` `^` `$` | `gh` `gs` `gl` | `$` is a shell filter in helix and `0` is a count digit |
| `gg` | `gg` | |
| `G` | `ge` | Bare `G` does nothing; `42G` still goes to line 42 |
| `ge` | — | In helix `ge` means **end of file** |
| `%` | `mm` | Match bracket. `%` selects the whole file |
| `zz` `zt` `zb` | `zz` `zt` `zb` | Same. `Z` = sticky view mode |
| `Ctrl-e` `Ctrl-y` | `zj` `zk` | Scroll without moving the cursor |
| `Ctrl-d` `Ctrl-u` | `Ctrl-d` `Ctrl-u` | Same |
| marks `ma` `'a` | `Ctrl-s` | No marks. `Ctrl-s` saves a jump, `Ctrl-o`/`Ctrl-i` walk them, `space j` picks one |

### Text objects and surround

`m` is **match mode**, not marks. Text objects hang off it: `mi` = inside, `ma` = around.

| vim | helix |
|-----|-------|
| `di(` | `mi(d` |
| `da"` | `ma"d` |
| `vip` | `mip` |
| `daf` (treesitter-textobjects) | `maf`: function. Also `t` type, `a` argument, `c` comment, `T` test |
| `]f` `[f` | Same. Also `]t` type, `]a` arg, `]T` test, `]g` git change |
| surround add | `ms"`: wraps the selection: `miwms"` → `"alpha"` |
| surround replace | `mr([`: closest `(` pair becomes `[` |
| surround delete | `md(` |

### Edit, undo, repeat

| vim | helix | Note |
|-----|-------|------|
| `u` / `Ctrl-r` | `u` / `U` | |
| `.` | `.` | **Only replays the last insert** (the `c`/`i`/`a`/`o` plus what you typed) on the current selection. A plain `d` is not repeatable; helix expects multiple selections instead |
| `p` `P` | `p` `P` | After/before the selection |
| — | `R` | Replace the selection with what you yanked |
| `qa` … `q` / `@a` | `"aQ` … `Q` / `"aq` | **Swapped**: `Q` records, `q` plays |

Yank/delete/paste use the system clipboard here (`default-yank-register = "+"`, same as LazyVim's `unnamedplus`). `space y` / `space p` are the explicit clipboard versions.

### Search and replace

| vim | helix | Note |
|-----|-------|------|
| `/foo` | `/foo⏎` | Selects the match |
| `n` `N` | `n` `N` | Selects the next match, replacing the selection. In select mode (`v`) it **adds** the match instead |
| `*` | `miw*n` | Helix `*` only sets the search pattern from the selection; `n` does the jump |
| `:%s/foo/bar/g` | `%sfoo⏎cbar⎋` | Select file → select every `foo` → change them all at once |
| `:s` within a range | select the range, then `sfoo⏎cbar⎋` | `s` searches *inside* the current selections |

### Visual block

| vim | helix |
|-----|-------|
| `Ctrl-v` `jj` `I` | `C` `C` `i` (or `I`): `C` copies the cursor to the next line |

## Keys that mean something else

The muscle-memory traps. Most come from Kakoune.

| Key | vim | helix |
|-----|-----|-------|
| `x` | delete char | select line |
| `s` | substitute char | select regex matches inside the selection |
| `S` | substitute line | split the selection on a regex |
| `;` `,` | repeat `f`/`t` | collapse selection / keep primary |
| `%` | match bracket | select whole file |
| `$` | end of line | pipe through a shell command, keep where it exits 0 |
| `G` | end of file | goto line (needs a count) |
| `ge` | end of previous word | end of file |
| `m` | set mark | match mode (text objects, surround, `mm` bracket) |
| `K` | hover (LazyVim) | keep selections matching a regex. Hover is `space k` |
| `U` | undo line | redo |
| `q` `Q` | record / Ex mode | play / record macro |
| `C` | change to EOL | add cursor on the next line |
| `R` | replace mode | replace with yanked text |
| `Ctrl-c` | interrupt | toggle comment |

## Things vim doesn't have

### Multiple selections

| Key | Action |
|-----|--------|
| `s` | Select every regex match inside the selection (e.g. `%s` = all matches in the file) |
| `S` | Split the selection on a regex |
| `Alt-s` | Split the selection into one per line |
| `C` / `Alt-C` | Copy the cursor to the next / previous line |
| `K` / `Alt-K` | Keep / drop selections matching a regex |
| `&` | Align selections into a column |
| `(` `)` | Rotate which selection is primary |
| `Alt-minus` | Merge all selections into one |
| `,` | Back to just the primary selection |

### Syntax-tree selection (tree-sitter)

| Key | Action |
|-----|--------|
| `Alt-o` / `Alt-i` | Grow / shrink the selection to the parent / child syntax node |
| `Alt-n` / `Alt-p` | Select the next / previous sibling node |
| `Alt-a` | Select all sibling nodes (every argument, every match arm…) |
| `Alt-e` / `Alt-b` | Move to the end / start of the parent node |

In Rust, `Alt-o` repeatedly on an expression walks out: expression → statement → block → fn.

### Shell

| Key | Action |
|-----|--------|
| `\|` | Pipe each selection through a command and replace it with the output |
| `!` / `Alt-!` | Insert a command's output before / after each selection |

### Jump labels

`gw` puts two-letter labels on every visible word; type one to select that word. The closest thing to LazyVim's flash `s`.

## Alt keys

Many of the chords above are `Alt-…`. In Ghostty, Option only acts as Alt when `macos-option-as-alt` is on, and its default turns that on just for the plain US and US International layouts. If `Alt-o` types `ø` instead of growing the selection, set `macos-option-as-alt = left` in `ghostty/config`. That keeps the right Option key for special characters.

## LazyVim → helix

| LazyVim | helix |
|---------|-------|
| `<leader><space>` / `<leader>ff` | `space f` (project root), `space F` (cwd) |
| `<leader>/` | `space /` |
| `<leader>,` | `space b` |
| `<leader>ss` / `<leader>sS` | `space s` / `space S` |
| `<leader>sd` / `<leader>xx` | `space d` (file) / `space D` (workspace) |
| `<leader>ca` | `space a` |
| `<leader>cr` | `space r` |
| `K` | `space k` |
| `gd` `gr` `gi` `gy` | Same |
| `]d` `[d` | Same |
| `s` (flash) | `gw` |
| `<C-h/j/k/l>` splits | `Ctrl-w h/j/k/l`; herdr panes stay on `Ctrl-Alt-h/j/k/l` |
| command palette | `space ?` |
| resume last picker | `space '` |

Rust-specific keymaps from `rustaceanvim.lua`:

| nvim | helix |
|------|-------|
| `<leader>cu` runnables | None. Run `cargo` in a herdr pane |
| `<leader>cD` render diagnostic | `space d`, or the inline diagnostic under the cursor |
| `<leader>ce` explain error | None. `rustc --explain E0xxx` in a pane |
