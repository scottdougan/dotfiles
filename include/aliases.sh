#!/bin/bash
# General Aliases

# # Mac
if [[ $PLATFORM == 'mac' ]]; then

	#ls
	alias ls='ls -A'
	alias ll='ls -Al'

	# vim
	alias vim='mvim -v'
	alias vimdiff='mvim -v -d'

	# Open current directory file browser
	alias x='open .'

	# Show/hide files in finder
	alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
	alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

# Linux
elif [[ $PLATFORM == 'linux' ]]; then

	#ls
	alias ls='ls -A --color'
	alias ll='ls -Al --color'

	# Open current directory file browser
	alias x='nautilus .'
fi

#Works on both mac and linux
alias ..='cd ..'
alias ...='cd ../../'