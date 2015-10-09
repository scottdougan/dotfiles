# Dotfiles 
These are my personal dotfiles that I use on a variety of machines.  I made an install script that will automatically install them for me on both my Mac and Linux machines.  I may have gotten a little carried away. The script really doesn't need to be this long and complex, so I thought I'd write a readme to explain what it's doing.  In short, the script will symlink the `.bashrc` (Linux) or `.bash_profile` (Mac) to `.dotfiles/bash_profile` and will symlink all the files located in the config folder to the users home directory. 

## More details
### Install
Going into a little bit more detail, when the script is first called it will check to make sure the dotfiles are not already installed.  I define the scrpt as "installed" when the `.bashrc` (Linux) or `.bash_profile` (Mac) is symlinked to `.dotfiles/bash_profile`.  If the dotfiles are already installed it will try and symlink any new files located in the config folder. 
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
As you can see from the example output above, if the file that is being symlinked to the users home directory already exists the script will make a backup with the file extension `.bak`. If for some reason a backup for the file(s) already exist the script will prompt the user with the option of overwriting them. 
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
If the file doesn't have a backup the user will be asked if they want to keep the current file that symlinked to the .dotfiles or delete it.  If they decide to keep the file the symlink will still be removed but the file will be copied directly into the users home directory. 
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

## Installation
 * Clone this repository
 * Rename the dotfiles folder to .dotfiles 
 * Make sure the .dotfiles folder is placed in your home directory. 

## Usage
Install - Symlinks the necessary files in the .dotfiles folder to the users home directory.
 ```
./install.sh
```

Uninstall - Removes symlinks to the .dotfiles folder and recovers any files using the backups.
 ```
./install.sh -u or --uninstall
```

## Note
* If you don't have anything to put in the config folder you can delete it. The install script will skip trying to symlink config files if the folder is missing.
* The script isn't portable and is only expected to work with bash.
* I'm sure this isn't 100% bug proof. Use at your own risk!