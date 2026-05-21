grall() {
  local repo="${1:-$(basename "$PWD")}"
  repo="${repo%.git}"

  if [ -z "$GITHUB_USER" ] || [ -z "$FORGEJO_USER" ]; then
    echo "GITHUB_USER and FORGEJO_USER must be set (in ~/.zshrc.local)" >&2
    return 1
  fi

  if git remote get-url all >/dev/null 2>&1; then
    echo "remote 'all' already exists; remove it first if you want to recreate" >&2
    return 1
  fi

  local github_url="$GITHUB_USER/$repo.git"
  local forgejo_url="$FORGEJO_USER/$repo.git"

  git remote add all "$github_url"
  git remote set-url --add --push all "$github_url"
  git remote set-url --add --push all "$forgejo_url"
}
