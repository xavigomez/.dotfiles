#!/bin/bash

set -e

# Parse arguments
VERBOSE=false
for arg in "$@"; do
  case $arg in
  --verbose | -v) VERBOSE=true ;;
  esac
done

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR"

echo "🚀 Bootstrapping dotfiles..."
echo ""

# --- Xcode CLT ---
if ! xcode-select -p &>/dev/null; then
  echo "⚠️  Xcode Command Line Tools not found"
  echo "📦 Installing Xcode Command Line Tools..."
  echo "   (This will take a few minutes. You may see a system dialog asking for permission.)"
  xcode-select --install

  echo ""
  echo "⏳ Waiting for installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  echo "✓ Xcode Command Line Tools installed"
else
  echo "✓ Xcode Command Line Tools already installed"
fi

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✓ Homebrew is already installed"
fi

# Ensure brew is in PATH (needed on Apple Silicon after fresh install)
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true

# --- Stow ---
if ! command -v stow &>/dev/null; then
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

# --- Rustup ---
if [ -x "/opt/homebrew/opt/rustup/bin/rustup" ]; then
  echo "📦 Installing stable Rust toolchain via rustup..."
  /opt/homebrew/opt/rustup/bin/rustup default stable
  /opt/homebrew/opt/rustup/bin/rustup component add rust-analyzer rust-src
  echo "✓ Stable Rust toolchain installed"
fi

# --- fnm ---
if command -v fnm &>/dev/null; then
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
# No --adopt: it silently pulls whatever is in $HOME into the repo, which has
# historically pulled live auth tokens into tracked files. If a conflict
# happens, stow aborts the package and the user resolves it manually.
STOW_PACKAGES=(zsh zed nvim claude opencode herdr spotify-player pi)

if [ "$VERBOSE" = true ]; then
  STOW_FLAGS="--verbose=2"
else
  STOW_FLAGS=""
fi

echo ""
echo "🔗 Creating symlinks with stow..."
echo ""
for pkg in "${STOW_PACKAGES[@]}"; do
  printf "  → Linking %s..." "$pkg"
  stow $STOW_FLAGS "$pkg"
  echo " ✓"
done

# --- spotify-player config from example ---
SPOTIFY_CONFIG="$HOME/.config/spotify-player/app.toml"
SPOTIFY_EXAMPLE="$HOME/.config/spotify-player/app.example.toml"
if [ ! -f "$SPOTIFY_CONFIG" ] && [ -f "$SPOTIFY_EXAMPLE" ]; then
  cp "$SPOTIFY_EXAMPLE" "$SPOTIFY_CONFIG"
  echo "  ✓ Created spotify-player config from example (edit app.toml to add your client_id)"
fi

# --- Ghostty ---
echo ""
echo "🔗 Linking Ghostty config..."
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sfn "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
echo "  ✓ Ghostty config linked"

# --- Herdr plugins ---
# Best-effort: herdr is installed by the Brewfile mid-bootstrap, so a fresh
# shell may not have it on PATH yet on first run. Never abort the bootstrap on
# plugin install failure — collect failures and emit a copy-paste retry.
HERDRFILE="$DOTFILES_DIR/Herdrfile"
if [ -f "$HERDRFILE" ]; then
  # Read non-comment, non-blank lines into an array.
  herdr_plugins=()
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [ -z "$line" ] && continue
    herdr_plugins+=("$line")
  done < "$HERDRFILE"

  if [ "${#herdr_plugins[@]}" -eq 0 ]; then
    echo "  ✓ No herdr plugins declared in Herdrfile"
  elif ! command -v herdr &>/dev/null; then
    echo "  ⚠️  herdr not on PATH yet — install plugins manually:"
    retry_cmd=""
    for src in "${herdr_plugins[@]}"; do
      [ -n "$retry_cmd" ] && retry_cmd="$retry_cmd && "
      retry_cmd="${retry_cmd}herdr plugin install $src --yes"
    done
    echo "      $retry_cmd"
    echo "      (restart your shell first if herdr was just installed)"
  else
    echo "📦 Installing herdr plugins from Herdrfile..."
    failed_plugins=()
    for src in "${herdr_plugins[@]}"; do
      printf "  → %s..." "$src"
      if herdr plugin install $src --yes >/tmp/herdr-plugin-install.log 2>&1; then
        echo " ✓"
      else
        echo " ✗"
        failed_plugins+=("$src")
      fi
    done

    total="${#herdr_plugins[@]}"
    ok=$((total - ${#failed_plugins[@]}))
    if [ "${#failed_plugins[@]}" -eq 0 ]; then
      echo "  ✓ $total/$total plugins installed"
    else
      echo ""
      echo "  ⚠️  $ok/$total plugins installed — ${#failed_plugins[@]} failed:"
      for src in "${failed_plugins[@]}"; do
        echo "     • $src"
      done
      echo "  Retry manually:"
      retry_cmd=""
      for src in "${failed_plugins[@]}"; do
        [ -n "$retry_cmd" ] && retry_cmd="$retry_cmd && "
        retry_cmd="${retry_cmd}herdr plugin install $src --yes"
      done
      echo "    $retry_cmd"
      echo "  (logs: /tmp/herdr-plugin-install.log)"
    fi
  fi
fi

# --- Herdr agent integrations ---
# Installs herdr's session-reporting hooks into agent configs (claude code,
# opencode). Those hook files are herdr-managed — updating the integration
# rewrites them — so they are deliberately NOT tracked in this repo; this
# step recreates them on a fresh machine. Best-effort, same rationale as
# the plugins block above.
HERDR_INTEGRATIONS=(claude opencode)
if ! command -v herdr &>/dev/null; then
  echo "  ⚠️  herdr not on PATH yet — install integrations manually:"
  echo "      herdr integration install claude && herdr integration install opencode"
  echo "      (restart your shell first if herdr was just installed)"
else
  echo "📦 Installing herdr agent integrations..."
  for target in "${HERDR_INTEGRATIONS[@]}"; do
    printf "  → %s..." "$target"
    if herdr integration install "$target" >/tmp/herdr-integration-install.log 2>&1; then
      echo " ✓"
    else
      echo " ✗ (logs: /tmp/herdr-integration-install.log)"
    fi
  done
fi

echo ""
echo "✅ Dotfiles bootstrapped successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Configure powerlevel10k if needed: p10k configure"
echo "   3. When ready to add nvim+LazyVim, run: nvim"
echo "   4. Set up Spotify: cp ~/.config/spotify-player/app.example.toml ~/.config/spotify-player/app.toml, add your client_id, then run: spotify_player"
echo "   5. Add a herdr plugin: echo 'owner/repo' >> Herdrfile && ./install.sh"
echo ""
