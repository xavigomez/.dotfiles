#!/bin/bash

set -e

# Parse arguments
VERBOSE=false
for arg in "$@"; do
    case $arg in
        --verbose|-v) VERBOSE=true ;;
    esac
done

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR"

echo "🚀 Bootstrapping dotfiles..."
echo ""

# --- Xcode CLT ---
if ! xcode-select -p &> /dev/null; then
    echo "⚠️  Xcode Command Line Tools not found"
    echo "📦 Installing Xcode Command Line Tools..."
    echo "   (This will take a few minutes. You may see a system dialog asking for permission.)"
    xcode-select --install
    
    echo ""
    echo "⏳ Waiting for installation to complete..."
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    echo "✓ Xcode Command Line Tools installed"
else
    echo "✓ Xcode Command Line Tools already installed"
fi

# --- Homebrew ---
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✓ Homebrew is already installed"
fi

# Ensure brew is in PATH (needed on Apple Silicon after fresh install)
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true

# --- Stow ---
if ! command -v stow &> /dev/null; then
    echo "📦 Installing GNU Stow..."
    brew install stow
else
    echo "✓ GNU Stow is already installed"
fi

# --- brew bundle ---
echo "📦 Installing packages from Brewfile..."
if [ "$VERBOSE" = true ]; then
    brew bundle install --file="$DOTFILES_DIR/Brewfile" --verbose
else
    brew bundle install --file="$DOTFILES_DIR/Brewfile" --quiet 2>/dev/null || brew bundle install --file="$DOTFILES_DIR/Brewfile"
fi
echo "✓ Brewfile dependencies installed"

# Step 3.5: Install LTS Node.js via fnm
if command -v fnm &> /dev/null; then
    echo "📦 Installing LTS Node.js via fnm..."
    fnm install --lts
    fnm default lts
    echo "✓ LTS Node.js installed and set as default"
fi

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

# Step 7.5: Create symlink for Ghostty themes directory
echo "🔗 Linking Ghostty themes..."
ln -sf "$DOTFILES_DIR/ghostty/themes" "$HOME/Library/Application Support/com.mitchellh.ghostty/themes"

echo ""
echo "✅ Dotfiles bootstrapped successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Configure powerlevel10k if needed: p10k configure"
echo "   3. When ready to add nvim+LazyVim, run: nvim"
echo ""
