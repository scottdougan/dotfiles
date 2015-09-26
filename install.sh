#!/bin/bash
#Author: Scott Dougan
#Installs dotfiles 

# Checks to make sure there are .dotfiles to be installed.
if [ ! -f "$HOME/.dotfiles/bash_profile" ]; then
	echo "Failed: ~/.dotfiles bash_profile does not exist!"
	exit 1
fi

# Function for backing up bash profiles
function backup_file {
	local FILE_NAME="$1"

	if [ ! -f "$HOME/$FILE_NAME" ]; then
		echo "Failed: Could not backup $FILE_NAME - $FILE_NAME does not exist!"
    	exit 1
	fi

    if [ ! -f "$HOME/$FILE_NAME.bak" ]; then
		cp $HOME/$FILE_NAME $HOME/$FILE_NAME.bak
		echo "Backed up $FILE_NAME to $FILE_NAME.bak"
	else
    	echo "Failed: Could not backup $FILE_NAME - $FILE_NAME.bak already exists."
    	exit 1
	fi
}

# Backup old bash profile and symbolic link the new one.
if [[ `uname` == 'Darwin' ]]; then
	backup_file ".bash_profile"
	rm $HOME/.bash_profile
	ln -s $HOME/.dotfiles/bash_profile $HOME/.bash_profile
elif [[ `uname` == 'Linux' ]]; then
	backup_file ".bashrc"
	rm $HOME/.bashrc
	ln -s $HOME/.dotfiles/bash_profile $HOME/.bashrc
else 
	echo "Failed: Operating system \"$(uname)\" not supported"
	exit 1
fi
echo "Success!"