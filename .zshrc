# zsh is the primary interactive shell; bash remains a small fallback.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

typeset -U path
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)

ZSH_THEME="agnosterzak"
plugins=(git archlinux zsh-autosuggestions zsh-syntax-highlighting)
# Keep syntax highlighting last: it hooks widgets installed by earlier plugins.
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree'
fi
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh 2>/dev/null) 2>/dev/null || true
fi
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh 2>/dev/null)"
fi

# Quiet in scripts, SSH, tmux, and IDE terminals. Config remains user-local.
if [[ -o interactive && -t 1 && -z "$SSH_CONNECTION$SSH_TTY$TMUX$VSCODE_PID$IDEA_INITIAL_DIRECTORY" ]]; then
  if command -v pokemon-colorscripts >/dev/null 2>&1 && command -v fastfetch >/dev/null 2>&1; then
    pokemon-colorscripts --no-title -s -r | fastfetch -c "${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/config-pokemon.jsonc" --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
  fi
fi

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}" 2>/dev/null
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY

# Bare-repo helper: dotfiles lives at ~/.dotfiles and uses HOME as work tree.
dot() { git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
alias st='git status'
alias co='git checkout'
alias br='git branch'
alias lg='git log --oneline --decorate --graph'
