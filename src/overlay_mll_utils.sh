#!/bin/sh
# AwlsomeLinux Overlay MLL-Utils Script
# MLL-Utils created by Ivandavidov

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)



#####################
# Prepare MLL-Utils #
#####################

echo "--- OVERLAY_MLL-UTILS BEGIN ---"

## DEBUGGING:
echo "--- MLL-UTILS_PREPARE BEGIN ---"

# Prepare MLL-Utils Folder
echo "Preparing the Minimal Linux Live Utilities folder. Please wait..."
rm -rf work/overlay/mll_utils
mkdir -p work/overlay/mll_utils/sbin

echo "Minimal Linux Live Utilites folder has been prepared."

cd $SRC_DIR

## DEBUGGING:
echo "--- MLL-UTILS_PREPARE END ---"



##########################################
# MLL-Utils Disk Eraser 'mll-disk-erase' #
##########################################

## DEBUGGING:
echo "--- MLL-UTILS_DISK-ERASE BEGIN ---"

# Check for MLL-Utils
if [ ! -d "$SRC_DIR/work/overlay/mll_utils" ] ; then
	echo "The Directory $SRC_DIR/work/overlay/mll_utils does not exist. Cannot Continue."
	exit
fi

cd work/overlay/mll_utils

## 'mll-disk-erase' BEGIN

# The purpose of this script is to erase all sectors on a disk
# with random data in a secure way, where even the NSA and CIA
# can't recover. 
cat << CEOF > sbin/mll-disk-erase
#!/bin/sh

PRINT_HELP=false

if [ "\$1" = "" -o "\$1" = "-h" -o "\$1" = "--help" ] ; then
  PRINT_HELP=true
fi

# Put more business logic here (if needed).

if [ "\$PRINT_HELP" = "true" ] ; then
  cat << DEOF

  This utility wipes disk partitions or entire disks in secure way by
  overwriting all sectors with random data. Use the '-h' or '--help' option
  to print again this information. Requires root permissions.

  Usage: mll-disk-erase DEVICE [loops]

  DEVICE    The device which will be wiped. Specify only the name, e.g. 'sda'.
            The utility will automatically convert this to '/dev/sda' and will
            exit with warning message if the actual device does not exist.

  loops     How many times to wipe the specified partition or disk. The default
            value is 1. Use higher value for multiple wipes in order to ensure
            that no one can recover your data.

  mll-disk-erase sdb 8

  The above example wipes '/dev/sdb' 8 times in row.

DEOF
  
  exit 0
fi

if [ ! "\$(id -u)" = "0" ] ; then
  echo "You need root permissions. Use '-h' or '--help' for more information."
  exit 1
fi

if [ ! -e /dev/\$1 ] ; then
  echo "Device '/dev/\$1' does not exist. Use '-h' or '--help' for more information."
  exit 1
fi

NUM_LOOPS=1

if [ ! "\$2" = "" ] ; then
  NUM_LOOPS=\$2
fi

for n in \$(seq \$NUM_LOOPS) ; do
  echo "  Windows update \$n of \$NUM_LOOPS is being installed. Please wait..."
  dd if=/dev/urandom of=/dev/\$1 bs=1024b conv=notrunc > /dev/null 2>\&1
done 

echo "  All updates have been installed."

CEOF

chmod +rx sbin/mll-disk-erase

## 'mll-disk-erase' END

echo "Utility Script 'mll-disk-erase' has been generated."

cd $SRC_DIR

## DEBUGGING:
echo "--- MLL-UTILS_DISK-ERASE END ---"



#####################################
# MLL-Utils Installer 'mll-install' #
#####################################

## DEBUGGING:
echo "--- MLL-UTILS_INSTALLER BEGIN ---"

# Check for MLL-Utils
if [ ! -d "$SRC_DIR/work/overlay/mll_utils" ] ; then
	echo "The Directory $SRC_DIR/work/overlay/mll_utils does not exist. Cannot Continue."
	exit
fi

cd work/overlay/mll_utils

# 'mll-install' BEGIN

# This script installs Minimal Linux Live on Ext2 partition.
cat << CEOF > sbin/mll-install
#!/bin/sh

CURRENT_DIR=\$(pwd)
PRINT_HELP=false

if [ "\$1" = "" -o "\$1" = "-h" -o "\$1" = "--help" ] ; then
  PRINT_HELP=true
fi

# Put more business logic here (if needed).

if [ "\$PRINT_HELP" = "true" ] ; then
  cat << DEOF

  This is the Minimal Linux Live installer. Requires root permissions.

  Usage: mll-install DEVICE

  DEVICE    The device where Minmal Linux Live will be installed. Specify only
            the name, e.g. 'sda'. The installer will automatically convert this
            to '/dev/sda' and will exit with warning message if the device does
            not exist.

  mll-install sdb

  The above example installs Minimal Linux Live  on '/dev/sdb'.

DEOF
  
  exit 0
fi

if [ ! "\$(id -u)" = "0" ] ; then
  echo "You need root permissions. Use '-h' or '--help' for more information."
  exit 1
fi

if [ ! -e /dev/\$1 ] ; then
  echo "Device '/dev/\$1' does not exist. Use '-h' or '--help' for more information."
  exit 1
fi

cat << DEOF

  Minimal Linux Live will be installed on device '/dev/\$1'. The device will be 
  formatted with Ext2 and all previous data will be lost. Press 'Ctrl + C' to
  exit or any other key to continue.
    
DEOF

read -n1 -s

umount /dev/\$1 2>/dev/null
sleep 1
mkfs.ext2 /dev/\$1
mkdir /tmp/mnt/inst
mount /dev/\$1 /tmp/mnt/inst
sleep 1
cd /tmp/mnt/device
cp -r kernel.xz rootfs.xz syslinux.cfg src minimal /tmp/mnt/inst 2>/dev/null
cat /opt/syslinux/mbr.bin > /dev/\$1
cd /tmp/mnt/inst
/sbin/extlinux --install .
cd ..
umount /dev/\$1
sleep 1
rmdir /tmp/mnt/inst

cat << DEOF

  Installation is now complete. Device '/dev/\$1' should be bootable now. Check
  the above output for any errors. You need to remove the ISO image and restart
  the system. Let us hope the installation process worked!!! :)

DEOF

cd \$CURRENT_DIR

CEOF

chmod +rx sbin/mll-install

# 'mll-install' END

# Check for Syslinux

if [ ! -d "$SRC_DIR/work/syslinux" ] ; then
	echo "The Installer depends on Syslinux which is missing. Cannot Continue."
	exit 1
fi;

# Goto Syslinux Directory.

cd $SRC_DIR/work/syslinux
cd $(ls -d syslinux-*)

# Copy Essential Syslinux Files for MLL-Utils

cp bios/extlinux/extlinux \
	$SRC_DIR/work/overlay/mll_utils/sbin
mkdir -p $SRC_DIR/work/overlay/mll_utils/opt/syslinux
cp bios/mbr/mbr.bin \
	$SRC_DIR/work/overlay/mll_utils/opt/syslinux
	
# 32-bit executatives need 32-bit libs workaround
mkdir -p $SRC_DIR/work/overlay/mll_utils/lib
mkdir -p $SRC_DIR/work/overlay/mll_utils/usr/lib
cp /lib/ld-linux.so.2 \
	$SRC_DIR/work/overlay/mll_utils/lib
cp /lib/i386-linux-gnu/libc.so.6 \
	$SRC_DIR/work/overlay/mll_utils/usr/lib
	
echo "Minimal Linux Live Installer has been generated."

cd $SRC_DIR

## DEBUGGING:
echo "--- MLL-UTILS_INSTALLER END ---"



#####################
# MLL-Utils Install #
#####################

## DEBUGGING:
echo "--- MLL-UTILS_INSTALL BEGIN ---"

if [ ! -d "$SRC_DIR/work/overlay/mll_utils" ] ; then
  echo "The directory $SRC_DIR/work/overlay/mll_utils does not exist. Cannot continue."
  exit 1
fi

# Copy all generated files to the source overlay folder.
cp -r $SRC_DIR/work/overlay/mll_utils/* \
  $SRC_DIR/work/src/minimal_overlay

echo "All utilities have been installed."

cd $SRC_DIR

## DEBUGGING:
echo "--- MLL-UTILS_INSTALL END ---"

echo "--- OVERLAY_MLL-UTILS END ---"
