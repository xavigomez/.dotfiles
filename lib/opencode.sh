#!/bin/bash

# Sourced by install.sh and the isolated bootstrap tests; no side effects here.
opencode_require_v2() {
  local version
  local pattern='^(opencode[[:space:]]+)?v?2\.[0-9]+\.[0-9]+([+-][[:alnum:].-]+)?$'
  if ! version="$(opencode --version 2>/dev/null)"; then
    echo "OpenCode V2 is required; could not run opencode --version." >&2
    return 1
  fi
  if [[ ! "$version" =~ $pattern ]]; then
    printf 'OpenCode V2 is required; found %s. Check the Homebrew installation and PATH.\n' "$version" >&2
    return 1
  fi
  printf '✓ OpenCode V2 verified (%s)\n' "$version"
}

opencode_stow() {
  local dotfiles_dir="$1"
  shift
  # Restow also unfolds an older directory link. Only user-owned files should
  # be linked: OpenCode and Herdr write credentials and runtime assets beside them.
  stow --dir="$dotfiles_dir" --target="$HOME" --no-folding --restow "$@" opencode || return
  if [[ -L "$HOME/.config/opencode" || ! -d "$HOME/.config/opencode" ]]; then
    echo "OpenCode config must be a real directory with individual file symlinks." >&2
    return 1
  fi
}
