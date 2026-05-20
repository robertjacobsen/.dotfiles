# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


DOTFILES=${${(%):-%x}:A:h}

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Auto-follow macOS appearance with dark-mode
CATPPUCCIN_FLAVOR=macchiato
if command -v dark-mode &>/dev/null; then
  [[ $(dark-mode status) == on ]] && CATPPUCCIN_FLAVOR=macchiato || CATPPUCCIN_FLAVOR=latte
fi

# Override by writing a flavor name (latte/frappe/macchiato/mocha) to catppuccin_flavor
[[ -f $DOTFILES/catppuccin_flavor ]] && CATPPUCCIN_FLAVOR=$(<$DOTFILES/catppuccin_flavor)
CATPPUCCIN_FLAVOR=${CATPPUCCIN_FLAVOR}

source $DOTFILES/catppuccin.zsh
zinit snippet https://github.com/catppuccin/zsh-syntax-highlighting/raw/main/themes/catppuccin_${CATPPUCCIN_FLAVOR}-zsh-syntax-highlighting.zsh

# Add in zsh plugins
# Install catppuccin
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# ssh-agent!
zstyle :omz:plugins:ssh-agent identities id_ed25519 id_rsa  # which keys to add
zstyle :omz:plugins:ssh-agent lazy no # only start when needed
zstyle :omz:plugins:ssh-agent quiet yes # suppress "Identity added" output
zinit snippet OMZP::ssh-agent

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

path=("$HOME/.local/bin" $path)

# Shell integrations
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"

# Local, untracked overrides (machine-specific, work-specific, etc.)
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# Aliases
[[ -f $DOTFILES/aliases.zsh ]] && source $DOTFILES/aliases.zsh
[[ -f $DOTFILES/custom_aliases.zsh ]] && source $DOTFILES/custom_aliases.zsh
