#!/bin/bash
#Personal dotfiles

PLATFORM='unknown'
if [[ `uname` == 'Darwin' ]]; then
	PLATFORM='mac'
elif [[ `uname` == 'Linux' ]]; then
	PLATFORM='linux'
fi
export PLATFORM

# Load other scoures from the include folder
if [ -d $HOME/.dotfiles ]; then
	for file in $HOME/.dotfiles/include/*; do
		source $file
	done
fi
