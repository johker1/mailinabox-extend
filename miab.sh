#!/bin/bash

# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Did you leave out sudo?"
	exit
fi

# Clone the Mail-in-a-Box repository if it doesn't exist.
if [ ! -d $HOME/mailinabox ]; then
	if [ ! -f /usr/bin/git ]; then
		echo Installing git . . .
		apt-get -y update
		apt-get install -y git
    echo
	fi

	echo Downloading Mail-in-a-Box LATEST-GIT. . .
	git clone	https://github.com/mail-in-a-box/mailinabox $HOME/mailinabox 
	echo
fi

# Change directory to it.
cd $HOME/mailinabox

# Update it.
if [ -d $HOME/mailinabox  ]; then
	echo Forcing Update Mail-in-a-Box to LATEST-GIT . . .
	git fetch --force
  echo
fi

# Start setup script.
setup/start.sh

