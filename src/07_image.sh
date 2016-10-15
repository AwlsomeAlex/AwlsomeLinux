#!/bin/sh
# AwlsomeLinux Image Generation Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)
KERNEL_INSTALLED=$SRC_DIR/work/kernel/kernel_installed



###########################
# Prepare Image Directory #
###########################

echo "--- IMAGE BEGIN ---"

## DEBUGGING:
#echo "--- PREPARE_IMAGE BEGIN ---"

# Find SYSLINUX Directory.
cd work/syslinux
cd $(ls -d *)
WORK_SYSLINUX_DIR=$(pwd)
cd $SRC_DIR

# Remove old ISO file.
rm -f awlsomelinux.iso
echo "Old ISO image has been removed."

# Remove old ISO Generation Folder.
echo "Removing old ISO Generation Folder. Please wait..."
rm -rf work/isoimage

# Create the Root Folder of the ISO Image.
mkdir work/isoimage

# Copy Source Directory to ISO Image.
cp -r work/src work/isoimage
echo "Source Directory has been copied to ISO Image."

## DEBUGGING:
#echo "--- PREPARE_IMAGE END ---"



#############
# OverlayFS #
#############

## DEBUGGING:
#echo "--- OVERLAY_IMAGE BEGIN ---"

## Folder Overlay Type Only:

#echo "Generating Overlay Structure..."

#time sh build_awlsomelinux_overlay.sh

#echo "--- OVERLAY_IMAGE END ---"



##################
# Generate Image #
##################

## DEBUGGING:
#echo "--- GEN_IMAGE BEGIN ---"

cd work/isoimage

# Copy precompiled 'isolinux.bin' and 'ldlinux.c32' to ISO Image.
cp $WORK_SYSLINUX_DIR/bios/core/isolinux.bin .
cp $WORK_SYSLINUX_DIR/bios/com32/elflink/ldlinux/ldlinux.c32 .

# Copy Kernel to ISO Image.
cp $KERNEL_INSTALLED/kernel ./kernel.xz

# Copy RootFS to ISO Image.
cp ../rootfs.cpio.xz ./rootfs.xz

# Copy OverlayFS to ISO Image.
mkdir -p minimal/rootfs
mkdir -p minimal/work

cp -rf $SRC_DIR/work/src/overlay/* minimal/rootfs/

echo "Generated OverlayFS"

# Create ISOLINUX Configuration File.
echo 'default kernel.xz initrd=rootfs.xz vga=ask' > ./isolinux.cfg

# Generate the ISO Image.
genisoimage \
	-J \
	-r \
	-o ../awlsomelinux.iso \
	-b isolinux.bin \
	-c boot.cat \
	-input-charset UTF-8 \
	-no-emul-boot \
	-boot-load-size 4 \
	-boot-info-table \
	./
	
# Make ISO Image bootable on USB Flash Drives.
isohybrid -u ../awlsomelinux.iso 2>/dev/null || true

# Copy ISO Image to Root Project Folder.
cp ../awlsomelinux.iso ../../

if [ "$(id -u)" = "0" ] ; then
  # Apply ownership back to original owner for all affected files.
  chown $(logname) ../../awlsomelinux.iso
  chown $(logname) ../../work/awlsomelinux.iso
  chown -R $(logname) .
  echo "Applied original ownership to all affected files and folders."
fi

cd $SRC_DIR

## DEBUGGING:
#echo "--- GEN_IMAGE END ---"

echo "--- IMAGE END ---"
	
