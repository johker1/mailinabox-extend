#!/bin/bash

# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Did you leave out sudo?"
	exit
fi

# Clone the Mail-in-a-Box EXTENDED repository if it doesn't exist.
if [ ! -d $HOME/mailinabox-extended ]; then
	if [ ! -f /usr/bin/git ]; then
		echo Installing git . . .
		apt-get -y update
		apt-get install -y git
    echo
	fi

	echo Downloading Mail-in-a-Box-EXTENDED. . .
	git clone	https://github.com/johker1/mailinabox-extend.git $HOME/mailinabox-extended
	echo
fi

# Change directory to it.
cd $HOME/mailinabox-extended

# Update it.
if [ -d $HOME/mailinabox-extended  ]; then
	echo Forcing Update Mail-in-a-Box to LATEST-GIT . . .
	git fetch --force
  echo
fi


