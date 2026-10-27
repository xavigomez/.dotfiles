# ---------------------------------------------------------------------------
#  Auto-start herdr
# ---------------------------------------------------------------------------
#  - Won't nest (skips if already inside herdr — HERDR_ENV=1)
#  - Skips inside VS Code, Zed, Emacs, non-interactive shells, and shells
#    without a TTY (e.g. Zed's env capture runs `zsh -l -i -c` over a pipe)
#  - Herdr is a persistent agent multiplexer; it replaces the old
#    tmux + tmux-resurrect + tmux_picker.lua setup. Session and agent
#    restore is native (see ~/.config/herdr/config.toml).
if command -v herdr &>/dev/null && [[ "$HERDR_ENV" != "1" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ "$TERM_PROGRAM" != "zed" ]] && [[ -z "$INSIDE_EMACS" ]] && [[ -o interactive && -t 0 && -t 1 ]]; then
  # herdr is the terminal: a normal quit exits the shell and closes the window.
  # On a launch failure, drop to a bare shell (zsh -f skips rc, so no
  # relaunch loop) so the error stays visible and fixable.
  herdr || exec zsh -f
  exit
fi

# ---------------------------------------------------------------------------
#  PATH
# ---------------------------------------------------------------------------
# brew shellenv also prepends Homebrew's site-functions to $fpath, so it must
# run before compinit.
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
#  Shell defaults
# ---------------------------------------------------------------------------
#  What oh-my-zsh's lib/ used to set up implicitly.

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups \
  hist_ignore_space hist_verify share_history

# Directories (auto_cd is what makes a bare `..` work)
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus

# Misc
setopt interactive_comments long_list_jobs multios
unsetopt flow_control

# Completion: menu on second tab, case-insensitive, partial-word matching.
# The full compinit (with its ~25ms compaudit security check, which also picks
# up newly installed completions) runs at most once a day; otherwise the
# cached dump is trusted with -C.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
_fresh_dump=($_zcompdump(N.mh-24))
if (( $#_fresh_dump )); then compinit -C -d "$_zcompdump"; else compinit -d "$_zcompdump"; fi
unset _zcompdump _fresh_dump
setopt auto_menu complete_in_word always_to_end
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# Key bindings: emacs mode, ↑/↓ search history by what's already typed
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[Z' reverse-menu-complete
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^X^E' edit-command-line

# Quote URLs as they're typed or pasted, so `?` and `&` don't trip globbing
autoload -Uz bracketed-paste-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
zle -N self-insert url-quote-magic

# ---------------------------------------------------------------------------
#  Terminal integration
# ---------------------------------------------------------------------------
#  Previously oh-my-zsh's lib/termsupport.zsh:
#  - Title: cwd while idle, command name while running.
#  - OSC 7: report the cwd on every prompt. Herdr's pane shells don't get
#    Ghostty's shell integration, so this is how herdr sees `cd` (and
#    restores agents in the right directory). The URL host is left empty:
#    herdr-radar's herdr-osc7.zsh found herdr ignores it otherwise.
autoload -Uz add-zsh-hook
_term_precmd() {
  print -Pn '\e]2;%~\a'
  printf '\e]7;file://%s\e\\' "$PWD"
}
_term_preexec() { print -rn -- $'\e]2;'"${1%% *}"$'\a' }
add-zsh-hook precmd _term_precmd
add-zsh-hook preexec _term_preexec

# ---------------------------------------------------------------------------
#  Tools & plugins
# ---------------------------------------------------------------------------

# fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd)"

# bun global binaries
export PATH="$HOME/.bun/bin:$PATH"

[[ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# direnv — installed before starship so it updates the env before the prompt
# renders.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# ---------------------------------------------------------------------------
#  Aliases
# ---------------------------------------------------------------------------
export CLICOLOR=1 # colored ls (oh-my-zsh aliased ls='ls -G')
alias ll='ls -lh'
alias la='ls -lAh'
alias zshconfig="zed ~/.zshrc"
alias ghosttyconfig="zed $HOME/Library/Application Support/com.mitchellh.ghostty/config"
alias v="nvim"

# ---------------------------------------------------------------------------
#  Prompt — config in ~/.config/starship.toml
# ---------------------------------------------------------------------------
(( ${+commands[starship]} )) && eval "$(starship init zsh)"
