# Dotfiles 
These are my personal dotfiles that I use on a variety of machines.  I made an install script that will automatically install them for me on both my Mac and Linux machines.  The script will either symlink `.bashrc` (Linux) or `.bash_profile` (Mac) to `.dotfiles/bash_profile` and symlink everything located under `config/` to the user's home directory.   If any of the files being linked already exists a backup of the file will be created with the extension `.bak`.  Calling the `install script` with the -u or --uninstall parameter will remove the symlink and restore the original files from the backups (if they exist).  More information can be found below in the `Install script` section.  Use both the install script and the dotfiles at your own risk.

## Contents
Brief description of the dotfiles folder layout.

### `config/`
Everything here will be symlinked to the user's home directory with a `.` appended to the filename. Mostly configuration files such as gitconfig, vimrc, etc are located here. As mentioned in the introduction, if any of the files being linked already exists in the user's home directory a backup of the file will be created with the extension `.bak`.  If for some reason a `.bak` for the file also already exists the user will be prompted if they would like to overwrite them.

### `include/`
All the files located here are scoured from the `bash_profile`.  This makes the `bash_profile` a little more organized by separating critical parts into small manageable files.  This effectively allows me to find bugs, add new features or change current terminal behaviour. 

### `scripts/`
This folder contains various helper scripts.  For example, two of the scripts (depending on if you're on Mac or Linux) will set the terminal coloured to be solorized (Dark or Light).  While others such as `git_prompt.sh` help with terminal appearance by showing the user which git branch they are currently on under Linux.  This is also a place where I put useful scripts I may need so I don't forget where they are in the future.


## Installation
 * Clone this repository into your home directory
 * Rename the dotfiles folder to .dotfiles 
 * Run `./install.sh` and follow the prompts (If they come up)


## Usage
**Install** - Symlinks the necessary files in the .dotfiles folder to the user's home directory.  If any of the files being linked already exists a backup of the file will be created with the extension `.bak`.  If for some reason a `.bak` for the file also already exists the user will be promoted if they would like to overwrite them. More information can be found below in the `Install script` section.
 ```
./install.sh
```

**Uninstall** - Removes symlinks to the .dotfiles folder and recovers any files from the `.bak` file backups (if they exist). Or the script will prompt the user to either keep the current file or delete it. More information can be found below in the `Install script` section. 
 ```
./install.sh -u or --uninstall
```


## Install script
I may have gotten a little carried away with my installation script.  It really doesn't need to be this long and complex, but since it is I thought I'd better write a section to explain what it's doing in a little bit more detail.  

When the script is first called it will check to make sure the dotfiles are not already installed.  I define the script as "installed" when the `.bashrc` (Linux) or `.bash_profile` (Mac) is symlinked to the `.dotfiles/bash_profile` file.  If the dotfiles are already installed it will try and symlink any new files located in the config folder. 
```
 --- .dotfiles already installed, linking any new config files --- 

No new config files to link.

 --- Success! ---
```
If they are not already installed it will then try and install them.
```

 --- Installing .dotfiles! --- 

Backed up .bashrc to /home/dougan/.bashrc.bak
Linking /home/dougan/.dotfiles/bash_profile -> /home/dougan/.bashrc

 --- Linking config files --- 

Backed up .bah to /home/dougan/.bah.bak
Linking /home/dougan/.dotfiles/config/bah -> /home/dougan/.bah

Backed up .gitconfig to /home/dougan/.gitconfig.bak
Linking /home/dougan/.dotfiles/config/gitconfig -> /home/dougan/.gitconfig

Backed up .test to /home/dougan/.test.bak
Linking /home/dougan/.dotfiles/config/test -> /home/dougan/.test

 --- Success! ---
```
As you can see from the example output above, if the file that is being symlinked to the user's home directory already exists the script will make a backup with the file extension `.bak`. If for some reason a backup for the file(s) already exist the script will prompt the user with the option of overwriting them. 
```
Stopped: Backup file(s) already exist
.bashrc.bak
.bah.bak
.gitconfig.bak
.test.bak
Would you like to overwrite them with the current versions of the files? (y/n):
```
#### Note
The script will not backup files that are already symlinked to the .dotfiles folder. This shouldn't ever happen but it got a bit annoying when I was testing. 

### Uninstall
Calling the script with the `-u` or `--uninstall` parameter will remove the symlinks to the .dotfiles folder and recover any files using the backups.  Once the files have been recovered the script will prompt the user if they want to remove the old .bak files. 
```
 --- Recovering config files from backups --- 

Recovering /home/dougan/.bah from /home/dougan/.bah.bak

Recovering /home/dougan/.gitconfig from /home/dougan/.gitconfig.bak

Recovering /home/dougan/.test from /home/dougan/.test.bak

Would you like to delete the backup files? (y/n):y

Deleting backup files:
.bashrc.bak
.bah.bak
.gitconfig.bak
.test.bak

 --- Success! ---
```
If the file doesn't have a backup the user will be asked if they want to keep the current file that symlinked to the .dotfiles or delete it.  If they decide to keep the file the symlink will still be removed but the file will be copied directly into the user's home directory. 
```
 --- Recovering config files from backups --- 

Recovering /home/dougan/.bah from /home/dougan/.bah.bak

Recovering /home/dougan/.gitconfig from /home/dougan/.gitconfig.bak

File: .test does not have a backup.
Would you like to keep the current file? (y/n):y
Keeping .test

Would you like to delete the backup files? (y/n):y

Deleting backup files:
.bashrc.bak
.bah.bak
.gitconfig.bak

 --- Success! ---
```


## Note
* If you don't have anything to put in the config folder you can delete it. The install script will skip trying to symlink config files if the folder is missing.
* The script isn't portable and is only expected to work with bash.
* I'm sure this isn't 100% bug proof. Use at your own risk!