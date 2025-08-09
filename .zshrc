# ──────────────────────────────────────────────────────────────
#  Helpers and prompt components
# ──────────────────────────────────────────────────────────────
autoload -U colors && colors     # enable %{$fg[color]%} escapes
setopt PROMPT_SUBST              # allow $(…) in $PROMPT

# Show non‑zero exit status in red
_exit_status() {
  local ec=$?
  (( ec )) && print -P "%F{red}✖${ec}%f "
}

# Show current Git branch (or short SHA on detached HEAD)
_git_branch() {
  local b
  b=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || b=$(command git rev-parse --quiet --short HEAD 2>/dev/null) \
    || return
  print -P "%F{cyan}(${b})%f "
}

# Minimal, dependency‑free prompt
set_minimal_prompt() {
  PROMPT='$(_exit_status)%F{yellow}%n@%m%f:%F{green}%~%f $(_git_branch)%B%F{blue}%#%f%b '
  # Uncomment for Python venv hint on the right
  # RPROMPT='${VIRTUAL_ENV:+(%F{magenta}%${${VIRTUAL_ENV:t}}%f)}'
}

# Convenience: `mkcd <dir>` makes a directory and enters it
mkcd() {
  command mkdir -p -- "$1" && cd -- "$1"
}

if [[ $TERM == xterm-kitty ]]; then
  alias icat="kitten icat"
fi

# ──────────────────────────────────────────────────────────────
#  VS Code Integrated Terminal vs. regular terminal
# ──────────────────────────────────────────────────────────────
# ––– Manjaro common configs (if present) –––
[[ -e /usr/share/zsh/manjaro-zsh-config  ]] && source /usr/share/zsh/manjaro-zsh-config

if [[ $TERM_PROGRAM == vscode ]]; then
  # VS Code: keep things light—no Powerlevel10k or wide chars
  use_powerline=false
  has_widechars=false
  set_minimal_prompt

else
  # Regular terminal
  use_powerline=true
  has_widechars=false

  # ––– Powerlevel10k instant prompt (if cached file exists) –––
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]
  then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  # ––– Manjaro common configs (if present) –––
  [[ -e /usr/share/zsh/manjaro-zsh-prompt  ]] && source /usr/share/zsh/manjaro-zsh-prompt

  # ––– Powerlevel10k main config –––
  if [[ -f ~/.p10k.zsh ]]; then
    source ~/.p10k.zsh
  else
    # Fallback to the minimal prompt when P10k isn’t installed
    set_minimal_prompt
  fi
fi

# ──────────────────────────────────────────────────────────────
#  fzf integration (Manjaro / Arch style)
# ──────────────────────────────────────────────────────────────
# Enables Ctrl-T, Ctrl-R, Alt-C keybindings + fuzzy completion
if (( $+commands[fzf] )); then
  # Prefer upstream integration if fzf ≥ 0.48
  source <(fzf --zsh) 2> /dev/null \
  || {
    [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
    [ -f /usr/share/fzf/completion.zsh   ] && source /usr/share/fzf/completion.zsh
  }

  # speedier searches with nicer previews (requires fd, ripgrep, bat)
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --line-range=:200 --plain {} 2>/dev/null || head -n 200 {}"'
fi

# ──────────────────────────────────────────────────────────────
#  Environment/Path tweaks that apply everywhere
# ──────────────────────────────────────────────────────────────
source ~/.zsh_env_vars
path+=("$HOME/go/bin")
