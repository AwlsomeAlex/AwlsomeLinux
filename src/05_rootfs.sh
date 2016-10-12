#!/bin/sh
# AwlsomeLinux RootFS Packager Script

####################
# Compile Settings #
####################

SRC_ROOT=$(pwd)
SRC_DIR=$(pwd)
GLIBC_PREPARED=$(pwd)/work/glibc/glibc_prepared
BUSYBOX_INSTALLED=$(pwd)/work/busybox/busybox_installed



###################
# Generate RootFS #
###################

echo "--- ROOTFS BEGIN ---"

## DEBUGGING:
#echo "--- GEN_ROOTFS BEGIN ---"

cd work

echo "Preparing initramfs Work Area..."
rm -rf rootfs

# Copy all BusyBox Generated Files to RootFS (initramfs) location.
cp -r $BUSYBOX_INSTALLED rootfs

# Copy all RootFS Resources to RootFS (initramfs) location.
cp -r src/rootfs/* rootfs

cd rootfs

# Remove 'linuxrc' which will be used to boot into RAM mode.
rm -f linuxrc

# Copy all Source Files to RootFS
cp -r ../src src

# Check which Bit BusyBox was compiled in for the Dynamic Loader.
BUSYBOX_ARCH=$(file bin/busybox | cut -d' '  -f3)
if [ "$BUSYBOX_ARCH" = "64-bit" ] ; then
  mkdir lib64
  cp $GLIBC_PREPARED/lib/ld-linux* lib64
  echo "Dynamic loader is accessed via '/lib64'."
else
  cp $GLIBC_PREPARED/lib/ld-linux* lib
  echo "Dynamic loader is accessed via '/lib'."
fi

# Copy all necessary Glibc Libraries to /lib.

## BEGIN:

## BusyBox Dependencies:
cp $GLIBC_PREPARED/lib/libm.so.6 lib
cp $GLIBC_PREPARED/lib/libc.so.6 lib

## DNS Resolving Dependencies:
cp $GLIBC_PREPARED/lib/libresolv.so.2 lib
cp $GLIBC_PREPARED/lib/libnss_dns.so.2 lib

## END:

# Reduce the size of Libraries and Executables.
strip -g \
	$SRC_ROOT/work/rootfs/bin/* \
	$SRC_ROOT/work/rootfs/sbin/* \
	$SRC_ROOT/work/rootfs/lib/* \
	2>/dev/null
echo "Reduced size of Libraries and Executables."

echo "The initramfs area has been generated."

cd $SRC_ROOT

## DEBUGGING:
#echo "--- GEN_ROOTFS END ---"



###############
# Pack RootFS #
###############

## DEBUGGING:
#echo "--- PACK_ROOTFS BEGIN ---"

cd work

echo "Packing initramfs. Please Wait..."

# Remove old 'initramfs' archive file type.
rm -f rootfs.cpio.gz

cd rootfs

# Pack initramfs folder in a 'cpio.xz' archive.
find . | cpio -R root:root -H newc -o | xz -9 --check=none > ../rootfs.cpio.xz

echo "Packing of initramfs has finished."

cd $SRC_DIR

## DEBUGGING:
#echo "--- PACK_ROOTFS END ---"

echo "--- ROOTFS END ---"
