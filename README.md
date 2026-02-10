# dotfiles

My personal dotfiles managed with GNU Stow.

## Structure

```
~/.dotfiles/
├── zsh/              # Zsh + Oh My Zsh + Powerlevel10k config
├── zed/              # Zed editor settings and keybindings
├── ghostty/          # Ghostty terminal emulator config
├── nvim/             # Neovim + LazyVim setup (future)
├── Brewfile          # Homebrew packages and casks
├── install.sh        # Bootstrap script
├── .gitignore        # Git ignore patterns
└── README.md         # This file
```

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
6. Use stow to create symlinks for zsh, zed, and nvim configs
7. Link the Ghostty config
8. Display next steps

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

## Setting up LazyVim (future)

When you're ready to add Neovim:

1. Install Neovim: `brew install neovim` (update Brewfile)
2. Run the LazyVim installer: `nvim`
3. Move `~/.config/nvim` to `~/.dotfiles/nvim/.config/nvim`
4. Run `cd ~/.dotfiles && stow nvim` to create symlink
5. Commit the changes

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
