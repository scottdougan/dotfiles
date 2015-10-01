#!/bin/bash
#Installs dotfiles 

# Makes sure everything is in order before doing anything.
function init_checks {
	local BASH_FILE="$1"
	local FAILED_FILES

	# Checks to make sure there are .dotfiles to be installed.
	if [ ! -f "$HOME/.dotfiles/bash_profile" ]; then
		echo "Stopped: $HOME/.dotfiles/bash_profile does not exist!" 1>&2
		exit 1
	fi

	# Makes sure there isn't already a bash profile backup.
	if [ -f "$HOME/$BASH_FILE.bak" ]; then
		FAILED_FILES="$BASH_FILE.bak\n"
	fi

	# Checks for existing config file backups.
	if [ -d $HOME/.dotfiles/config/ ]; then
		for FILE in $HOME/.dotfiles/config/*; do
			local BASEFILE=$(basename "$FILE")
			if [ -f "$HOME/.$BASEFILE.bak" ] && [ -f "$HOME/.$BASEFILE" ]; then
				FAILED_FILES="$FAILED_FILES.$BASEFILE.bak\n"
			fi
		done
	fi

	if [ -n "$FAILED_FILES" ]; then
		echo -e "Stopped: Backup file(s) already exist \n$(echo -e "$FAILED_FILES" | tr -d '\\n')" 1>&2
		read -p "Would you like to overwrite them with the current versions of the files? (y/n):" -n 1 -r
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			echo ""
			exit 1
		fi
	fi
	echo -e "\n --- Installing .dotfiles! --- \n"
}

function backup_file {
	local FILE="$1"

	if [ -f "$FILE" ]; then
		cp $FILE $FILE.bak
		echo "Backed up $(basename "$FILE") to $FILE.bak"
	fi
}

function sym_link {
	local FROM="$1"
	local TO="$2"

	backup_file $TO
	echo "Linking $FROM -> $TO"
 	rm -f $TO
 	ln -s $FROM $TO
}

if [[ `uname` == 'Darwin' ]]; then
	init_checks ".bash_profile"
	sym_link $HOME/.dotfiles/bash_profile $HOME/.bash_profile
elif [[ `uname` == 'Linux' ]]; then
	init_checks ".bashrc"
	sym_link $HOME/.dotfiles/bash_profile $HOME/.bashrc
 else 
	echo "Failed: Operating system \"$(uname)\" not supported"
	exit 1
fi

# Fianlly Link all the config files.
echo -e "\n --- Linking config files! --- \n"
if [ -d $HOME/.dotfiles/config/ ]; then
	for FILE in $HOME/.dotfiles/config/*; do
		BASEFILE=$(basename "$FILE")
		sym_link $HOME/.dotfiles/config/$BASEFILE $HOME/.$BASEFILE
		echo ""
	done
fi

echo " --- Success! ---"