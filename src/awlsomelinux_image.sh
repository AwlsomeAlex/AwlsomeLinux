#!/bin/sh

## AwlsomeLinux Image Creation Script
## Created by AwlsomeAlex (GNU GPLv3)

##############################
# -------------------------- #
# AwlsomeLinux Configuration #
# -------------------------- #
##############################

SRC_DIR=$(pwd)
LINUX_INSTALLED=$SRC_DIR/core/install/linux

##########################
# AwlsomeLinux Variables #
##########################

SYSLINUX_DOWNLOAD_URL=http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz
SYSLINUX_ARCHIVE_FILE=${SYSLINUX_DOWNLOAD_URL##*/}

#############################
# ------------------------- #
# AwlsomeLinux Image Script #
# ------------------------- #
#############################


####################
# Extract SYSLINUX #
####################
get_syslinux() {
	echo "== Get SYSLINUX (Start) =="
	
	# Change Directory to 'isoimage'
	cd isoimage
	
	# Download SYSLINUX
	echo "Downloading SYSLINUX Source Archive..."
	wget -c --progress=bar:force $SYSLINUX_DOWNLOAD_URL
	
	# Clean out old SYSLINUX Directory (If 'make clean' or 'make all' wasn't executed)
	rm -rf syslinux
	mkdir syslinux
	
	# Extract .xz Archive to 'isoimage/SYSLINUX'
	echo "Extracting SYSLINUX..."
	tar -xvf $SYSLINUX_ARCHIVE_FILE -C $SRC_DIR/isoimage/syslinux
	
	cd $SRC_DIR
	
	echo "== Get SYSLINUX (Stop) =="
}



###########################
# Prepare Image Directory #
###########################

prepare_imagedir() {
	echo "== Prepare Image Directory (Start) =="
	
	# Change Directory to SYSLINUX and Remember it
	cd isoimage/syslinux
	cd $(ls -d *)
	WORK_SYSLINUX_DIR=$(pwd)
	cd $SRC_DIR
	
	# Remove old AwlsomeLinux Image
	rm -f awlsomelinux.iso
	echo "Old AwlsomeLinux Image has been removed."
	
	# Remove old Image Generation Folder
	rm -rf isoimage/image
	
	# Copy Source Directory to AwlsomeLinux Image
#	cp -r core/src isoimage/image
#	echo "Source Directory has been copied to AwlsomeLinux Image.
	mkdir isoimage/image
	
	cd $SRC_DIR
	
	echo "== Prepare Image Directory (Stop) =="
}



#################################
# Run OverlayFS Creation Script #
#################################

generate_overlayfs() {
	echo "== Prepare OverlayFS (Start) =="
	
	# Execute AwlsomeLinux Image Script
	echo "Generating OverlayFS..."
	time sh awlsomelinux_overlay.sh 2>&1 | tee awlsomelinux_overlay.log
	
	echo "== Prepare OverlayFS (Stop) =="
}



###################################
# Generate AwlsomeLinux ISO Image #
###################################

generate_image() {
	echo "== Generate Image (Start) =="
	
	cd $SRC_DIR
	
	# Change Directory to 'isoimage/image'
	cd isoimage/image
	
	# Copy Linux Kernel to AwlsomeLinux Image
	cp $LINUX_INSTALLED/kernel ./kernel.xz
	
	# Copy RootFS to AwlsomeLinux Image
	cp $SRC_DIR/core/core.cpio.xz ./core.xz
	
	# Copy OverlayFS to AwlsomeLinux Image
	mkdir -p overlay/rootfs
	mkdir -p overlay/work
	
	cp -rf $SRC_DIR/overlay/overlayfs/* overlay/rootfs
	
	# Copy Required Syslinux Componients to AwlsomeLinux Image
	cp $WORK_SYSLINUX_DIR/bios/core/isolinux.bin .
    cp $WORK_SYSLINUX_DIR/bios/com32/elflink/ldlinux/ldlinux.c32 .
    cp $WORK_SYSLINUX_DIR/bios/com32/libutil/libutil.c32 .
    cp $WORK_SYSLINUX_DIR/bios/com32/menu/menu.c32 .
	
	# Create ISOLINUX Configuration File
	cat << CEOF > ./syslinux.cfg
UI menu.c32
PROMPT 0
 
MENU TITLE AwlsomeLinux Boot Menu:
TIMEOUT 10
DEFAULT awlsomelinux
 
LABEL awlsomelinux
        MENU LABEL AwlsomeLinux
        LINUX kernel.xz
        INITRD core.xz
CEOF
	
	# Create UEFI Boot Script
	mkdir -p efi/boot
	cat << CEOF > ./efi/boot/startup.nsh
	echo -off
	echo AwlsomeLinux is starting...
	\\kernel.xz initrd=\\core.xz
CEOF
	
	# Generate AwlsomeLinux Image
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
		-joliet-long \
		./
		
	# Make AwlsomeLinux Image Bootable on USB Flash Drives
	isohybrid -u ../awlsomelinux.iso 2>/dev/null || true
	
	# Copy AwlsomeLinux Image to Root Project Folder
	cp ../awlsomelinux.iso ../../
	
	if [ "$(id -u)" = "0" ] ; then
		# Apply ownership back to original owner for all affected files.
		chown $(logname) ../../awlsomelinux.iso
		chown $(logname) ../../work/awlsomelinux.iso
		chown -R $(logname) .
		echo "Applied original ownership to all affected files and folders."
	fi

	cd $SRC_DIR
	
	echo "== Generate Image (Stop) =="
}
get_syslinux

prepare_imagedir

generate_overlayfs

generate_image
