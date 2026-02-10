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
└── README.md         # This file
```

## Installation

### First-time setup:

```bash
cd ~/.dotfiles
./install.sh
```

The script will:
1. Install Homebrew (if needed)
2. Install GNU Stow (if needed)
3. Run `brew bundle` to install all packages
4. Install oh-my-zsh and plugins
5. Use stow to create symlinks for zsh, zed, and nvim configs
6. Link the Ghostty config
7. Display next steps

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

1. Create the directory structure in `~/.dotfiles/{package}/.config/...` (mirroring `$HOME` structure)
2. Move the actual config file there
3. Run `cd ~/.dotfiles && stow {package}` to create the symlink
4. Commit

### Adding new Homebrew packages

```bash
brew install <package>
brew bundle dump --file=~/.dotfiles/Brewfile
cd ~/.dotfiles
git add Brewfile
git commit -m "add <package> to Brewfile"
```

## Setting up LazyVim (future)

When you're ready to add Neovim:

1. Install Neovim: `brew install neovim` (update Brewfile)
2. Run the LazyVim installer: `nvim`
3. Move `~/.config/nvim` to `~/.dotfiles/nvim/.config/nvim`
4. Run `cd ~/.dotfiles && stow nvim` to create symlink
5. Commit the changes

## Notes

- **Ghostty config** is symlinked manually in `install.sh` (not via stow) because of the deeply nested `~/Library/Application Support/com.mitchellh.ghostty/` path
- **oh-my-zsh plugins/themes** are installed directly via git clone in `install.sh`, not tracked as submodules
- `.zsh_history`, `.zcompdump`, and other ephemeral files are gitignored automatically
