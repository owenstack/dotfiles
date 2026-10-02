# zsh is the primary shell; this is a minimal bash fallback.
[[ $- != *i* ]] && return
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\\$ '
