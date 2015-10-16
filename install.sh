#!/bin/bash
#Installs dotfiles 

function backupFile {
	local FILE="$1"

	if [ -f "$FILE" ]; then
		cp $FILE $FILE.bak
		echo "Backed up $(basename "$FILE") to $FILE.bak"
	fi
}

function symLink {
	local FROM="$1"
	local TO="$2"

	backupFile $TO
	echo "Linking $FROM -> $TO"
	rm -f $TO
	ln -s $FROM $TO
}

function recover {
	local FILE="$1"
	local DELETE_NO_BACKUP="$2"

	if [ -f $FILE.bak ]; then
		echo "Recovering $FILE from $FILE.bak"
		rm $FILE
		cp $FILE.bak $FILE
	else
		echo "File: $(basename "$FILE") does not have a backup."
		read -p "Would you like to keep the current file? (y/n):" -n 1 -r
		if [[ ! $REPLY =~ ^[Nn]$ ]]; then
			echo -e "\nKeeping $(basename "$FILE")"
			FILE_LOCATION=$(readlink $FILE)
		 	rm $FILE
		 	cp $FILE_LOCATION $FILE
		 	return
		fi
		echo -e "\nDeleting $FILE - no backup"
	 	rm $FILE
	fi
}

function OverwriteBackupsQuestion {
	local BACKUP_FILES=("${!1}")

	if [ -n "$BACKUP_FILES" ]; then
	 	echo "Stopped: Backup file(s) already exist" 
	 	for FILE in "${BACKUP_FILES[@]}"; do
			echo $FILE
		done
		read -p "Would you like to overwrite them with the current versions of the files? (y/n):" -n 1 -r
		echo ""
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			exit 1
		fi
	fi
}

function linkNewConfigs {
	local BACKUP_FILES=()
	local NEW=0

	# Checks for existing config file backups on new config files.
	for FILE in $HOME/.dotfiles/config/*; do
		local BASEFILE=$(basename "$FILE")
		if [ -f "$HOME/.$BASEFILE" ] && [[ $(readlink $HOME/.$BASEFILE) != "$HOME/.dotfiles/config/$BASEFILE" ]] && [ -f "$HOME/.$BASEFILE.bak" ]; then
			BACKUP_FILES+=(.$BASEFILE.bak)
		fi
	done

	# This is only here so spacing is consistent
	if [ -n "$BACKUP_FILES" ]; then
		OverwriteBackupsQuestion BACKUP_FILES[@]
		echo ""
	fi

	for FILE in $HOME/.dotfiles/config/*; do
		BASEFILE=$(basename "$FILE")
		if [[ $(readlink $HOME/.$BASEFILE) != "$HOME/.dotfiles/config/$BASEFILE" ]]; then
			symLink $HOME/.dotfiles/config/$BASEFILE $HOME/.$BASEFILE
			NEW=1
			echo ""
		fi
	done
	if [ $NEW != 1 ]; then
		echo -e "No new config files to link.\n"
	fi
}

function freshInstall {
	local BASH_FILE="$1"
	local BACKUP_FILES=()
	local NEW=0
	# Makes sure everything is in order for a fresh install before doing anything.

	# Checks to make sure there are .dotfiles to be installed.
	if [ ! -f "$HOME/.dotfiles/bash_profile" ]; then
		echo "Failed: $HOME/.dotfiles/bash_profile does not exist." 1>&2
		exit 1
	fi
	# Makes sure there isn't already a bash profile backup.
	if [ -f "$HOME/$BASH_FILE.bak" ]; then
		BACKUP_FILES+=($BASH_FILE.bak)
	fi
	# Checks for existing config file backups.
	for FILE in $HOME/.dotfiles/config/*; do
		local BASEFILE=$(basename "$FILE")
		if [ -f "$HOME/.$BASEFILE.bak" ] && [ -f "$HOME/.$BASEFILE" ] && [[ $(readlink $HOME/.$BASEFILE) != "$HOME/.dotfiles/config/$BASEFILE" ]]; then
			BACKUP_FILES+=(.$BASEFILE.bak)
		fi
	done
	OverwriteBackupsQuestion BACKUP_FILES[@]

	echo -e "\n --- Installing .dotfiles! --- \n"
	symLink $HOME/.dotfiles/bash_profile $HOME/$BASH_FILE
	echo ""

	# Fianlly Link all the config files.
	if [ -d $HOME/.dotfiles/config/ ]; then
		echo -e " --- Linking config files --- \n"
		for FILE in $HOME/.dotfiles/config/*; do
			BASEFILE=$(basename "$FILE")
			if [[ $(readlink $HOME/.$BASEFILE) != "$HOME/.dotfiles/config/$BASEFILE" ]]; then
				symLink $HOME/.dotfiles/config/$BASEFILE $HOME/.$BASEFILE
				NEW=1
				echo ""
			fi
		done
		if [ $NEW != 1 ]; then
			echo -e "No config files to link.\n"
		fi
	fi
}

function uninstall {
	local BASH_FILE="$1"

	# Some basic checks
	if [[ $(readlink $HOME/$BASH_FILE) != "$HOME/.dotfiles/bash_profile" ]]; then
		echo -e "Failed: $BASH_FILE is not linked to $HOME/.dotfiles/bash_profile \n.dotfiles are not installed." 1>&2
		exit;
	fi

	echo -e "\n --- Uninstalling .dotifles --- \n"
	recover $HOME/$BASH_FILE
	if [ -f $HOME/$BASH_FILE.bak ]; then
		BACKUP_FILES+=($BASH_FILE.bak)
	fi

	if [ -d $HOME/.dotfiles/config/ ]; then
		# Recover only our config files.
		echo -e "\n --- Recovering config files from backups --- \n"
		for FILE in $HOME/.dotfiles/config/*; do
			BASEFILE=$(basename "$FILE")
			# Make sure the file is symlinked to our config folder otherwise skip it.
			if [[ $(readlink $HOME/.$BASEFILE) != "$HOME/.dotfiles/config/$BASEFILE" ]]; then
				echo -e "Error: Skipping file $HOME/.$BASEFILE \n.$BASEFILE is not linked to .dotfiles/config/* "
				continue
			fi
			recover $HOME/.$BASEFILE
			echo ""
			if [ -f $HOME/.$BASEFILE.bak ]; then
				BACKUP_FILES+=(.$BASEFILE.bak)
			fi
		done
		if [ -n "$BACKUP_FILES" ]; then
			read -p "Would you like to delete the backup files? (y/n):" -n 1 -r
			echo ""
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo -e "\nDeleting backup files:"
				for FILE in "${BACKUP_FILES[@]}"; do
					echo $FILE
					rm -f $HOME/$FILE
				done
			fi
			echo ""
		fi
	fi
}

# Main 
if [ $(uname) == "Darwin" ]; then
	BASH_FILE=".bash_profile"
elif [ $(uname) == 'Linux' ]; then
	BASH_FILE=".bashrc"
else 
	echo "Failed: Operating system \"$(uname)\" not supported." 1>&2
	exit 1
fi

# Install new config files.
if [ $# == 0 ] && [[ $(readlink $HOME/$BASH_FILE) == "$HOME/.dotfiles/bash_profile" ]]; then 
	if [ -d $HOME/.dotfiles/config/ ]; then
		echo -e "\n --- .dotfiles already installed, linking any new config files --- \n"
		linkNewConfigs
	else 
		echo -e "\n --- .dotfiles already installed, nothing to do --- \n"
	fi
# Fresh Install of dotfiles.
elif [ $# == 0 ]; then
	freshInstall $BASH_FILE
# Uninstall dotfiles.
elif [ $# == 1 ] && [ $1 == "-u" ] || [ $1 == "-Uninstall" ]; then
	uninstall $BASH_FILE
else 
	echo "Usage: ./install (Optional argument: -u, --Uninstall)" 1>&2
	exit;
fi

echo " --- Success! ---"