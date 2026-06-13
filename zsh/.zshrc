# ---------------------------------------------------------------------------
#  Auto-start tmux
# ---------------------------------------------------------------------------
#  - Won't nest (skips if already inside tmux)
#  - Skips inside VS Code, Zed, Emacs, or non-interactive shells
#  - Opens an nvim scratch buffer to attach, create, or quit to plain shell
if command -v tmux &>/dev/null && command -v nvim &>/dev/null && [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ "$TERM_PROGRAM" != "zed" ]] && [[ -z "$INSIDE_EMACS" ]] && [[ -o interactive ]]; then
  _tmux_picker="$HOME/.config/nvim/lua/tmux_picker.lua"
  if [[ -f "$_tmux_picker" ]]; then
    _tmux_out=$(mktemp)
    TMUX_PICKER_OUT="$_tmux_out" nvim --clean -c "luafile $_tmux_picker"
    _tmux_choice=$(cat "$_tmux_out" 2>/dev/null)
    rm -f "$_tmux_out"
    case "$_tmux_choice" in
      attach:*) tmux attach -t "${_tmux_choice#attach:}" ;;
      new:*) tmux new-session -s "${_tmux_choice#new:}" ;;
      resume:*)
        # Restore the latest tmux-resurrect snapshot, then attach to the picked
        # session. resurrect's restore script needs a running tmux server, so
        # bootstrap one with a throwaway session, run the restore inside it,
        # then drop the bootstrap and attach to the real target.
        _target="${_tmux_choice#resume:}"
        tmux new-session -d -s __resurrect_bootstrap 2>/dev/null
        tmux run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
        tmux kill-session -t __resurrect_bootstrap 2>/dev/null
        tmux attach -t "$_target"
        unset _target
        ;;
      close:*|close)
        osascript 2>/dev/null <<'APPLESCRIPT'
tell application "Ghostty"
  set w to front window
  set current_idx to index of selected tab of w
  if current_idx > 1 then
    set prev_tab to item (current_idx - 1) of tabs of w
    tell prev_tab to select tab
  end if
end tell
APPLESCRIPT
        exit
        ;;
      focus:*)
        _target="${_tmux_choice#focus:}"
        _found=$(osascript - "$_target" 2>/dev/null <<'APPLESCRIPT'
on run argv
  set target_name to item 1 of argv
  tell application "Ghostty"
    activate
    repeat with w in windows
      repeat with t in tabs of w
        if name of t is target_name then
          tell w to activate window
          tell t to select tab
          return "found"
        end if
      end repeat
    end repeat
    return "not_found"
  end tell
end run
APPLESCRIPT
)
        if [[ "$_found" == "found" ]]; then
          exit
        else
          tmux attach -t "$_target"
        fi
        unset _target _found
        ;;
    esac
  fi
  unset _tmux_out _tmux_choice _tmux_picker
fi

# Load the current directory's .envrc before instant prompt is enabled, so
# direnv's "loading…" output lands in the pre-instant-prompt phase. The hook
# installed at the bottom of this file handles future cd's.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd)"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="zed ~/.zshrc"
alias omzconfig="zed ~/.oh-my-zsh"
alias ghosttyconfig="zed $HOME/Library/Application Support/com.mitchellh.ghostty/config"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# direnv hook — silent at install time; the starting cwd's .envrc was already
# exported above the instant prompt block.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
