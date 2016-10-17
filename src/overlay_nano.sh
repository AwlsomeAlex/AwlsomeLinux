#!/bin/sh
# AwlsomeLinux Overlay Nano Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^NANO_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



############
# Get Nano #
############

echo "--- OVERLAY_NANO BEGIN ---"

## DEBUGGING:
echo "--- NANO_GET BEGIN ---"

cd source/overlay

# Downloads Nano and puts it in the Source Directory.
echo "Downloading Nano Source Bundle from nano-editor.org"
wget -c $DOWNLOAD_URL

# Delete Nano Work Directory
echo "Removing Old Nano Work Area. Please wait..."
rm -rf ../../work/overlay/nano
mkdir ../../work/overlay/nano

# Extract Links to '/work/overlay/nano/nano-[version]'.
tar -xvf $ARCHIVE_FILE -C ../../work/overlay/nano

cd $SRC_DIR

## DEBUGGING:
echo "--- NANO_GET END ---"



##############
# Build Nano #
##############

## DEBUGGING:
echo "--- NANO_BUILD BEGIN ---"

cd work/overlay/nano

# Change Directory to the Nano Source Directory.
cd $(ls -d nano-*)

# Clean out Nano Work Area.
echo "Preparing Nano Work Area. Please wait..."
make clean -j $NUM_JOBS 2>/dev/null

# Configure Nano
echo "Configuring Nano..."
./configure \
	--prefix=$SRC_DIR/work/overlay/nano/nano_installed \
	--disable-utf8 \
    CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
    
# Build Nano.
echo "Building Nano..."
make -j $NUM_JOBS

# Install Nano.
echo "Installing Nano..."
make install -j $NUM_JOBS

# Clean and Copy Ncurses.
echo "Reducing Nano Size..."
strip -g ../nano_installed/bin/* 2>/dev/null

cp -r ../nano_installed/bin $SRC_DIR/work/src/overlay

echo "Nano has been Installed to OverlayFS."

# Configure Nano.
echo "set autoindent" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set const" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set fill 72" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set historylog" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set multibuffer" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set nohelp" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set regexp" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set smooth" >> $SRC_DIR/work/src/overlay/etc/nanorc
echo "set suspend" >> $SRC_DIR/work/src/overlay/etc/nanorc

cd $SRC_DIR

## DEBUGGING:
echo "--- NANO_BUILD END ---"

echo "--- OVERLAY_NANO END 

