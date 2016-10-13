#!/bin/sh
# AwlsomeLinux Overlay Links Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^LINKS_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



#############
# Get Links #
#############

echo "--- OVERLAY_LINKS BEGIN ---"

## DEBUGGING:
echo "--- LINKS_GET BEGIN ---"

cd source/overlay

# Downloads Links and puts it in the Source Directory.
echo "Downloading Links Source Bundle from twibright.com"
wget -c $DOWNLOAD_URL

# Delete Links Work Directory
echo "Removing Old Links Work Area. Please wait..."
rm -rf ../../work/overlay/links
mkdir ../../work/overlay/links

# Extract Links to '/work/overlay/links/links-[version]'.
tar -xvf $ARCHIVE_FILE -C ../../work/overlay/links

cd $SRC_DIR

## DEBUGGING:
echo "--- LINKS_GET END ---"



###############
# Build Links #
###############

## DEBUGGING:
echo "--- LINKS_BUILD BEGIN ---"

cd work/overlay/links

# Change Directory to the Links Source Directory.
cd $(ls -d links-*)

# Clean out Links Work Area.
echo "Preparing Links Work Area. Please wait..."
make clean -j $NUM_JOBS 2>/dev/null

rm -rf ../links_installed

# Configure Links
echo "Configuring Links..."
./configure \
	--prefix=../links_installed \
	--disable-graphics \
	--disable-utf8 \
	--without-ipv6 \
	--without-ssl \
	--without-x 

# Set CLAGS Directly in Makefile.
sed -i "s/^CFLAGS = .*/CFLAGS = \\-Os \\-s \\-fno\\-stack\\-protector \\-U_FORTIFY_SOURCE/" Makefile

# Build Links.
echo "Building Links..."
make -j $NUM_JOBS

# Install Links.
echo "Installing Links..."
make install -j $NUM_JOBS

# Clean and Copy Links
echo "Reducing Links Size..."
strip -g ../links_installed/bin/* 2>/dev/null

cp -r ../links_installed/bin $SRC_DIR/work/src/overlay
echo "Links has been Installed to OverlayFS."

cd $SRC_DIR

## DEBUGGING:
echo "--- LINKS_BUILD END ---"

echo "--- OVERLAY_LINKS END ---"
