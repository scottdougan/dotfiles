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
    fi
elif [[ $PLATFORM == "linux" ]]; then
    # Load git_prompt for __git_ps1
    if [ -f "$HOME/.dotfiles/scripts/git-prompt.sh" ]; then
        source $HOME/.dotfiles/scripts/git-prompt.sh
        PROMPT_COMMAND=git_prompt
    fi
fi

prompt () {
    local exit_status=${1:-$?} # Save exit status since the if statments below will change it.
    local host
    local venv
    local git_branch=$2
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
    PS1="${venv}${current_time} \u${host}:\W$git_branch$RESET\n\$ "
}

git_prompt () {
    prompt $? "$BR_MAGENTA$(__git_ps1)$RESET"
}