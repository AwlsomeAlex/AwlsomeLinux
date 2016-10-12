#!/bin/sh
# AwlsomeLinux SYSLINUX Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^SYSLINUX_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}



####################
# Extract SYSLINUX #
####################

echo "--- SYSLINUX BEGIN ---"

cd source

# Downloads SYSLINUX and puts it in the Source Directory.
echo "Downloading SYSLINUX Source Bundle from kernel.org"
wget -c $DOWNLOAD_URL

# Delete SYSLINUX Work Directory
echo "Removing Old SYSLINUX Work Area. Please wait..."
rm -rf ../work/syslinux
mkdir ../work/syslinux

# Extract SYSLINUX to '/work/syslinux/syslinux-[version]'.
tar -xvf $ARCHIVE_FILE -C ../work/syslinux

cd $SRC_DIR

echo "--- SYSLINUX END ---"

