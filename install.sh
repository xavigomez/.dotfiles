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

# --- fnm ---
if command -v fnm &> /dev/null; then
    echo "📦 Installing LTS Node.js via fnm..."
    eval "$(fnm env)"
    fnm install --lts
    # Get the LTS version from fnm ls (the one tagged as lts-latest)
    FNM_LTS=$(fnm ls | grep lts-latest | awk '{print $2}')
    fnm default "$FNM_LTS"
    echo "✓ LTS Node.js ($FNM_LTS) installed and set as default"
fi

# --- oh-my-zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing oh-my-zsh..."
    if [ "$VERBOSE" = true ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc 2>/dev/null
    fi
    echo "✓ oh-my-zsh installed"
else
    echo "✓ oh-my-zsh is already installed"
fi

# --- oh-my-zsh plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "📦 Installing zsh-autosuggestions plugin..."
    if [ "$VERBOSE" = true ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null
    fi
    echo "✓ zsh-autosuggestions installed"
else
    echo "✓ zsh-autosuggestions is already installed"
fi

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "📦 Installing powerlevel10k theme..."
    if [ "$VERBOSE" = true ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    else
        git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" 2>/dev/null
    fi
    echo "✓ powerlevel10k installed"
else
    echo "✓ powerlevel10k is already installed"
fi

# --- Stow dotfiles ---
STOW_PACKAGES=(zsh zed nvim)

if [ "$VERBOSE" = true ]; then
    STOW_FLAGS="--adopt --verbose=2"
else
    STOW_FLAGS="--adopt"
fi

echo ""
echo "🔗 Creating symlinks with stow..."
echo ""
for pkg in "${STOW_PACKAGES[@]}"; do
    printf "  → Linking %s..." "$pkg"
    stow $STOW_FLAGS "$pkg"
    echo " ✓"
done

# Restore any adopted files to ensure dotfiles repo is source of truth
git -C "$DOTFILES_DIR" restore .
echo "  ✓ Restored dotfiles to source of truth"

# --- Ghostty ---
echo ""
echo "🔗 Linking Ghostty config..."
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sfn "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
echo "  ✓ Ghostty config linked"

echo "🔗 Linking Ghostty themes..."
ln -sfn "$DOTFILES_DIR/ghostty/themes" "$HOME/Library/Application Support/com.mitchellh.ghostty/themes"
echo "  ✓ Ghostty themes linked"

echo ""
echo "✅ Dotfiles bootstrapped successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Configure powerlevel10k if needed: p10k configure"
echo "   3. When ready to add nvim+LazyVim, run: nvim"
echo ""
