#!/bin/sh
# AwlsomeLinux Overlay Dialog Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^DIALOG_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



##############
# Get Dialog #
##############

echo "--- OVERLAY_DIALOG BEGIN ---"

## DEBUGGING:
echo "--- DIALOG_GET BEGIN ---"

cd source/overlay

# Downloads Dialog and puts it in the Source Directory.
echo "Downloading Dialog Source Bundle from invisible-island.net"
wget -c $DOWNLOAD_URL

# Delete Dialog Work Directory
echo "Removing Old Dialog Work Area. Please wait..."
rm -rf ../../work/overlay/dialog
mkdir ../../work/overlay/dialog

# Extract Links to '/work/overlay/dialog/dialog-[version]'.
tar -xvf $ARCHIVE_FILE -C ../../work/overlay/dialog

cd $SRC_DIR

## DEBUGGING:
echo "--- DIALOG_GET END ---"



################
# Build Dialog #
################

## DEBUGGING:
echo "--- DIALOG_BUILD BEGIN ---"

cd work/overlay/dialog

# Change Directory to the Dialog Source Directory.
cd $(ls -d dialog-*)

# Clean out Dialog Work Area.
echo "Preparing Dialog Work Area. Please wait..."
make clean -j $NUM_JOBS 2>/dev/null

# Configure Dialog
echo "Configuring Dialog..."
./configure \
	--prefix=$SRC_DIR/work/overlay/dialog/dialog_installed \
	--with-ncurses \
	--disable-utf8 \
    CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
    
# Build Dialog.
echo "Building Dialog..."
make -j $NUM_JOBS

# Install Dialog.
echo "Installing Dialog..."
make install -j $NUM_JOBS

# Clean and Copy Dialog.
echo "Reducing Dialog Size..."
strip -g ../dialog_installed/bin/* 2>/dev/null

cp -r ../dialog_installed/bin $SRC_DIR/work/src/overlay

echo "Dialog has been Installed to OverlayFS."

cd $SRC_DIR

## DEBUGGING:
echo "--- DIALOG_BUILD END ---"

echo "--- OVERLAY_DIALOG END ---"
