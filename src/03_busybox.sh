#!/bin/sh
# AwlsomeLinux BusyBox Compile Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^BUSYBOX_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))
GLIBC_PREPARED=$(pwd)/work/glibc/glibc_prepared


###############
# Get BusyBox #
###############

echo "--- BUSYBOX BEGIN ---"

## DEBUGGING:
echo "--- BUSYBOX_GET BEGIN ---"

cd source

# Downloads BusyBox and puts it in the Source Directory.
echo "Downloading BusyBox Source Bundle from busybox.net"
wget -c $DOWNLOAD_URL

# Delete BusyBox Work Directory
echo "Removing Old BusyBox Work Area. Please wait..."
rm -rf ../work/busybox
mkdir ../work/busybox

# Extract BusyBox to '/work/busybox/busybox-[version]'.
tar -xvf $ARCHIVE_FILE -C ../work/busybox

cd $SRC_DIR

## DEBUGGING:
echo "--- BUSYBOX_GET END ---"



#################
# Build BusyBox #
#################

## DEBUGGING:
echo "--- BUSYBOX_BUILD BEGIN ---"

cd work/busybox

# Remove BusyBox Install Area.
rm -rf busybox_installed

# Change Directory to Source
cd $(ls -d busybox-*)

# Remove Generated Atrifacts.
echo "Preparing BusyBox Work Area. Please wait..."
make distclean -j $NUM_JOBS

# Generate Default Configuration File.
echo "Generating Default BusyBox Configuration File..."
make defconfig -j $NUM_JOBS
sed -i "s/.*CONFIG_INETD.*/CONFIG_INETD=n/" .config

# Remember and tell BusyBox Full GLIBC Installation Area.
GLIBC_PREPARED_ESCAPE=$(echo \"GLIBC_PREPARED\" | sed 's/\//\\\//g')
sed -i "s/.*CONFIG_SYSROOT.*/CONFIG_SYSROOT=$GLIBC_PREPARED_ESCAPED/" .config

# Compile BusyBox.
echo "Building BusyBox..."
make \
	EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
	busybox -j $NUM_JOBS
	
# Create symlinks for BusyBox.
echo "Generating BusyBox-Based initramfs area..."
make \
	CONFIG_PREFIX="../busybox_installed" \
	install -j $NUM_JOBS
	
cd $SRC_DIR

## DEBUGGING:
echo "--- BUSYBOX_BUILD END ---"

echo "--- BUSYBOX END ---"
