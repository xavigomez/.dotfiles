#!/bin/bash

set -e

echo "🚀 Bootstrapping dotfiles..."

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR"

# Step 1: Install Homebrew if needed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✓ Homebrew is already installed"
fi

# Step 2: Ensure stow is installed
if ! command -v stow &> /dev/null; then
    echo "📦 Installing GNU Stow..."
    brew install stow
else
    echo "✓ GNU Stow is already installed"
fi

# Step 3: Run brew bundle to install packages
echo "📦 Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# Step 4: Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✓ oh-my-zsh is already installed"
fi

# Step 5: Install oh-my-zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "📦 Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✓ zsh-autosuggestions is already installed"
fi

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "📦 Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "✓ powerlevel10k is already installed"
fi

# Step 6: Run stow to create symlinks for managed dotfiles
echo "🔗 Creating symlinks with stow..."
stow -vv zsh
stow -vv zed
stow -vv nvim

# Step 7: Create symlink for Ghostty config (manual, outside of stow)
echo "🔗 Linking Ghostty config..."
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sf "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

echo ""
echo "✅ Dotfiles bootstrapped successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Configure powerlevel10k if needed: p10k configure"
echo "   3. When ready to add nvim+LazyVim, run: nvim"
echo ""
