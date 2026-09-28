# ADI-NAN default zsh configuration.
# Copied into every new user's home directory from /etc/skel.

# --- history --------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# --- completion -----------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# --- prompt & tool integrations ------------------------------------------
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v mise      >/dev/null && eval "$(mise activate zsh)"
command -v direnv    >/dev/null && eval "$(direnv hook zsh)"
command -v zoxide    >/dev/null && eval "$(zoxide init zsh)"

# --- kube / IaC completions ----------------------------------------------
command -v kubectl >/dev/null && source <(kubectl completion zsh)
command -v helm    >/dev/null && source <(helm completion zsh)

# --- aliases --------------------------------------------------------------
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias tf='tofu'
alias tfp='tofu plan'
alias tfa='tofu apply'
alias d='podman'
alias dc='podman compose'
alias g='git'
alias gs='git status -sb'
alias ll='ls -alh --color=auto'
alias vim='nvim'

export EDITOR=nvim

# --- greeting -------------------------------------------------------------
command -v fastfetch >/dev/null && fastfetch 2>/dev/null || true
