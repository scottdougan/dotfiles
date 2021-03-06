#!/bin/bash
#Referenced from Mark Story and Alex Vermeulen.
#This script customizes the appearance of the shell.

# Colours
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
MAGENTA="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"
BR_RED="\[\033[1;31m\]"
BR_MAGENTA="\[\033[1;35m\]"
RESET="\[\033[0m\]"

PROMPT_COMMAND=prompt

# Grep colour
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

if [[ $PLATFORM == "mac" ]]; then
    # Load git_completion for __git_ps1
    if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
        source $(brew --prefix)/etc/bash_completion
        PROMPT_COMMAND=git_prompt
         if [ -f "$HOME/.hgrc" ]; then
            PROMPT_COMMAND=git_hg_prompt
         fi
    elif [ -f "$HOME/.hgrc" ]; then
        PROMPT_COMMAND=hg_prompt
    fi
elif [[ $PLATFORM == "linux" ]]; then
    # Load git_prompt for __git_ps1
    if [ -f "$HOME/.dotfiles/scripts/git-prompt.sh" ]; then
        source $HOME/.dotfiles/scripts/git-prompt.sh
        PROMPT_COMMAND=git_prompt
        if [ -f "$HOME/.hgrc" ]; then
            PROMPT_COMMAND=git_hg_prompt
        fi
    elif [ -f "$HOME/.hgrc" ]; then
        PROMPT_COMMAND=hg_prompt
    fi
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


prompt () {
    local exit_status=${1:-$?} # Save exit status since the if statments below will change it.
    local host
    local venv
    local branch=$2
    local current_time="$GREEN[$CYAN\D{%H:%M:%S}$GREEN]$RESET"

    if [[ -n $SSH_CLIENT ]]; then
        host=@$WHITE$(echo "$HOSTNAME" | cut -d '.' -f 1)$RESET
    fi

    if [[ $VIRTUAL_ENV != '' ]]; then
        venv="$WHITE(${VIRTUAL_ENV##*/}) $RESET"
    fi

    if [[ $exit_status != 0 ]]; then
        current_time="$RED[$CYAN\D{%H:%M:%S}$RED]$RESET"
    fi
    PS1="${venv}${current_time} \u${host}:\W$branch$RESET\n\$ "
}

git_prompt () {
    prompt $? "$BR_MAGENTA$(__git_ps1)$RESET"
}

hg_prompt () {
    local exit_status=$? # Save exit status since the command below will change it.
    local hg_prompt=$(hg prompt '{ ({branch})}{status}' 2> /dev/null)

    prompt $exit_status "$BR_MAGENTA $hg_prompt$RESET"
}

git_hg_prompt () {
    local exit_status=$? # Save exit status since the command below will change it.
    local hg_prompt=$(hg prompt '{ ({branch})}{status}' 2> /dev/null)

    prompt $exit_status "$BR_MAGENTA$(__git_ps1)$hg_prompt$RESET"
}
