# ---------------------------------------------------------------------------
#  Auto-start tmux
# ---------------------------------------------------------------------------
#  - Won't nest (skips if already inside tmux)
#  - Skips inside VS Code, Zed, Emacs, or non-interactive shells
#  - Prompts via fzf to attach to an existing session or create a new one
if command -v tmux &>/dev/null && [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ "$TERM_PROGRAM" != "zed" ]] && [[ -z "$INSIDE_EMACS" ]] && [[ -o interactive ]]; then
  _tmux_sessions=$(tmux list-sessions -F '#S' 2>/dev/null)
  _tmux_new_label='[+ new session]'
  _tmux_list_cmd="printf '%s\n' '$_tmux_new_label'; tmux list-sessions -F '#S' 2>/dev/null"

  if [[ -z "$_tmux_sessions" ]]; then
    _tmux_choice="$_tmux_new_label"
  elif command -v fzf &>/dev/null; then
    # Keys that should be inert in NORMAL mode (excludes j,k,q,i which have actions)
    _fzf_inert='a,b,c,d,e,f,g,h,l,m,n,o,p,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,1,2,3,4,5,6,7,8,9,space,;,:,.,-,_,/'
    _fzf_inert_binds="${_fzf_inert//,/:ignore,}:ignore"
    _tmux_choice=$(eval "$_tmux_list_cmd" | fzf \
      --reverse --height=40% --prompt='INSERT > ' \
      --header='enter: attach · ctrl-x: kill · esc: normal · i: insert · q: cancel' \
      --bind "ctrl-x:execute-silent(tmux kill-session -t {} 2>/dev/null)+reload($_tmux_list_cmd)" \
      --bind "$_fzf_inert_binds" \
      --bind 'j:down' \
      --bind 'k:up' \
      --bind 'q:abort' \
      --bind "start:unbind(j,k,q,i,$_fzf_inert)" \
      --bind "esc:rebind(j,k,q,i,$_fzf_inert)+unbind(esc)+change-prompt(NORMAL > )" \
      --bind "i:unbind(j,k,q,i,$_fzf_inert)+rebind(esc)+change-prompt(INSERT > )")
    unset _fzf_inert _fzf_inert_binds
  else
    # fzf not installed yet — fall back to creating a new session
    _tmux_choice="$_tmux_new_label"
  fi

  if [[ "$_tmux_choice" == "$_tmux_new_label" ]]; then
    read "_tmux_name?Session name: "
    [[ -z "$_tmux_name" ]] && _tmux_name="tab-$$"
    tmux new-session -s "$_tmux_name"
  elif [[ -n "$_tmux_choice" ]]; then
    tmux attach -t "$_tmux_choice"
  fi

  unset _tmux_sessions _tmux_new_label _tmux_choice _tmux_name _tmux_list_cmd
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
