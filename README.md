# dotfiles

My personal dotfiles managed with GNU Stow.

## Structure

```
~/.dotfiles/
├── zsh/              # Zsh + Oh My Zsh + Powerlevel10k + herdr autostart
├── zed/              # Zed editor settings and keybindings
├── ghostty/          # Ghostty terminal emulator config
├── nvim/             # Neovim + LazyVim (extras via lazyvim.json)
├── claude/           # Claude Code settings, hooks, and skills
├── opencode/         # OpenCode agent settings + TUI plugins
├── herdr/            # herdr agent multiplexer config (active settings only)
├── pi/               # pi coding agent settings (state stays untracked)
├── spotify-player/   # spotify-player TUI config (app.example.toml template)
├── docs/             # Cheatsheets for tools in use
├── Herdrfile         # Declarative herdr plugin list (pinned via --ref)
├── Brewfile          # Homebrew packages and casks
├── install.sh        # Bootstrap script
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
| claude code | `claude/.claude/settings.json` → `"theme": "dark-ansi"` | chrome |
| lazygit (bare + in nvim) | snacks `configure = false` (see `nvim/.../plugins/snacks.lua`) | chrome |

**Sovereign apps** render their own truecolor palette and ignore ANSI slots:

| App | Palette | Source |
|---|---|---|
| nvim | Tokyoppuccin Storm (Catppuccin-flavored Tokyo Night, bg matched to chrome `#222436`) | `EmmanuelVernet/tokyoppuccin.nvim` via `nvim/.../plugins/tokyoppuccin.lua` |
| opencode | its own built-in default theme | unset — follows nothing |

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

## nvim

LazyVim with language extras enabled in `lazyvim.json` (`:LazyExtras` to
manage). The custom layer is deliberately minimal — every deviation from
stock LazyVim lives in `lua/plugins/*.lua` and `lua/config/*.lua`, commented
with its rationale. Non-obvious decisions:

- **Registers never touch disk.** `options.lua` sets `shada` with `<0`, so
  yanked text (tokens, `.env` contents) is never persisted to the shada file.
  Pairs with this repo's secrets posture — same reason there is no
  `stow --adopt` (see below).
- **Visual `p` doesn't clobber the paste register** (`keymaps.lua`): the
  standard `"_dP` idiom, so pasting over a selection repeatedly keeps working.
- **Lazygit runs stock** inside nvim (`snacks.lua` sets `configure = false`)
  so it inherits terminal chrome — see Theming.
- **Parsers and LSP servers no extra covers** (`lsp.lua`): `scss` + `jsonc`
  parsers, `cssls` and `emmet_language_server`. LazyVim has no CSS extra
  (verified 2026); everything else comes from extras.

## herdr

Agent multiplexer — autostarted by `.zshrc` on interactive TTYs (guarded
against nesting, VS Code/Zed/Emacs shells, and non-TTY runs; a failed launch
drops to a bare shell instead of closing the window). `config.toml` keeps
active settings only; herdr's own docs cover the defaults.

The claude-code/opencode session-reporting hooks (`herdr-agent-state.*`) are
**herdr-managed files** — updating an integration rewrites them — so they are
not tracked here. `install.sh` recreates them via
`herdr integration install <target>`; check versions with
`herdr integration status`.

## Installation

### Prerequisites

On a **factory-reset Mac**, the script handles everything, but be aware:
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
4. Run `brew bundle` to install all packages
5. Install oh-my-zsh and plugins
6. Use stow to create symlinks for: zsh, zed, nvim, claude, opencode, herdr, spotify-player, pi
7. Link the Ghostty config
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
- `~/.config/opencode/plugins/herdr-agent-state.js` — same, for opencode
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
- **oh-my-zsh plugins/themes** are installed directly via git clone in `install.sh`, not tracked as submodules. This keeps things simple and lets them update independently.
- `.zsh_history`, `.zcompdump`, and other ephemeral files are gitignored automatically (see `.gitignore`).
- **GNU Stow** is the only external dependency besides Homebrew. It's lightweight (~1MB) and installed automatically by `install.sh`.
