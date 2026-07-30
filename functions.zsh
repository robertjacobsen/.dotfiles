# Force the display mode (dark/light) or fall back to the system, then reload.
zfm() {
  if [[ $# -eq 0 ]]; then
    local forced=""
    [[ -f $DOTFILES/force_display_mode ]] && forced=$(<$DOTFILES/force_display_mode)
    case "$forced" in
      dark|light) echo "$forced (forced)" ;;
      *)          echo "$CATPPUCCIN_FLAVOR (system)" ;;
    esac
    return 0
  fi
  case "$1" in
    dark|light)
      print -r -- "$1" > "$DOTFILES/force_display_mode"
      ;;
    system)
      rm -f "$DOTFILES/force_display_mode"
      ;;
    *)
      echo "usage: zfm [dark|light|system]" >&2
      return 1
      ;;
  esac
  exec zsh
}

# Machine-local Ghostty overrides, layered on top of ghostty/config by its
# optional ?<kind>-override includes.
typeset -gA _ghst_keys=(theme theme font font-family size font-size)

_ghst_candidates() {
  case $1 in
    theme) ghostty +list-themes --plain | sed -E 's/ \((resources|user)\)$//' ;;
    font)  ghostty +list-fonts | grep -v '^[[:space:]]' | grep . ;;
  esac
}

_ghst_show() {
  local kind=$1 key=$_ghst_keys[$1] origin=forced value
  value=$(sed -n "s/^$key = \(..*\)$/\1/p" $DOTFILES/ghostty/$kind-override 2>/dev/null)
  if [[ -z $value ]]; then
    origin=config
    value=$(sed -n "s/^$key = \(..*\)$/\1/p" $DOTFILES/ghostty/config)
  fi
  printf '%-5s %s (%s)\n' $kind $value $origin
}

ghst() {
  local kind=$1
  if [[ -z $kind ]]; then
    for kind in theme font size; do _ghst_show $kind; done
    return 0
  fi
  if [[ -z $_ghst_keys[$kind] ]]; then
    echo "usage: ghst [theme|font|size] [<value>|system|list]" >&2
    return 1
  fi
  shift

  local override=$DOTFILES/ghostty/$kind-override value="$*"
  case $value in
    '')
      _ghst_show $kind
      return 0
      ;;
    list)
      if [[ $kind == size ]]; then
        echo "ghst size takes a number, not a list" >&2
        return 1
      fi
      _ghst_candidates $kind
      return 0
      ;;
    system)
      rm -f $override
      ;;
    *)
      if [[ $kind == size ]]; then
        if [[ $value != <->(|.<->) ]]; then
          echo "not a font size: $value" >&2
          return 1
        fi
      elif ! _ghst_candidates $kind | grep -qxF -- "$value"; then
        echo "unknown $kind: $value" >&2
        return 1
      fi
      if [[ $kind == font ]]; then
        # font-family is repeatable, so reset the list first or the name becomes
        # a fallback behind the config's font instead of replacing it.
        { print -- 'font-family = '; print -r -- "font-family = $value" } > $override
      else
        print -r -- "$_ghst_keys[$kind] = $value" > $override
      fi
      ;;
  esac
  echo "reload Ghostty (cmd+shift+,) to apply"
}

_ghst() {
  local -a kinds=('theme:color theme' 'font:font family' 'size:font size')
  if (( CURRENT == 2 )); then
    _describe -t settings setting kinds
    return
  fi

  local kind=$words[2]
  [[ -n $_ghst_keys[$kind] ]] || return 1

  local -a extra=(system)
  [[ $kind == size ]] || extra+=(list)
  if (( CURRENT == 3 )); then
    _describe -t actions action extra
  fi
  [[ $kind == size ]] && return

  # Values contain spaces, so match candidates against the words typed so far
  # and offer only the remainder of each match.
  local prefix="${(j: :)words[3,CURRENT-1]}"
  [[ -n $prefix ]] && prefix+=' '
  local -a matches=(${(M)${(f)"$(_ghst_candidates $kind)"}:#$prefix*})
  compadd -- ${matches#$prefix}
}
compdef _ghst ghst

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
