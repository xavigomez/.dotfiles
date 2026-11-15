# dotfiles

My personal dotfiles managed with GNU Stow.

## Structure

```
~/.dotfiles/
├── zsh/              # Zsh (no framework) + herdr autostart
├── starship/         # Starship prompt config
├── zed/              # Zed editor settings and keybindings
├── ghostty/          # Ghostty terminal emulator config
├── nvim/             # Neovim + LazyVim (extras via lazyvim.json)
├── helix/            # Helix editor, trialed for Rust next to nvim
├── claude/           # Claude Code skills (settings.json stays local, see the herdr section)
├── opencode/         # OpenCode V2 model settings + terminal preferences/plugins
├── herdr/            # herdr agent multiplexer config (active settings only)
├── pi/               # pi coding agent settings (state stays untracked)
├── spotify-player/   # spotify-player TUI config (app.example.toml template)
├── docs/             # Cheatsheets and decision write-ups
├── Herdrfile         # Declarative herdr plugin list (pinned via --ref)
├── Brewfile          # Homebrew packages and casks
├── install.sh        # Bootstrap script
├── lib/              # Bootstrap helpers (OpenCode version check and safe linking)
├── tests/            # Isolated bootstrap/configuration checks
├── macos.sh          # Native window shortcuts, applied by install.sh
├── .gitignore        # Git ignore patterns
└── README.md         # This file
```

## Theming

Two kinds of TUI apps live on this machine, and knowing which is which explains
every color on screen:

**ANSI-slot followers** paint with the terminal's 16 ANSI color slots. Their
palette *is* the terminal theme — one change in Ghostty re-themes all of them:

| App | Config | Follows |
|---|---|---|
| Ghostty (chrome) | `ghostty/config` → `theme = TokyoNight Moon` | — (defines the slots) |
| herdr | `herdr/.config/herdr/config.toml` → `name = "tokyo-night"` | chrome (explicit match) |
| claude code | `~/.claude/settings.json` (local, untracked) → `"theme": "dark-ansi"` | chrome |
| lazygit (bare + in nvim) | snacks `configure = false` (see `nvim/.../plugins/snacks.lua`) | chrome |
| starship | `starship/.config/starship.toml` → ANSI color names only, no hex | chrome |

**Sovereign apps** render their own truecolor palette and ignore ANSI slots:

| App | Palette | Source |
|---|---|---|
| nvim | Tokyoppuccin Storm (Catppuccin-flavored Tokyo Night, bg matched to chrome `#222436`) | `EmmanuelVernet/tokyoppuccin.nvim` via `nvim/.../plugins/tokyoppuccin.lua` |
| helix | built-in `tokyonight_moon` (bg already the chrome's `#222436`) with dimmed diagnostics and inlay hints | `helix/.config/helix/themes/tokyonight_moon_dim.toml` |
| opencode | built-in `tokyonight` | `opencode/.config/opencode/cli.json` |

Notes:

- The master palette is decided in exactly one place: `ghostty/config`'s
  `theme =` line. Everything in the follower table lands on it automatically.
- nvim's colorscheme is the official nvim port of Zed's Tokyoppuccin theme
  (`EmmanuelVernet/tokyoppuccin.nvim`, by the Zed theme's creator). Local
  deviation: editor/float bg overridden to the chrome's `#222436` (via
  `on_colors`/`on_highlights`) so nvim blends into the terminal.
- snacks' lazygit config generation (`configure = true`) was trialed and
  rejected: stock lazygit inheriting chrome keeps one source of truth, and the
  generated theme fought the editor colors.
- If a sovereign app ever needs to match the chrome palette: ghostty ships a
  built-in `TokyoNight Moon` theme, herdr `tokyo-night`, and tokyonight.nvim
  generates configs for most tools (`:TokyoNight` extras).

## macOS window shortcuts

`install.sh` runs the small `macos.sh` script to configure native window
commands instead of Rectangle. Requires macOS 15+ and English menu names.

| Shortcut | Native menu command |
|---|---|
| Ctrl+Option+Return | Window → Fill (maximize, not fullscreen) |
| Ctrl+Option+← | Window → Move & Resize → Left |
| Ctrl+Option+→ | Window → Move & Resize → Right |
| Ctrl+Option+F | Enter/exit native fullscreen (own Space, separate from Fill) |

```sh
./macos.sh  # Reapply after editing the bindings; also run by install.sh
```

The script uses Apple's `defaults -dict-add` to set only these menu shortcuts,
preserving unrelated preferences. They survive reboots; no daemon, startup
hook, plist symlink, or Accessibility permission is needed. Reopen affected
apps after changing bindings. Exit fullscreen before using desktop halves.

To inspect, change or remove individual bindings, use **System Settings →
Keyboard → Keyboard Shortcuts → App Shortcuts → All Applications**.

Rectangle is no longer in the Brewfile. An existing copy is not automatically
uninstalled: quit it, then remove the Homebrew cask once if desired:

```sh
brew uninstall --cask rectangle
```

Do not leave it running: its default Ctrl+Option+J/K bindings conflict with
Herdr navigation, and Return/arrows conflict with the native window controls.

## nvim

LazyVim, with every deviation from stock living in `nvim/.config/nvim/` and
commented with its rationale. Two rules keep the layer small:

1. **Language support goes through extras** (`lazyvim.json`, managed with
   `:LazyExtras`) — never hand-rolled lspconfig.
2. **`lua/plugins/` is only for what no extra covers**, plus overrides of
   plugins LazyVim already ships.

### Extras enabled (`lazyvim.json`)

`formatting.prettier` · `lang.astro` · `lang.json` · `lang.rust` ·
`lang.tailwind` · `lang.typescript` · `linting.eslint`

Everything those drag in (vtsls, eslint-lsp, rustaceanvim, crates.nvim,
SchemaStore, conform, nvim-lint, …) is stock — only the deltas below are ours.

### Plugins LazyVim doesn't ship

| Plugin | Spec | What it does |
|---|---|---|
| `EmmanuelVernet/tokyoppuccin.nvim` | `plugins/tokyoppuccin.lua` | The colorscheme (see Theming). Eager at `priority = 1000`; `on_colors`/`on_highlights` force bg `#222436` on the editor, floats and neo-tree so nvim blends into the terminal chrome. |
| `laytan/cloak.nvim` | `plugins/cloak.lua` | Masks `=` values in `.env*`, `*.env` and `.dev.vars` buffers. Loads on `BufReadPre`/`BufNewFile` (must beat `BufEnter`), `cloak_on_leave = true`, mask keeps the real value's width. |

### Overrides of plugins LazyVim does ship

| Plugin | Spec | Delta |
|---|---|---|
| `gitsigns.nvim` | `plugins/gitsigns.lua` | Inline blame on by default — 300 ms delay, `<author>, <relative time>` format. |
| `snacks.nvim` | `plugins/snacks.lua` | ① lazygit `configure = false` so stock lazygit inherits terminal chrome (see Theming), with the `rounded` border restored that snacks drops; ② file and explorer pickers show hidden **and** ignored files, excluding `node_modules` and `.git`. Window/terminal navigation uses LazyVim defaults. |
| `nvim-lspconfig` | `plugins/lsp.lua` | `cssls` and `emmet_language_server` (LazyVim still ships no `lang.css` extra as of v16); plus a `vtsls` `publishDiagnostics` handler that drops TS unused-symbol hints (6133/6192/6196/6198) when eslint is attached to the buffer, so the same unused variable isn't reported twice — write-up in `docs/nvim-vtsls-eslint-dedupe.md`. |
| `nvim-treesitter` | `plugins/lsp.lua` | Parsers no extra covers: `scss`, `jsonc`. |
| `rustaceanvim` | `plugins/rustaceanvim.lua` | Buffer-local `<leader>cu` → `:RustLsp runnables`, `<leader>cD` → `:RustLsp renderDiagnostic` (the full cargo-style error instead of split-up virtual text), `<leader>ce` → `:RustLsp explainError`, chained onto the extra's own `on_attach` instead of replacing it. |
| `LazyVim/LazyVim` | `plugins/tokyoppuccin.lua` | `colorscheme = "tokyoppuccin"`. |

### Config (`lua/config/`)

- **Registers never touch disk** (`options.lua`): `shada` is
  `'100,<0,s10,h,r/tmp/,r/private/` — `<0` keeps yanked text (tokens, `.env`
  contents) out of the shada file, and the `r` flags keep marks for temp paths
  out of it too. Same posture as cloak.nvim above and as the no-`stow --adopt`
  rule below.
- **`softtabstop = 2`** (`options.lua`): LazyVim sets `shiftwidth`/`tabstop` but
  leaves `softtabstop` at Neovim's `0`, so `<Tab>`/`<BS>` move by 2 as well.
- **Visual `p` doesn't clobber the paste register** (`keymaps.lua`): the
  standard `"_dP` idiom, so pasting over a selection repeatedly keeps working.
- **Window navigation stays stock**: LazyVim's `<C-hjkl>` moves editor splits
  in normal mode and inline Snacks terminals. Pickers and floating terminals
  keep their normal controls; there is no Herdr edge handoff or custom adapter.
- **No `autocmds.lua`**: the starter ships one; we have none, so LazyVim's
  stock autocmds run unmodified.
- **`lazy.lua` is the LazyVim starter template with exactly three edits**:
  `defaults.lazy = true` (custom plugins lazy-load too, instead of eager-loading
  and making every `event = "LazyFile"` a no-op), no `version` key at all (so
  lazy.nvim resolves tagged releases rather than git HEAD), and
  `install.colorscheme = { "tokyoppuccin", "habamax" }` (starter: tokyonight) —
  that last one only paints the bootstrap install on a fresh machine; the real
  colorscheme is set in `plugins/tokyoppuccin.lua`. Everything else, including
  the `disabled_plugins` list, is stock.
- **`.stylua.toml`**: 2-space indent, 120-column width, so `stylua` output
  matches what's committed.
- **`lazy-lock.json` is committed**, so a new machine gets the same plugin
  commits rather than whatever is current.

### Keymaps added

| Key | Mode | Action |
|---|---|---|
| `p` | x | Paste over selection without clobbering the register |
| `<leader>uk` / `<leader>uK` | n | `:CloakToggle` / `:CloakPreviewLine` |
| `<leader>uB` | n | Toggle gitsigns inline blame |
| `<leader>cu` | n (rust buffers) | `:RustLsp runnables` |
| `<leader>cD` | n (rust buffers) | `:RustLsp renderDiagnostic` — full cargo-style error |
| `<leader>ce` | n (rust buffers) | `:RustLsp explainError` |

`<leader>u*` is LazyVim's ui/toggle group, so the new toggles show up in the
which-key list next to the stock ones.

### Tried, then returned to canon

Deviations that existed and were removed, so they don't get re-litigated:

| Reverted | Commit | Why it went back to stock |
|---|---|---|
| `emmet-vim` | `1ceb912` | Replaced by `emmet_language_server`, which already lists astro/tsx/jsx/svelte/vue in its default filetypes. Cost: the `<C-y>,` chord — completions come through blink now. |
| `obsidian.nvim` + `telescope.nvim` | `fe0e39e` | obsidian v3.9.0 registers completion through nvim-cmp only, so `[[` never worked under blink.cmp; telescope existed solely as its dependency and was eager-loaded on every startup. Vault at `~/.obsidian` untouched; `<leader>st` uses `Snacks.picker`. |
| Hand-rolled catppuccin colorscheme | `7b6d594`, then `9ce69c8` | The spec never actually applied (LazyVim ships catppuccin `lazy = true`, so its `config` never ran and tokyonight-moon was live the whole time). Superseded by the official `tokyoppuccin.nvim`. |
| snacks lazygit theme generation | `781ec43` → `7b6d594` | `configure = true` fought the editor colors; stock lazygit inheriting terminal chrome keeps one source of truth. See Theming. |
| `defaults.lazy = false` | `46ebeb6` | Eager-loading every custom plugin defeats LazyVim's architecture and makes each `event = "LazyFile"` a no-op. A plugin that misbehaves lazy-loaded gets a per-plugin fix instead. |
| `require("config.keymaps")` inside `lazy.lua` | `774d647` | It loaded user keymaps during startup while LazyVim loads its own on `VeryLazy`, inverting the order so LazyVim's defaults silently won every collision (reproduced with `<C-h>`). |
| `number`, `relativenumber`, `expandtab`, `shiftwidth`, `tabstop` in `options.lua` | `5d51794` | All already LazyVim defaults — restating them hid which options were genuine deviations. |

## helix

Second editor, trialed for Rust next to nvim. `config.toml` and
`languages.toml` keep deviations from defaults only. Motions and keys
against vim/LazyVim: `docs/cheatsheets/helix.md`.

- **Rust needs no plugin**: helix finds `rust-analyzer` on `PATH` (the
  rustup shim from `.zshrc`, components from `install.sh`) and runs rustfmt
  on save by default. `languages.toml` switches the save-time check to
  clippy — more than nvim gets, since LazyVim's rust extra only enables
  `checkOnSave` (plain `cargo check`). `hx --health rust` verifies it; the
  `lldb-dap` ✘ there is the debugger, which isn't set up.
- `default-yank-register = "+"` mirrors LazyVim's `clipboard=unnamedplus`.
- **Separate navigation layers** — Helix splits move with `ctrl+w hjkl`;
  Herdr panes use `ctrl+alt+hjkl`, which works from inside `hx` too.
- **Removing it**: `stow -D helix` *before* `git revert` (stow needs the
  package dir to know what to unlink), then `brew uninstall helix`.


## opencode

OpenCode V2 comes from the Homebrew `opencode` formula. Bootstrap verifies the
major version before linking user configuration and skills:

| File or directory under `opencode/.config/opencode/` | Owns |
|---|---|
| `opencode.jsonc` | OpenAI-only provider policy; default `openai/gpt-6.1-sol` model with high reasoning |
| `cli.json` | Tokyo Night in system mode, word-wrapped diffs, automatic sidebar, hidden scrollbar, visible thinking, animations, and TUI plugins |
| `skills/` | Global skills, including Wayfinder and its supporting files |

The root model selection does not retain a variant, so high reasoning is set
under `providers.openai.models.gpt-6.1-sol.settings`, not appended to the root
model ID. A session's explicitly selected model still takes precedence.

Provider policies deny every model provider except `openai`, including providers
discovered through saved accounts, environment variables, and built-in plugins.

Vimcode is pinned to `v0.19.2`; its V2 support is experimental. Options and keys
are in [the cheatsheet](docs/cheatsheets/vimcode.md). Herdr's V2 plugin is
registered as `./herdr-opencode`, relative to the live config directory.

`lib/opencode.sh` uses `stow --no-folding --restow`: `~/.config/opencode/`
remains a real directory, with individual configuration-file symlinks. This
keeps runtime writes out of the repository, even on a fresh machine. Local
conflicts are refused, never adopted. To reapply just this setup from the repo:

```bash
source lib/opencode.sh
opencode_require_v2 && opencode_stow "$PWD" && herdr integration install opencode
```

Saved settings reload automatically; `/reload` forces a full reload. Do not
restart a healthy background service just to apply configuration changes.

### Adding a global skill

Add the skill to `opencode/.config/opencode/skills/<skill-id>/SKILL.md` in this
repository, with its supporting files beside it. Then run from the repo root:

```bash
stow --no-folding --restow opencode
```

Stow does not watch for additions: new files need restowing, while edits to
already-linked files are visible immediately. Use `/reload` in OpenCode if the
new skill is not discovered, then invoke it with `@<skill-id>`.

Wayfinder is manual-only (`@wayfinder`). Its companion skills are bundled globally:
`grilling`, `domain-modeling`, `research`, `prototype`, and
`setup-matt-pocock-skills`, including their supporting files. These five are
unmodified copies from [mattpocock/skills at
`5863806dd4e15c63174bee4e7515a4256792ecfa`](https://github.com/mattpocock/skills/tree/5863806dd4e15c63174bee4e7515a4256792ecfa/skills).

Run `@setup-matt-pocock-skills` separately in each project to choose its issue
tracker and domain-doc layout. Installing the skills does not configure projects.

### Herdr compatibility exception

Herdr 0.9.5 installs both native V2 support and legacy compatibility assets.
Its health check still requires the latter. These files stay local and are
**Herdr-managed**, not tracked or maintained as a custom plugin fork:

- `~/.config/opencode/herdr-opencode/tui.js` — native V2 entrypoint.
- `~/.config/opencode/herdr-tui-session.js` — shared session-reporting implementation.
- `~/.config/opencode/plugins/herdr-agent-state.js` — compatibility server plugin.
- `~/.config/opencode/tui.jsonc` — compatibility registration, not the V2 preferences file.

Keep these until upstream supports V2-only installation and health checks.
Check with `herdr integration status`; reinstall with
`herdr integration install opencode`. Plugin packages may also contain their
own compatibility code; that is not an active V1 installation.

### Existing-machine cleanup and checks

The old tracked `tui.json` is retired. Before deleting a legacy symlink, verify
that it points to this repository; never remove a hand-written local config
without reviewing it. Preserve any preferences before removing unused V1 SDK
dependencies, their manifests/lockfiles, redundant backup configs, or individually
identified old plugin caches. Do not wipe OpenCode's data/state directories:
credentials, session history, permissions, and service state must survive.

Run the isolated checks with Python 3, GNU Stow, and Herdr installed:

```bash
python3 -m unittest discover -s tests -v
```

Tests use temporary homes, not live settings. They cover version checks, fresh
and repeated linking, newly added skills, old folded links, conflict refusal,
native configuration, and Herdr's installer preserving symlinks/preferences
without duplicate entries.

## herdr

Agent multiplexer — autostarted by `.zshrc` on interactive TTYs (guarded
against nesting, VS Code/Zed/Emacs shells, and non-TTY runs; a failed launch
drops to a bare shell instead of closing the window). `config.toml` keeps
active settings only; herdr's own docs cover the defaults.

### Pane navigation

Two independent layers, with no automatic edge handoff:

- **`ctrl+alt+hjkl`** (Control+Option on macOS) moves Herdr panes directly,
  from any pane app. `prefix+hjkl` remains available too.
- **`ctrl+hjkl`** uses stock LazyVim window navigation inside Neovim. Herdr
  never intercepts these keys; there is no automatic handoff at editor edges.

Pickers keep their stock list controls, and floating terminals use Ctrl+/ to
hide. No extra navigation mappings or LSP overrides are needed.

Desktop windows use Ctrl+Option+Return/arrows/F, configured during installation
by `macos.sh`. These do not claim hjkl; see [macOS window shortcuts](#macos-window-shortcuts).

After reviewing navigation changes, restart Neovim and press **Ctrl+B, then
`r`** to reload both Herdr's client and server configuration. No pane/server
restart is needed.

The claude-code/opencode session-reporting hooks (`herdr-agent-state.*`) are
**herdr-managed files** — updating an integration rewrites them — so they are
not tracked here. `install.sh` recreates them via
`herdr integration install <target>`; check versions with
`herdr integration status`.

`claude/.claude/settings.json` is **not** tracked (gitignored). Claude Code
rewrites it on every settings change, including the auto-mode `environment`
block it generates, which describes work infrastructure, and this repo is
public. On this machine the file stays at that path, so the existing
`~/.claude/settings.json` link keeps working; on a new machine Claude Code
creates its own. `herdr integration install claude` (run by `install.sh`)
adds the herdr hook to it; set the rest by hand or via `/config`:
`"theme": "dark-ansi"`, `"editorMode": "vim"`, `"tui": "fullscreen"`.

## zsh & prompt

Plain zsh, no plugin framework. `.zshrc` spells out what oh-my-zsh's `lib/`
used to set up implicitly: history options, completion (case-insensitive, menu
on the second tab; the full `compinit` security audit runs at most once a day,
otherwise the cached dump is trusted with `-C`), emacs key bindings with ↑/↓
prefix history search, and URL quoting on paste. oh-my-zsh's termsupport is
replaced by a small hook that sets the window title and reports the cwd via
OSC 7: herdr's pane shells don't get Ghostty's shell integration, so that's how
herdr sees `cd` (and restores agents in the right directory).
`zsh-autosuggestions` comes from Homebrew. Startup is ~80 ms.

Two prompt-layout details also live in `.zshrc`: the blank line between
prompts (a hook instead of starship's `add_newline`, so there's none above the
first prompt in a pane or after `clear`), and `ZLE_RPROMPT_INDENT=0` so the
right prompt ends flush with the top line. herdr's `pane_scrollbars = false`
is part of the same fix: the scrollbar column made right-aligned content stop
short of the pane border.

### Prompt

[Starship](https://starship.rs), starting from the `jetpack` preset and trimmed
to what earns its place:

```
goorie in .dotfiles                 feat/x ⧉ my-worktree ●3 ◌2 ▴40 ▿4
sudo ▸                                                     8m40s 15:39
```

| Where | What |
|---|---|
| Top left | `<user> in <folder>`: folder name only, capped at 20 characters (`~` at home) |
| Top right | Git block, only inside a repo: branch (up to 30 characters, `main` included), `⧉ <name>` in a linked worktree (up to 20), then file and line counts |
| Bottom left | `sudo` while sudo credentials are cached, then `▸` (green) after success or a hollow `▹` (red) after a failure |
| Bottom right | Language versions inside a project (jetpack's), the last command's duration when over 2 s, the clock |

Git symbols: `●` modified · `◌` untracked · `▪` staged · `✕` deleted ·
`◎` renamed · `◪` conflicts · `▴`/`▿` lines added/deleted · `⇡`/`⇣` ahead of /
behind the remote. Stashes are deliberately left out.

Two segments are custom modules, run on every prompt with shell builtins only:
the capped folder name (~6 ms; the built-in `directory` module truncates by
path segments, not characters) and the worktree marker (~14 ms; Starship has
no worktree module). The hostname is deliberately absent: this config lives on
one machine, so the user is the part worth showing. For remote sessions, add
`[hostname]` with `ssh_only = true` to show it only over SSH.

To try another look: a preset is just a complete `starship.toml`, so
`starship preset <name> --force -o starship/.config/starship.toml`, and
`git checkout` brings this one back. Avoid theme switchers that "apply" by
replacing `~/.config/starship.toml` (stellar does): that breaks the stow link.
`starship explain` and `starship timings` show what each segment is and what
it costs.

## Installation

### Prerequisites

On a **factory-reset Mac**, the script handles everything, but be aware:
- **macOS 15+ and English menu names** are required for the native window shortcuts.
- **Xcode Command Line Tools** will be installed first (required for Homebrew). This takes a few minutes and may show a system dialog.
- Apple Silicon Macs (`/opt/homebrew`) and Intel Macs (`/usr/local`) both supported automatically.

If you're on a machine that already has developer tools, the script detects this and skips the installation.

### First-time setup:

```bash
cd ~/.dotfiles
./install.sh
```

The script will:
1. Install Xcode Command Line Tools (if needed)
2. Install Homebrew (if needed)
3. Install GNU Stow (if needed)
4. Run `brew bundle` to install all packages and verify OpenCode V2
5. Use stow to create symlinks for: zsh, starship, zed, nvim, helix, claude, opencode, herdr, spotify-player, pi, git
6. Link the Ghostty and Lazygit configs
7. Apply native macOS window shortcuts via `macos.sh` (replaces Rectangle)
8. Install herdr plugins (Herdrfile) and agent integrations (claude, opencode)
9. Display next steps

### Subsequent machines:

```bash
cd ~/.dotfiles
./install.sh
```

## Managing Configs

### Editing configs

All symlinks point back to the dotfiles repo, so you can edit directly:
- `~/.zshrc` → `~/.dotfiles/zsh/.zshrc`
- `~/.config/zed/settings.json` → `~/.dotfiles/zed/.config/zed/settings.json`
- etc.

### Committing changes

```bash
cd ~/.dotfiles
git add -A
git commit -m "update zsh config"
git push
```

### Adding new configs

The golden rule: **mirror the `$HOME` directory structure inside `~/.dotfiles/{package}/`**.

When you run `stow {package}`, it creates symlinks from `~/.dotfiles/{package}` back to `$HOME`.

#### Example A: Simple dotfile in $HOME (e.g., .gitconfig)

Your git config lives at `~/.gitconfig`. To manage it with dotfiles:

```bash
# 1. Create the package directory
mkdir -p ~/.dotfiles/git

# 2. Move the actual file there
mv ~/.gitconfig ~/.dotfiles/git/.gitconfig

# 3. Create the symlink
cd ~/.dotfiles && stow git

# 4. Verify
ls -la ~/.gitconfig
# lrwxr-xr-x  goorie  staff  ~/.gitconfig -> .dotfiles/git/.gitconfig

# 5. Commit
git add git/ && git commit -m "add git config"
```

#### Example B: Config under ~/.config/ (e.g., starship)

Your starship config lives at `~/.config/starship.toml`. To manage it:

```bash
# 1. Create the package directory MIRRORING the $HOME structure
mkdir -p ~/.dotfiles/starship/.config

# 2. Move the actual file there (preserving the directory path)
mv ~/.config/starship.toml ~/.dotfiles/starship/.config/starship.toml

# 3. Create the symlink
cd ~/.dotfiles && stow starship

# 4. Verify
ls -la ~/.config/starship.toml
# lrwxr-xr-x  goorie  staff  ~/.config/starship.toml -> ../../.dotfiles/starship/.config/starship.toml

# 5. Commit
git add starship/ && git commit -m "add starship config"
```

**Key point:** If the original file was at `~/.config/foo/bar.toml`, put it in `~/.dotfiles/{package}/.config/foo/bar.toml`. Stow handles the relative symlink path automatically.

#### Example C: macOS-specific paths (e.g., ~/Library/Application Support/)

Some apps store config in deeply nested macOS paths like `~/Library/Application Support/MyApp/config`. Stow can handle this, but the directory structure inside `~/.dotfiles` gets messy.

For these cases, **handle it manually in `install.sh`** instead:

```bash
# In ~/.dotfiles/install.sh, add:
mkdir -p "$HOME/Library/Application Support/MyApp"
ln -sf "$DOTFILES_DIR/myapp/config" "$HOME/Library/Application Support/MyApp/config"
```

Then move your config to `~/.dotfiles/myapp/config` and commit it.

(This is exactly what we do with Ghostty — see the `install.sh` file.)

### Tool-managed files and secrets

Some apps (CLIs, agents, etc.) keep their own config directory and write their own state files there: auth tokens, runtime caches, downloaded binaries, version markers. Examples:

- `~/.pi/agent/auth.json` — pi's auth token
- `~/.pi/agent/settings.json` — pi's runtime state (last-used model, version)
- `~/.pi/agent/bin/` — binaries pi downloads on demand
- `~/.claude/hooks/herdr-agent-state.sh` — herdr's claude-code integration hook (herdr-managed, recreated by `herdr integration install`; see the herdr section)
- `~/.config/opencode/herdr-opencode/`, `herdr-tui-session.js`, `plugins/herdr-agent-state.js`, and `tui.jsonc` — Herdr's OpenCode integration (see the compatibility exception above)
- `~/.config/opencode/service.json` — machine-local service configuration; never track it
- `~/.config/spotify-player/credentials.json` — spotify-player's OAuth state
- anything matching `**/auth.json`, `**/credentials.json`, `**/.env*`

**These must never be tracked in the repo.** They are per-machine or per-account (or both), and committing them has leaked secrets in this repo's history before. The current `.gitignore` blocks the common shapes — extend it whenever you onboard a new tool that writes secrets next to user-managed config.

#### Onboarding a tool that mixes user config with tool state

Some tools (like pi) keep user-managed config (`~/.pi/settings.json`) alongside tool-managed state (`~/.pi/agent/*`). Stow only the user-managed paths:

```bash
mkdir -p ~/.dotfiles/pi/.pi
mv ~/.pi/settings.json ~/.dotfiles/pi/.pi/settings.json   # user-managed → tracked
# do NOT move ~/.pi/agent/* into the repo — it's tool-managed
echo 'pi/.pi/agent/' >> ~/.dotfiles/.gitignore            # belt-and-suspenders
cd ~/.dotfiles && stow pi
```

If `git status` ever shows a tool-managed file, do **not** commit it. Untrack it with `git rm --cached <path>` and add the path to `.gitignore`.

#### Why `install.sh` does not use `stow --adopt`

`stow --adopt` moves whatever is in `$HOME` into the repo, replacing tracked files. That sounds convenient on a fresh machine but has bitten us: a tool wrote a live auth token to its config file, and the next `install.sh` silently adopted the token into the repo and a later commit pushed it. Without `--adopt`, stow aborts on conflict and you resolve it explicitly — back up the conflicting file and remove it before re-running.

### Removing a package

If you want to remove a package from dotfiles but keep the config file:

```bash
# Unstow the package (removes symlinks)
cd ~/.dotfiles && stow -D {package}

# The original config file is gone (it's in the dotfiles repo now).
# If you need it back as a real file:
cp ~/.dotfiles/{package}/<path> ~/<path>

# Then delete the package from dotfiles
rm -rf ~/.dotfiles/{package}
git add -A && git commit -m "remove {package} from dotfiles"
```

### Updating Brewfile

Whenever you install a new package with brew, update the Brewfile:

```bash
# After: brew install <package> or brew install --cask <app>

brew bundle dump --file=~/.dotfiles/Brewfile
cd ~/.dotfiles
git add Brewfile
git commit -m "add <package> to Brewfile"
```

The next person (or you on a new machine) can run `brew bundle install` to get everything.

## Quick Reference

Common commands you'll use:

```bash
# Edit a config (either location works — they're the same file)
vim ~/.zshrc                          # or
vim ~/.dotfiles/zsh/.zshrc

# Commit config changes
cd ~/.dotfiles && git add -A && git commit -m "update zsh"

# Add a new config to dotfiles
mkdir -p ~/.dotfiles/{package}/<path>
mv ~/<path> ~/.dotfiles/{package}/<path>
cd ~/.dotfiles && stow {package}
git add {package}/ && git commit -m "add {package}"

# Remove symlinks for a package temporarily
cd ~/.dotfiles && stow -D {package}

# Re-enable symlinks for a package
cd ~/.dotfiles && stow {package}

# Update Brewfile after installing packages
brew bundle dump --file=~/.dotfiles/Brewfile && cd ~/.dotfiles && git add Brewfile && git commit -m "update Brewfile"

# Test stow (shows what would be created without actually doing it)
cd ~/.dotfiles && stow -n {package}
```

## Notes

- **Ghostty config** is symlinked manually in `install.sh` (not via stow) because of the deeply nested `~/Library/Application Support/com.mitchellh.ghostty/` path. Use Example C above as the pattern for other macOS-specific paths.
- **Zsh has no plugin framework.** The prompt is Starship and `zsh-autosuggestions` comes from Homebrew; the defaults oh-my-zsh used to provide (history, completion, key bindings, terminal title/OSC 7) are spelled out in `.zshrc`.
- `.zsh_history`, `.zcompdump`, and other ephemeral files are gitignored automatically (see `.gitignore`).
- **GNU Stow** is the only external dependency besides Homebrew. It's lightweight (~1MB) and installed automatically by `install.sh`.
