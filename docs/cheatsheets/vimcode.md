# vimcode Cheatsheet

Quick reference for [vimcode](https://github.com/oribarilan/vimcode), the OpenCode TUI plugin that adds Vim-style modal editing to the prompt input.

Installed via `opencode/.config/opencode/tui.json`. Pin to a tagged version — OpenCode caches `@latest` forever.

## Configuration

Pass options via the tuple form in `tui.json`:

```json
{
  "plugin": [
    ["vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.3", {
      "updateCheck": true,
      "modeIndicator": "toast",
      "startMode": "insert"
    }]
  ]
}
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `updateCheck` | `boolean` | `true` | Daily GitHub version check on startup (the only network request). |
| `modeIndicator` | `"toast"` \| `"none"` | `"toast"` | How mode switches are shown. `"none"` relies on cursor shape alone. |
| `startMode` | `"insert"` \| `"normal"` | `"insert"` | Which mode OpenCode launches in. |

> `modeToast` and `leader` options existed in older versions but were removed. `modeIndicator` replaces `modeToast`; the leader key is auto-detected from `keybinds.leader`.

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
| `:q` `:quit` `:wq` | Quit OpenCode |
| `:vim` | Toggle vim mode on/off (persisted across restarts) |
| `/` | Jump to message (session timeline) |
| `[` `]` | Scroll conversation half-page up/down |
| `{` `}` | Jump to previous/next message |
| `Enter` (normal) | Submit prompt |
| `Ctrl+Enter` (insert) | Submit prompt |

## Behaviors

- **Overlay passthrough** — when OpenCode shows UI (command palette, `/sessions`, `@` file picker, question/permission prompts), vimcode steps aside and all keys pass through.
- **Leader key** — auto-detected from `keybinds.leader`. In normal/visual, the leader and follow-up pass straight through. In insert, printable leaders (space) type their character; non-printable (`ctrl+x`) pass through.
- **Cursor shape** — block in normal, bar in insert. Works across all terminals (uses `cursorStyle`, not DECSCUSR escapes).
- **System clipboard** — `pbcopy` (macOS), `clip.exe` (Windows), `xclip`/`wl-copy` (Linux). Falls back to an internal register if no clipboard tool is installed.
- **Update checker** — daily GitHub API check, cached via `api.kv`, toast on new version. Disable with `updateCheck: false`.
- **No telemetry** — the GitHub version check is the only network request.

## Known Gaps

- No block visual mode (`Ctrl+V`).
- No text objects (`ciw`, `di"`, `da(`, etc.) — backlog priority #1.
- No persistent mode indicator — toast fades after ~1s. Slot-based indicator is blocked by host JSX resolution limits for git-installed plugins.
- Normal-mode cursor can land past last character after `$` or `A` + Escape.
- `p` always pastes at cursor, not after (vim convention) for character-wise yanks.
- No configurable keymaps yet (`jk` to exit insert, `Y` → `y$`, etc. are on the roadmap).

## Upgrading

Bump the version ref in `opencode/.config/opencode/tui.json` and restart OpenCode. The cache invalidates on tag change.

```json
"plugin": ["vimcode@git+https://github.com/oribarilan/vimcode.git#v0.15.4"]
```

Check for new releases at <https://github.com/oribarilan/vimcode/releases>.
