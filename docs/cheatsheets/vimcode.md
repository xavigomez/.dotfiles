# vimcode Cheatsheet

Quick reference for [vimcode](https://github.com/oribarilan/vimcode), the OpenCode TUI plugin that adds Vim-style modal editing to the prompt input.

Installed via `opencode/.config/opencode/cli.json`, pinned to `v0.19.2`.
This release's OpenCode V2 support is experimental; use a tagged ref for reproducible installs.

## Configuration

Edit the existing Vimcode entry in `cli.json`, passing `options` beside `package`.
Keep the separate `./herdr-opencode` entry used for Herdr reporting:

```json
{
  "plugins": [
    {
      "package": "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.19.2",
      "options": {
        "updateCheck": true,
        "modeIndicator": "toast",
        "startMode": "insert"
      }
    },
    "./herdr-opencode"
  ]
}
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `updateCheck` | `boolean` | `true` | Daily GitHub version check on startup (the only network request). |
| `modeIndicator` | `"toast"` \| `"none"` | `"toast"` | How mode switches are shown. `"none"` relies on cursor shape alone. |
| `startMode` | `"insert"` \| `"normal"` | `"insert"` | Which mode OpenCode launches in. |
| `experimentalV2Leader` | `string` \| `string[]` \| `false` | `"ctrl+x"` | Must match the host's leader; use `false` if disabled. |

The V2 adapter cannot auto-detect `keybinds.leader`. The default `ctrl+x`
needs no extra option; if you change the host leader, also set
`options.experimentalV2Leader` to match.

## Modes

- **Insert mode** — typing works normally. `Enter` inserts a newline, `Ctrl+Enter` submits.
- **Normal mode** — keys are vim commands. Unrecognized keys are swallowed. `Enter` submits.
- **Visual mode** — selection extends with motions; operators act on the selection.
- **One-shot normal** (`Ctrl+O` from insert) — run one normal command, return to insert.

`Escape` enters normal mode. First Escape in insert does **not** trigger OpenCode's double-escape interrupt — cancelling a running response takes 3 escapes (one to normal, two for interrupt).

## Motions

All motions take counts: `3j` moves down 3 lines.

| Key | Action |
|-----|--------|
| `h` `j` `k` `l` | Left, down, up, right |
| `w` `b` `e` | Word forward, backward, end of word |
| `0` `^` | Line start |
| `$` | Line end |
| `gg` | Buffer start |
| `G` | Buffer end |
| `j`/`k` (empty input) | Cycle prompt history |

## Operators

`d` (delete), `c` (change), and `y` (yank) combine with motions. Counts work on both operator and motion: `2dd` deletes 2 lines, `d3w` deletes 3 words.

| Combo | Action |
|-------|--------|
| `dd` `cc` `yy` | Whole line |
| `D` `C` | To end of line |
| `dw` `cw` `yw` | To next word |
| `db` `cb` `yb` | To previous word |
| `de` `ce` `ye` | To end of word |
| `d$` `c$` `y$` | To end of line |
| `d0` `c0` `y0` | To start of line |
| `d^` `c^` `y^` | To start of line |
| `dh` `ch` `yh` | Character left |
| `dl` `cl` `yl` | Character right |
| `dj` `cj` `yj` | Current + line below |
| `dk` `ck` `yk` | Current + line above |
| `dG` `cG` `yG` | To end of buffer |

## Text Objects

Combine with `d`, `c`, `y`, or visual selection: `diw`, `ci"`, `da(`, `viw`.

| Object | Selects |
|--------|---------|
| `iw` / `aw` | Word / word plus surrounding whitespace |
| `i"`, `i'`, `` i` `` | Inside matching quotes; `a` includes the quotes |
| `i(`, `i{`, `i[`, `i<` | Inside brackets; `a` includes the delimiters |
| `iq` / `aq` | Nearest quote of any type |
| `ib` / `ab` | Nearest bracket of any type, not Vim's parentheses-only `ib` |

## Insert Entries

| Key | Action |
|-----|--------|
| `i` | Insert at cursor |
| `a` | Insert after cursor |
| `A` | Insert at end of line |
| `o` | Open line below |
| `O` | Open line above |
| `Ctrl+O` | One-shot normal mode |

## Visual Mode

| Key | Action |
|-----|--------|
| `v` | Character-wise visual |
| `V` | Line-wise visual (select current line) |
| `d` / `x` | Delete selection |
| `c` | Delete selection, enter insert |
| `y` | Yank selection |
| `Escape` / `v` | Exit visual |

All normal-mode motions extend the selection, with counts.

## Other Keys

| Key | Action |
|-----|--------|
| `r{char}` | Replace char under cursor (supports counts: `3ra`) |
| `x` | Delete character |
| `X` | Backspace |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `p` | Paste from yank register |
| `J` | Join current line with next |
| `:` | Command palette |
| `:w` `:write` | Submit prompt |
| `:q` `:quit` `:wq` | Quit OpenCode |
| `:vim` | Toggle vim mode on/off (persisted across restarts) |
| `/` | Jump to message (session timeline) |
| `[` `]` | Scroll conversation half-page up/down |
| `{` `}` | Jump to previous/next message |
| `Enter` (normal) | Submit prompt |
| `Ctrl+Enter` (insert) | Submit prompt |

## Behaviors

- **Overlay passthrough** — when OpenCode shows UI (command palette, `/sessions`, `@` file picker, question/permission prompts), vimcode steps aside and all keys pass through.
- **Leader key** — `experimentalV2Leader` must match `keybinds.leader`. In normal/visual, the leader and follow-up pass straight through. In insert, printable leaders (space) type their character; non-printable (`ctrl+x`) pass through.
- **Question answers** — free-text answers have their own Vim editing state. Enter/Tab retain OpenCode's native form behavior; question choices and permissions remain host-controlled.
- **Cursor shape** — block in normal, bar in insert. Works across all terminals (uses `cursorStyle`, not DECSCUSR escapes).
- **System clipboard** — `pbcopy` (macOS), `clip.exe` (Windows), `xclip`/`wl-copy` (Linux). Falls back to an internal register if no clipboard tool is installed.
- **Update checker** — daily GitHub API check, cached in plugin storage, toast on new version. Disable with `updateCheck: false`.
- **No telemetry** — the GitHub version check is the only network request.

## Known Gaps

- No block visual mode (`Ctrl+V`).
- No persistent mode indicator — toast fades after ~1s. Slot-based indicator is blocked by host JSX resolution limits for git-installed plugins.
- No configurable keymaps yet (`jk` to exit insert, `Y` → `y$`, etc. are on the roadmap).

## Upgrading

Bump the tagged ref in the existing Vimcode `package` entry in
`opencode/.config/opencode/cli.json`, retaining its options and other plugins.
Saved configuration reloads automatically; use `/reload` to force a reload.
No background-service restart is needed.

```json
{"package": "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.19.2"}
```

Check for new releases at <https://github.com/oribarilan/vimcode/releases>.
