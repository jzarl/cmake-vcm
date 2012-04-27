#!/bin/bash
##
# Author: Johannes Zarl <isilmendil@gmx.net>
# This file is in the public domain.
##

if [ ! -r "$1" ]
then
	echo "File not readable!"
	exit 1
fi

# clear old clipboard contents (the files are not too small ;-)
qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardHistory
# set clipboard
qdbus org.kde.klipper /klipper org.kde.klipper.klipper.setClipboardContents "`cat "$1"`"
