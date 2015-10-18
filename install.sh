#!/bin/bash
#Installs dotfiles 

if [[ $(uname) == "Darwin" ]]; then
    BASH_FILE=".bash_profile"
elif [[ $(uname) == 'Linux' ]]; then
    BASH_FILE=".bashrc"
else 
    echo "Failed: Operating system \"$(uname)\" not supported." 1>&2
    exit 1
fi

backup_file () {
    local file="$1"

    if [ -f "$file" ]; then
        cp "$file" "$file.bak"
        echo "Backed up $(basename "$file") to $file.bak"
    fi
}

symlink () {
    local from="$1"
    local to="$2"

    backup_file "$to"
    echo "Linking $from -> $to"
    rm -f "$to"
    ln -s "$from" "$to"
}

recover () {
    local file="$1"

    if [ -f "$file.bak" ]; then
        echo "Recovering $file from $file.bak"
        rm "$file"
        cp "$file.bak" "$file"
    else
        echo "file: $(basename "$file") does not have a backup."
        read -p "Would you like to keep the current file? (y/n):" -n 1 -r
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            echo -e "\nKeeping $(basename "$file")"
            file_location=$(readlink "$file")
            rm "$file"
            cp "$file_location" "$file"
            return
        fi
        echo -e "\nDeleting $file - no backup"
        rm "$file"
    fi
}

overwrite_backups_question () {
    local backup_files=("${!1}")

    if (( ${#backup_files[@]} > 0 )); then
        echo "Stopped: Backup file(s) already exist" 
        for file in "${backup_files[@]}"; do
            echo "$file"
        done
        read -p "Would you like to overwrite them with the current versions of the files? (y/n):" -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

link_new_configs () {
    local backup_files=()
    local new=0
    local basefile

    # Checks for existing config file backups on new config files.
    for file in $HOME/.dotfiles/config/*; do
        basefile=$(basename "$file")
        if [[ -f $HOME/.$basefile ]] && [[ $(readlink "$HOME/.$basefile") != "$HOME/.dotfiles/config/$basefile" ]] && [ -f "$HOME/.$basefile.bak" ]; then
            backup_files+=(.$basefile.bak)
        fi
    done

    # This is only here so spacing is consistent
    if (( ${#backup_files[@]} > 0 )); then
        overwrite_backups_question backup_files[@]
        echo ""
    fi

    for FILE in $HOME/.dotfiles/config/*; do
        basefile=$(basename "$FILE")
        if [[ $(readlink "$HOME/.$basefile") != "$HOME/.dotfiles/config/$basefile" ]]; then
            symlink "$HOME/.dotfiles/config/$basefile" "$HOME/.$basefile"
            new=1
            echo ""
        fi
    done
    if (( new != 1 )); then
        echo -e "No new config files to link.\n"
    fi
}

fresh_install () {
    local backup_files=()
    local new=0
    local basefile
    # Makes sure everything is in order for a fresh install before doing anything.

    # Checks to make sure there are .dotfiles to be installed.
    if [[ ! -f $HOME/.dotfiles/bash_profile ]]; then
        echo "Failed: $HOME/.dotfiles/bash_profile does not exist." 1>&2
        exit 1
    fi
    # Makes sure there isn't already a bash profile backup.
    if [[ -f $HOME/$BASH_FILE.bak ]]; then
        backup_files+=($BASH_FILE.bak)
    fi
    # Checks for existing config file backups.
    for file in $HOME/.dotfiles/config/*; do
        basefile=$(basename "$file")
        if [[ -f $HOME/.$basefile.bak ]] && [[ -f $HOME/.$basefile ]] && [[ $(readlink "$HOME/.$basefile") != "$HOME/.dotfiles/config/$basefile" ]]; then
            backup_files+=(.$basefile.bak)
        fi
    done
    overwrite_backups_question backup_files[@]

    echo -e "\n --- Installing .dotfiles! --- \n"
    symlink "$HOME/.dotfiles/bash_profile" "$HOME/$BASH_FILE"
    echo ""

    # Fianlly Link all the config files.
    if [[ -d $HOME/.dotfiles/config/ ]]; then
        echo -e " --- Linking config files --- \n"
        for file in $HOME/.dotfiles/config/*; do
            basefile=$(basename "$file")
            if [[ $(readlink "$HOME/.$basefile") != "$HOME/.dotfiles/config/$basefile" ]]; then
                symlink "$HOME/.dotfiles/config/$basefile" "$HOME/.$basefile"
                new=1
                echo ""
            fi
        done
        if (( new != 1 )); then
            echo -e "No config files to link.\n"
        fi
    fi
}

uninstall () {
    local backup_files
    local basefile

    # Some basic checks
    if [[ $(readlink "$HOME/$BASH_FILE") != "$HOME/.dotfiles/bash_profile" ]]; then
        echo -e "Failed: $BASH_FILE is not linked to $HOME/.dotfiles/bash_profile \n.dotfiles are not installed." 1>&2
        exit;
    fi

    echo -e "\n --- Uninstalling .dotifles --- \n"
    recover "$HOME/$BASH_FILE"
    if [[ -f $HOME/$BASH_FILE.bak ]]; then
        backup_files+=($BASH_FILE.bak)
    fi

    if [[ -d $HOME/.dotfiles/config/ ]]; then
        # Recover only our config files.
        echo -e "\n --- Recovering config files from backups --- \n"
        for file in $HOME/.dotfiles/config/*; do
            basefile=$(basename "$file")
            # Make sure the file is symlinked to our config folder otherwise skip it.
            if [[ $(readlink "$HOME/.$basefile") != "$HOME/.dotfiles/config/$basefile" ]]; then
                echo -e "Error: Skipping file $HOME/.$basefile \n.$basefile is not linked to .dotfiles/config/* "
                continue
            fi
            recover "$HOME/.$basefile"
            echo ""
            if [[ -f $HOME/.$basefile.bak ]]; then
                backup_files+=(.$basefile.bak)
            fi
        done
        if (( ${#backup_files[@]} > 0 )); then
            read -p "Would you like to delete the backup files? (y/n):" -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "\nDeleting backup files:"
                for file in "${backup_files[@]}"; do
                    echo "$file"
                    rm -f "$HOME/$file"
                done
            fi
            echo ""
        fi
    fi
}

# Main 

# Install new config files.
if (( $# == 0 )) && [[ $(readlink "$HOME/$BASH_FILE") == "$HOME/.dotfiles/bash_profile" ]]; then 
    if [[ -d $HOME/.dotfiles/config/ ]]; then
        echo -e "\n --- .dotfiles already installed, linking any new config files --- \n"
        link_new_configs
    else 
        echo -e "\n --- .dotfiles already installed, nothing to do --- \n"
    fi
# Fresh Install of dotfiles.
elif (( $# == 0 )); then
    fresh_install
# Uninstall dotfiles.
elif (( $# == 1 )) && ([[ "$1" == "-u" ]] || [[ "$1" == "--uninstall" ]]); then
    uninstall
else 
    echo "Usage: ./install (Optional argument: -u, --uninstall)" 1>&2
    exit
fi

echo " --- Success! ---"
