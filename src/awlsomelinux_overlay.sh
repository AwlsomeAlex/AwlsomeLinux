#!/bin/sh

## AwlsomeLinux Overlay Creation Script
## Created by AwlsomeAlex (GNU GPLv3)

##############################
# -------------------------- #
# AwlsomeLinux Configuration #
# -------------------------- #
##############################

SRC_DIR=$(pwd)

##########################
# AwlsomeLinux Variables #
##########################


#############################
# ------------------------- #
# AwlsomeLinux Image Script #
# ------------------------- #
##############################


###########################
# GLIBC Full Installation #
###########################

install_glibc() {
	echo "== GLIBC Full Installation (Start) =="
	
	# Check if Glibc is Built
	if [ ! -d $SRC_DIR/core/install/glibc ] ; then
		echo "GLIBC Full Installation Failed - GLIBC was never built. Please build GLIBC!"
		exit 1
	fi
	
	# Prepare GLIBC Full Installation Work Area
	rm -rf overlay/work/glibc
	rm -rf overlay/install/glibc
	mkdir overlay/work/glibc
	mkdir overlay/work/glibc/lib
	mkdir overlay/install/glibc
	mkdir overlay/install/glibc/lib
	
	# Change Directory to 'core/install/glibc_prepared/lib'
	cd core/install/glibc_prepared/lib
	
	# Copy all GLIBC Libraries to OverlayFS
	find . -type l -exec cp {} $SRC_DIR/overlay/work/glibc/lib \;
	echo "All GLIBC Libraries have been copied."
	
	cd $SRC_DIR/overlay/work/glibc/lib

	for FILE_DEL in $(ls *.so)
		do
			FILE_KEEP=$(ls $FILE_DEL.*)

		if [ ! "$FILE_KEEP" = "" ] ; then
			# We remove the shorter file and replace it with symbolic link.
			rm $FILE_DEL
			ln -s $FILE_KEEP $FILE_DEL
		fi
	done
	echo "Duplicate Libraries have been replaced with soft links."
	
	strip -g *
	echo "All Libraries have been reduced in File Size."
	
	cp -r $SRC_DIR/overlay/work/glibc/lib $SRC_DIR/overlay/install/glibc
	echo "GLIBC Full Installation has been installed to the OverlayFS."
	
	cd $SRC_DIR
	
	echo "== GLIBC Full Installation (Stop) =="
}

##########################################
# Minimal Linux Live Utilities Installer #
##########################################

install_mll_utils() {
	
	echo "== Minimal Linux Live Utilities (Start) =="
	
	# Prepare Minimal Linux Live Utilities Script Area
	rm -rf overlay/work/mll_utils
	mkdir -p overlay/work/mll_utils/sbin
	
	# Change Directory to 'overlay/work/mll_utils'
	cd overlay/work/mll_utils
	
	## Minimal Linux Live Utilities (Disk Eraser)
	
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
  echo "  Wiping of \$1 \$n of \$NUM_LOOPS complete... Please wait..."
  dd if=/dev/urandom of=/dev/\$1 bs=1024b conv=notrunc > /dev/null 2>\&1
done 

echo "  Drive \$1 has been wiped."

CEOF

	# Make 'sbin/mll-disk-erase' executable
	chmod +rx sbin/mll-disk-erase
	
	## Minimal Linux Live Utilities (Disk Eraser) [END]
	echo "Utility Script 'mll-disk-erase' has been generated."
	
	## Minimal Linux Live Utilities (Installer)
	
	# Installer Script
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
cp -r kernel.xz core.xz syslinux.cfg menu.c32 libutil.c32 overlay /tmp/mnt/inst 2>/dev/null
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
	
	# Make 'mll-install' executable
	chmod +rx sbin/mll-install
	
	# Copy 'mll-installer' Dependencies from Generated Syslinux
	cd $SRC_DIR/isoimage/syslinux
	cd $(ls -d syslinux-*)
	
	cp bios/extlinux/extlinux \
		$SRC_DIR/overlay/work/mll_utils/sbin
	mkdir -p $SRC_DIR/overlay/work/mll_utils/opt/syslinux
	cp bios/mbr/mbr.bin \
		$SRC_DIR/overlay/work/mll_utils/opt/syslinux
		
	# Syslinux/Extlinux 32-bit Executable Workaround
	mkdir -p $SRC_DIR/overlay/work/mll_utils/lib
	mkdir -p $SRC_DIR/overlay/work/mll_utils/usr/lib
	cp /lib/ld-linux.so.2 \
		$SRC_DIR/overlay/work/mll_utils/lib
	cp /lib/i386-linux-gnu/libc.so.6 \
		$SRC_DIR/overlay/work/mll_utils/usr/lib
	
	echo "Utility Script 'mll-install' has been generated."
	
	cd $SRC_DIR
	
	echo "== Minimal Linux Live Utilities (Stop) =="
		
}

######################
# OverlayFS Creation #
######################
overlayfs_create() {
	
	echo "== OverlayFS Creation (Start) =="

	# Create OverlayFS Directories
	mkdir $SRC_DIR/overlay/overlayfs/etc
	mkdir $SRC_DIR/overlay/overlayfs/lib

	# Copy Packages to OverlayFS
	cp -r $SRC_DIR/overlay/install/glibc/* $SRC_DIR/overlay/overlayfs
	cp -r $SRC_DIR/overlay/work/mll_utils/* $SRC_DIR/overlay/overlayfs
	
	echo "The OverlayFS Directory has been created."
	
	cd $SRC_DIR
	
	echo "== OverlayFS Creation (Stop) =="
	
}

######################
# Root User Creation #
######################
generate_user() {
	
	echo "== Generate Root User (Start) =="
	
	# Create User Files
	touch $SRC_DIR/overlay/overlayfs/etc/passwd
	touch $SRC_DIR/overlay/overlayfs/etc/group
	
	# Add group 0 for root
	echo "root:x:0:" \
			> $SRC_DIR/overlay/overlayfs/etc/group
			
	# Add user root with password 'toor'
	echo "root:AprZpdBUhZXss:0:0:AwlsomeLinux Root,,,:/root:/bin/sh" \
		> $SRC_DIR/overlay/overlayfs/etc/passwd
	
	# Generate Root Directory '/root' for Root User
	mkdir -p $SRC_DIR/overlay/overlayfs/root
	
	# Copy OverlayFS Inittab from 'core/rootfs/etc' to 'overlay/overlayfs/etc'
	cp -r $SRC_DIR/core/rootfs/etc/inittab_overlay $SRC_DIR/overlay/overlayfs/etc/inittab
	
	echo "== Generate Root User (Stop) =="
	
}


install_glibc

install_mll_utils

overlayfs_create

generate_user
