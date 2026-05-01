# If not running interactively, don't do anything
[ -z "$PS1" ] && return

CONFIGS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

current_branch() {
    git branch 2>/dev/null | grep "^*" | sed -e "s/^* \(.*\)$/ ‹\1›/" -e "s/[()]+//g"
}

current_directory_short() {
    echo $PWD | perl -e'$p=<STDIN>;$p=~s{^/(Users|home)/[^/]+}{~};@a=split/\//,$p;@c=();@b=@a>1?reverse(pop@a,pop@a):();for(@a){push@c,substr($_,0,1);}push@c,@b;print join"/",@c;'
}

. ~/$CONFIGS_DIR/colors
PS1="\[$RESET$BOLD\][\$([[ \"$SHOWHOST\" -ge 1 ]] && echo -n $HOSTNAME)\[$RESET\]\$([[ \"$SHOWHOST\" -ge 1 ]] && echo -n ':')\[$PSCOLOR\]\$(current_directory_short)\[$RESET$BOLD\]]\[$PURPLE\]\$(current_branch)\[$RESET$BOLD\]\$ \[$RESET\]"
PS2="\[$ORANGE\]→ \[$RESET\]"

if [[ ! "$(whoami)" =~ r(obertj?|ja) ]]; then
    PS1="\[$RESET$BOLD\]\u\[$BOLD$WHITE\]\[$RESET$PSCOLOR\] -> $PS1"
fi

#UH="\[\033[02;32m\]\u\033[00m\] / \033[01;34m\]nef\[\033[00m\] :"
#PS1="$UH \w\[\033[1;36m\]\$(current_branch)\[\033[00m\]\n\$ "

# Set the title of the terminal to the current hostname.
echo -ne "\033]0;$HOSTNAME\007"

export LC_ALL=en_US.UTF-8

# Load aliases
. ~/$CONFIGS_DIR/aliases

# Load git auto-completion
. ~/$CONFIGS_DIR/git-completion.bash

# Fix PATH for homebrew
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:${PATH}

# Always have 256 color
if [[ $STY ]]; then
    export TERM=screen-256color
else
    export TERM=xterm-256color
fi

# Add SSH-agent for the win. Carefully stolen from the ZSH ssh-agent plugin,
# which was based off of http://www.cygwin.com/ml/cygwin/2001-06/msg00537.html
SSH_ENV=$HOME/.ssh/environment

function start_agent {
  /usr/bin/env ssh-agent | sed 's/^echo/#echo/' > $SSH_ENV
  chmod 600 $SSH_ENV
  . $SSH_ENV > /dev/null

  # Find all keys we might have and add them.
  find ~/.ssh -maxdepth 1 -name 'id_*' -not -name '*.pub'  -exec /usr/bin/ssh-add {} \;
}

# Source SSH settings, if applicable
if [ -f "$SSH_ENV" ]; then
  . $SSH_ENV > /dev/null
  ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ > /dev/null || {
    rm $SSH_ENV;
    start_agent;
  }
else
  start_agent;
fi
