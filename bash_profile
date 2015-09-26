#!/bin/bash
#Author: Scott Dougan
#Personal dotfiles

PLATFORM='unknown'
if [[ `uname` == 'Darwin' ]]; then
	PLATFORM='mac'
elif [[ `uname` == 'Linux' ]]; then
	PLATFORM='linux'
fi
export PLATFORM

# Load dotfiles
if [ -d $HOME/.dotfiles ]; then
	export DOTFILES_DIR="$HOME/.dotfiles"
	for file in $DOTFILES_DIR/include/*
	do
		source $file
	done
fi
