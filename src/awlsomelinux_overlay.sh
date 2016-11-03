#!/bin/sh

## AwlsomeLinux Overlay Creation Script
## Created by AwlsomeAlex (GNU GPLv3)

##############################
# -------------------------- #
# AwlsomeLinux Configuration #
# -------------------------- #
##############################

SRC_DIR=$(pwd)

##########################
# AwlsomeLinux Variables #
##########################


#############################
# ------------------------- #
# AwlsomeLinux Image Script #
# ------------------------- #
##############################


###########################
# GLIBC Full Installation #
###########################

install_glibc() {
	echo "--- GLIBC Full Installation Start ---"
	
	# Check if Glibc is Built
	if [ ! -d $SRC_DIR/core/install/glibc ] ; then
		echo "GLIBC Full Installation Failed - GLIBC was never built. Please build GLIBC!"
		exit 1
	fi
	
	# Prepare GLIBC Full Installation Work Area
	rm -rf overlay/work/glibc
	mkdir overlay/work/glibc/lib
	
	# Change Directory to 'overlay/work/glibc/lib'
	cd overlay/work/glibc/lib
	
	# Copy all GLIBC Libraries to OverlayFS
	find . -type l -exec cp {} $SRC_DIR/core/install/glibc/lib \;
	echo "All GLIBC Libraries have been copied."
	
	cd $SRC_DIR/overlay/work/glibc/lib

	for FILE_DEL in $(ls *.so)
		do
			FILE_KEEP=$(ls $FILE_DEL.*)

		if [ ! "$FILE_KEEP" = "" ] ; then
			# We remove the shorter file and replace it with symbolic link.
			rm $FILE_DEL
			ln -s $FILE_KEEP $FILE_DEL
		fi
	done
	echo "Duplicate Libraries have been replaced with soft links."
	
	strip -g *
	echo "All Libraries have been reduced in File Size."
	
	cp -r $SRC_DIR/overlay/work/glibc/lib $SRC_DIR/overlay/install/usr/lib
	echo "GLIBC Full Installation has been installed to the OverlayFS."
	
	cd $SRC_DIR
	
	echo "--GLIBC Full Installation Stop ---"
}

install_glibc
