#!/bin/sh
# AwlsomeLinux Glibc Compile Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^GLIBC_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))
KERNEL_INSTALLED=$SRC_DIR/work/kernel/kernel_installed



#############
# Get Glibc #
#############

echo "--- GLIBC BEGIN ---"

## DEBUGGING:
echo "--- GLIBC_GET BEGIN ---"

cd source

# Downloads Glibc and puts it in the Source Directory.
echo "Downloading Glibc Source Bundle from GNU.org"
wget -c $DOWNLOAD_URL

# Delete Glibc Work Directory
echo "Removing Old Glibc Work Area. Please wait..."
rm -rf ../work/glibc
mkdir ../work/glibc

# Extract Glibc to '/work/glibc/glibc-[version]'.
tar -xvf $ARCHIVE_FILE -C ../work/glibc

cd $SRC_DIR

## DEBUGGING:
echo "--- GLIBC_GET END ---"



###############
# Build Glibc #
###############

## DEBUGGING:
echo "--- GLIBC_BUILD BEGIN ---"

cd work/glibc

# Find the glibc Soruce Directory and Remember it.
cd $(ls -d glibc-*)
GLIBC_SRC=$(pwd)
cd ..

# Prepare Glibc Work Area. 
echo "Preparing Glibc Object Area. Please wait..."
rm -rf glibc_objects
mkdir glibc_objects

# Prepare Glibc Install Area and Remember it.
echo "Preparing Glibc Install Area. Please wait..."
rm -rf glibc_installed
mkdir glibc_installed
GLIBC_INSTALLED=$(pwd)/glibc_installed

# All Compiling is donw in Work Area.
cd glibc_objects

# Configure Glibc Configuration File.
echo "Configuring Glibc..."
$GLIBC_SRC/configure \
	--prefix= \
	--with-headers=$KERNEL_INSTALLED/include \
	--without-gd \
	--without-selinux \
	--disable-werror \
	CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
	
# Compile Glibc from Configuration File.
echo "Building Glibc..."
make -j $NUM_JOBS

# Install Glibc to work/glibc/glibc_installed
echo "Installing Glibc..."
make install \
	DESTDIR=$GLIBC_INSTALLED \
	-j $NUM_JOBS

cd $SRC_DIR

## DEBUGGING:
echo " --- GLIBC_BUILD END ---"



#################
# Prepare Glibc #
#################

## DEBUGGING:
echo " --- GLIBC_PREPARED BEGIN ---"

cd work/glibc

# Prepare Glibc.
echo "Preparing Glibc. Please wait..."
rm -rf glibc_prepared
cp -r glibc_installed glibc_prepared

cd glibc_prepared

# Create a /usr area and link it with Kernel Headers and Kernel Functions.
mkdir -p usr
cd usr
ln -s ../include include
ln -s ../lib lib
ln -s $KERNEL_INSTALLED/include/linux linux
ln -s $KERNEL_INSTALLED/include/asm asm
ln -s $KERNEL_INSTALLED/include/asm-generic asm-generic
ln -s $KERNEL_INSTALLED/include/mtd mtd

cd $SRC_DIR

## DEBUGGING:
echo " --- GLIBC_PREPARE END ---"

echo "--- GLIBC END ---"
