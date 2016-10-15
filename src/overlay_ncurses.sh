#!/bin/sh
# AwlsomeLinux Overlay Ncurses Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^NCURSES_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



###############
# Get Ncurses #
###############

echo "--- OVERLAY_NCURSES BEGIN ---"

## DEBUGGING:
echo "--- NCURSES_GET BEGIN ---"

cd source/overlay

# Downloads Ncurses and puts it in the Source Directory.
echo "Downloading Ncurses Source Bundle from ftp.gnu.org"
wget -c $DOWNLOAD_URL

# Delete Ncurses Work Directory
echo "Removing Old Ncurses Work Area. Please wait..."
rm -rf ../../work/overlay/ncurses
mkdir ../../work/overlay/ncurses

# Extract Links to '/work/overlay/ncurses/ncurses-[version]'.
tar -xvf $ARCHIVE_FILE -C ../../work/overlay/ncurses

cd $SRC_DIR

## DEBUGGING:
echo "--- NCURSES_GET END ---"



#################
# Build Ncurses #
#################

## DEBUGGING:
echo "--- NCURSES_BUILD BEGIN ---"

cd work/overlay/ncurses

# Change Directory to the Ncurses Source Directory.
cd $(ls -d ncurses-*)

# Clean out Ncurses Work Area.
echo "Preparing Ncurses Work Area. Please wait..."
make clean -j $NUM_JOBS 2>/dev/null

# Configure Ncurses to not make libraries it can't support.
#sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in

# Configure Ncurses
echo "Configuring Ncurses..."
./configure \
	--prefix=$SRC_DIR/work/overlay/ncurses/ncurses_installed \
    --with-shared           \
    --without-debug         \
    --without-normal        \
    --enable-pc-files       \
    --enable-widec			\
    CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
    CPPFLAGS="-P"
	
# Build Ncurses.
echo "Building Ncurses..."
make -j $NUM_JOBS

# Install Ncurses.
echo "Installing Ncurses..."
make install -j $NUM_JOBS

# Clean and Copy Ncurses.
echo "Reducing Ncurses Size..."
strip -g ../ncurses_installed/bin/* 2>/dev/null
strip -g ../ncurses_installed/lib/* 2>/dev/null

cp -r ../ncurses_installed/bin $SRC_DIR/work/src/overlay
cp -r ../ncurses_installed/lib $SRC_DIR/work/src/overlay
echo "Ncurses has been Installed to OverlayFS."

cd $SRC_DIR

## DEBUGGING:
echo "--- NCURSES_BUILD END ---"

echo "--- OVERLAY_NCURSES END ---"

