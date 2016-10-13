#!/bin/sh
# AwlsomeLinux Overlay Clean Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)



#################
# Clean Overlay #
#################

echo "--- OVERLAY_CLEAN BEGIN ---"

echo "Cleaning the Overlay Work Area. Please wait..."
rm -rf work/overlay
mkdir -p work/overlay

# Extra Precaution just in case this script is generated before Main Script.
mkdir -p work/src/minimal_overlay

# Clean/Create Overlay Source Area
rm -rf source/overlay
mkdir -p source/overlay

cd overlay

for dir in $(ls -d */ 2>/dev/null) ; do
	rm -rf $dir
	echo "Overlay Folder '$dir' has been removed."
done

echo "Ready to Continue with Overlay Software."

cd $SRC_DIR

echo "---OVERLAY_CLEAN END ---"
