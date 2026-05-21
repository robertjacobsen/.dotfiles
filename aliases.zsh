alias g='git'
alias ga='git add'
alias gb='git branch -vv'
alias gbc='git branch -r --contains'
alias gbr='git branch -r'
alias gc='git cherry -v origin/master'
alias gca='git commit --amend'
alias gcm='git commit'
alias gco='git checkout'
alias gm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gfe='git fetch'
alias gfh='git flathist'
alias gh='git hist'
alias gl='git log'
alias gff='git merge --ff-only @{u}'
alias gpu='git pull'
alias gp='git push'
alias gr='git reset'
alias gru='git remote update'
alias gruff='gru && gff'
alias gs='git status'
alias gsh='git show'
alias gsm='git submodule'
alias gsmu='git submodule update'
alias gst='git status'
alias vim='nvim'
alias zr='exec zsh'

alias grep='grep --color=auto'
alias ls='ls --color=auto'

grall() {
  local repo="${1:-$(basename "$PWD")}"
  repo="${repo%.git}"

  if [ -z "$GITHUB_USER" ] || [ -z "$FORGEJO_USER" ]; then
    echo "GITHUB_USER and FORGEJO_USER must be set (in ~/.zshrc.local)" >&2
    return 1
  fi

  if git remote get-url all >/dev/null 2>&1; then
    echo "remote 'all' already exists; remove it first if you want to rebuild" >&2
    return 1
  fi

  local github_url="$GITHUB_USER/$repo.git"
  local forgejo_url="$FORGEJO_USER/$repo.git"

  git remote add all "$github_url"
  git remote set-url --add --push all "$forgejo_url"
}
