#!/bin/bash
#Personal dotfiles

PLATFORM='unknown'
if [[ `uname` == 'Darwin' ]]; then
	PLATFORM='mac'
elif [[ `uname` == 'Linux' ]]; then
	PLATFORM='linux'
fi
export PLATFORM
#export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

#source /Users/sdougan/.rvm/scripts/rvm

# Load other scoures from the include folder
if [ -d $HOME/.dotfiles ]; then
	for file in $HOME/.dotfiles/include/*; do
		source $file
	done
fi

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*