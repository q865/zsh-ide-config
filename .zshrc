# ------------------------------------------------------------------------------
# SECRETS
# ------------------------------------------------------------------------------
# All secret keys and tokens are stored in a separate, untracked file.
if [[ -f ~/.zsh_secrets ]]; then
  source ~/.zsh_secrets
fi

# ------------------------------------------------------------------------------
# PATH & ENVIRONMENT VARIABLES
# ------------------------------------------------------------------------------
# Set the default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Add ~/.local/bin to the PATH
export PATH="$HOME/.local/bin:$PATH"

# ------------------------------------------------------------------------------
# OH MY ZSH CONFIGURATION
# ------------------------------------------------------------------------------
# Path to your oh-my-zsh installation.
export ZSH="/home/panch/.oh-my-zsh"

# We leave ZSH_THEME empty to allow starship to take control.
ZSH_THEME=""

# List of plugins
plugins=(
    git
    vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    zsh-history-substring-search
    fzf
    fzf-tab # fzf-powered completions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# PROMPT & SHELL EXTENSIONS
# ------------------------------------------------------------------------------
# Starship - The cross-shell prompt
eval "$(starship init zsh)"

# zoxide - A smarter cd command
# To enable, install zoxide (e.g., `yay -S zoxide`) and restart your shell.
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# FZF and bat integration
# Use bat for fzf previews and set up keybindings
if command -v bat &> /dev/null; then
  export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
fi
eval "$(fzf --zsh)"

# direnv: per-project environments
eval "$(direnv hook zsh)"




# ------------------------------------------------------------------------------
# ALIASES & FUNCTIONS
# ------------------------------------------------------------------------------
# General
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias ..="cd .."
alias ...="cd ../.."
alias vim='nvim'
alias vi='nvim'
alias lg='lazygit'
alias cat='bat --paging=never'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias glg='git log --graph --oneline --decorate --all'

# Zellij
alias zl="zellij --layout dev-setup" # запуск с кастомным layout
alias za="zellij attach"             # подключение к последней сессии
alias zs="zellij list-sessions"      # список сессий
alias zk="zellij kill-all-sessions"  # убить все сессии

# System specific (Arch Linux)
alias update="yay -Syu"
alias cleanup="sudo pacman -Sc"

# Custom scripts
alias promptgen="bash ~/.local/bin/prompter.sh"
alias soundcloud-dl="/home/panch/dev_projects/my_sound-cloud/.venv/bin/python /home/panch/dev_projects/my_sound-cloud/soundcloud_downloader.py"

# lf - file manager wrapper
lf () {
    tmp="$(mktemp)"
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ] && [ "$dir" != "$(pwd)" ]; then
            cd "$dir"
        fi
    fi
}

# ------------------------------------------------------------------------------
# AUTO-START ZELLIJ
# ------------------------------------------------------------------------------
# Automatically start Zellij on shell startup if not already in a session.
# It attaches to a session named "main" or creates it if it doesn't exist.
# ------------------------------------------------------------------------------
# FINALIZATION
# ------------------------------------------------------------------------------
# Display system info on startup
fastfetch -s ascii
