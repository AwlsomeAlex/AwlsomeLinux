#!/bin/sh
# AwlsomeLinux Overlay Dropbear Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^DROPBEAR_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



################
# Get Dropbear #
################

echo "--- OVERLAY_DROPBEAR BEGIN ---"

## DEBUGGING:
echo "--- DROPBEAR_GET BEGIN ---"

cd source/overlay

# Downloads Dropbear and puts it in the Source Directory.
echo "Downloading Dropbear Source Bundle from matt.ucc.asn.au"
wget -c $DOWNLOAD_URL

# Delete Dropbear Work Directory
echo "Removing Old Dropbear Work Area. Please wait..."
rm -rf ../../work/overlay/dropbear
mkdir ../../work/overlay/dropbear

# Extract Links to '/work/overlay/dropbear/dropbear-[version]'.
tar -xvf $ARCHIVE_FILE -C ../../work/overlay/dropbear

cd $SRC_DIR

## DEBUGGING:
echo "--- DROPBEAR_GET END ---"



##################
# Build Dropbear #
##################

## DEBUGGING:
echo "--- DROPBEAR_BUILD BEGIN ---"

cd work/overlay/dropbear

# Change Directory to the Dropbear Source Directory.
cd $(ls -d dropbear-*)

# Checks if GLIBC has been Compiled.

if [ ! -d $SRC_DIR/work/glibc/glibc_prepared ] ; then
	echo "Dropbear Build Impossible - GLIBC is missing. Please build GLIBC first!"
	exit 1
fi

# Clean Dropbear Work Area. 
echo "Preparing Dropbear Work Area. Please wait..."
make clean -j $NUM_JOBS 2>/dev/null

rm -rf ../dropbear_installed

# Configure Dropbear.
echo "Configuring Dropbear..."
./configure \
	--prefix=$SRC_DIR/work/overlay/dropbear/dropbear_installed \
	--disable-zlib \
	--disable-loginfunc \
	CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
	
# Build Dropbear.
echo "Building Dropbear..."
make -j $NUM_JOBS

echo "Installing Dropbear..."
make install -j $NUM_JOBS

# Copy all Glibc Dependencies to Dropbear.
mkdir -p ../dropbear_installed/lib

cp $SRC_DIR/work/glibc/glibc_prepared/lib/libnsl.so.1 ../dropbear_installed/lib
cp $SRC_DIR/work/glibc/glibc_prepared/lib/libnss_compat.so.2 ../dropbear_installed/lib
cp $SRC_DIR/work/glibc/glibc_prepared/lib/libutil.so.1 ../dropbear_installed/lib
cp $SRC_DIR/work/glibc/glibc_prepared/lib/libcrypt.so.1 ../dropbear_installed/lib

mkdir -p ../dropbear_installed/etc/dropbear

## Create Dropbear SSH Configuration BEGIN

# Create RSA Key.
../dropbear_installed/bin/dropbearkey \
	-t rsa \
	-f ../dropbear_installed/etc/dropbear/dropbear_rsa_host_key
	
# Create DSS Key.
../dropbear_installed/bin/dropbearkey \
	-t dss \
	-f ../dropbear_installed/etc/dropbear/dropbear_dss_host_key
	
# Create ECDSA Key.
../dropbear_installed/bin/dropbearkey \
	-t ecdsa \
	-f ../dropbear_installed/etc/dropbear/dropbear_ecdsa_host_key
	
# Create User/Group Configuration Files.
touch ../dropbear_installed/etc/passwd
touch ../dropbear_installed/etc/group

# Add group 0 for root.
echo "root:x:0:" \
	> ../dropbear_installed/etc/group
	
# Add user root with password 'toor'.
echo "root:AprZpdBUhZXss:0:0:Minimal Root,,,:/root:/bin/sh" \
  > ../dropbear_installed/etc/passwd
  
# Create home directory for root user.
mkdir -p ../dropbear_installed/root

## Create Dropbear SSH Configuration END

# Reduce Dropbear Size.
echo "Reducing Dropbear Size..."
strip -g \
	../dropbear_installed/bin/* \
	../dropbear_installed/sbin/* \
	../dropbear_installed/lib/* \
	
# Install Dropbear to OverlayFS.
echo "Installing Dropbear to OverlayFS."

cp -r \
	../dropbear_installed/etc \
	../dropbear_installed/bin \
	../dropbear_installed/sbin \
	../dropbear_installed/lib \
	$SRC_DIR/work/src/overlay
	
echo "Dropbear has been installed."

## DEBUGGING:
echo "--- DROPBEAR_BUILD END ---"

echo "--- OVERLAY_DROPBEAR END ---"
