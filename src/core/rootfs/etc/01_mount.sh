#!/bin/sh

# AwlsomeLinux Initialization Chart:
#
# /init
#  |
#  +--(1) /etc/01_mount.sh (this file)
#          |
#          +--(2) /etc/02_init.sh
#                  |
#                  +-- /sbin/init
#                       |
#                       +--(1) /etc/03_boot.sh
#                       |       |
#                       |       +-- udhcpc
#                       |           |
#                       |           +-- /etc/rc.udhcp
#                       +--(2) /bin/login (Alt + F1, Main Login Console)
#                       |
#                       +--(2) /bin/login (Alt + F2)
#                       |
#                       +--(2) /bin/login (Alt + F3)
#                       |
#                       +--(3) /bin/sh (Alt + F4, Recovery/Debug Shell)
#                       |
#                       +--(3) /bin/login (Alt + F4 [PUBLIC RELEASES ONLY])

#####################
# InitramFS Prepare #
#####################

initramfs_prepare() {
	# Turn off Kernel Messages
	dmesg -n 1
	echo "Supressed Most Kernel Messages."
	# Prepare and Mount InitramFS
	mount -t devtmpfs none /dev
	mount -t proc none /proc
	mount -t tmpfs none /tmp -o mode=1777
	mount -t sysfs none /sys
	mkdir -p /dev/pts
	mount -t devpts none /dev/pts
	echo "Mounted InitramFS."
}



#####################
# OverlayFS Prepare #
#####################

overlayfs_prepare() {
	# Prepare OverlayFS Root Directory
	mount -t tmpfs none /mnt
	echo "Prepared OverlayFS Work Area."
	# Create Folders for Root Directory
	mkdir /mnt/dev
	mkdir /mnt/sys
	mkdir /mnt/proc
	mkdir /mnt/tmp
	mkdir /mnt/var
	echo "Created Core OverlayFS Folders."
	# Copy Root Directory to /mnt (RAM)
	cp -a bin etc lib lib64 root sbin src usr var /mnt 2>/dev/null
	echo "Copied Root Filesystem to /mnt."
	# Define Variables for OverlayFS
	DEFAULT_OVERLAY_DIR="/tmp/overlay/overlay"
	DEFAULT_UPPER_DIR="/tmp/overlay/rootfs"
	DEFAULT_WORK_DIR="/tmp/overlay/work"
	# Search for Overlay Content
	echo "Searching for Available Devices for Overlay Content..."
	for DEVICE in /dev/* ; do
		DEV=$(echo "${DEVICE##*/}")
		SYSDEV=$(echo "/sys/class/block/$DEV")
		
		case $DEV in
			*loop*) continue ;;
		esac
		
		if [ ! -d "$SYSDEV" ] ; then
			continue
		fi
		
		mkdir -p /tmp/mnt/device
		DEVICE_MNT=/tmp/mnt/device
		
		OVERLAY_DIR=""
		OVERLAY_MNT=""
		UPPER_DIR=""
		WORK_DIR=""
		
		mount $DEVICE $DEVICE_MNT 2>/dev/null
		if [ -d $DEVICE_MNT/overlay/rootfs -a -d $DEVICE_MNT/overlay/work ] ; then
			# Folder Mount ONLY!
			echo "Found '/overlay' Folder on Device '$DEVICE'."
			touch $DEVICE_MNT/overlay/rootfs/rwtest.pid 2>/dev/null
			if [ -f $DEVICE_MNT/overlay/rootfs/rwtest.pid ] ; then
				# Read/Write Mode
				echo "Device '$DEVICE' is mounted in Read/Write Mode."
				rm -f $DEVICE_MNT/overlay/rootfs/rwtest.pid
				OVERLAY_DIR=$DEFAULT_OVERLAY_DIR
				OVERLAY_MNT=$DEVICE_MNT
				UPPER_DIR=$DEVICE_MNT/overlay/rootfs
				WORK_DIR=$DEVICE_MNT/overlay/work
			else
				# Read Only Mode
				echo "Device '$DEVICE' is mounted in Read Only Mode."
				OVERLAY_DIR=$DEVICE_MNT/overlay/rootfs
				OVERLAY_MNT=$DEVICE_MNT
				UPPER_DIR=$DEFAULT_UPPER_DIR
				WORK_DIR=$DEFAULT_WORK_DIR
			fi
		fi
		if [ "$OVERLAY_DIR" != "" -a "$UPPER_DIR" != "" -a "$WORK_DIR" != "" ] ; then
			mkdir -p $OVERLAY_DIR
			mkdir -p $UPPER_DIR
			mkdir -p $WORK_DIR
			mount -t overlay -o lowerdir=$OVERLAY_DIR:/mnt,upperdir=$UPPER_DIR,workdir=$WORK_DIR none /mnt 2>/dev/null
			OUT=$?
			if [ ! "$OUT" = "0" ] ; then
				echo "OverlayFS Mount Failed. (Probably Formatted with vFAT.)"
				umount $OVERLAY_MNT 2>/dev/null
				rmdir $OVERLAY_MNT 2>/dev/null
				rmdir $DEFAULT_OVERLAY_DIR 2>/dev/null
				rmdir $DEFAULT_UPPER_DIR 2>/dev/null
				rmdir $DEFAULT_WORK_DIR 2>/dev/null
			else
				echo "Overlay data from device '$DEVICE' has been merged."
				break
			fi
		else
			echo "Device '$DEVICE' has no proper Overlay Structure."
		fi
		
		umount $DEVICE_MNT 2>/dev/null
		rm -rf $DEVICE_MNT 2>/dev/null
	done
	# Move Critical File Systems to '/mnt'
	mount --move /dev /mnt/dev
	mount --move /sys /mnt/sys
	mount --move /proc /mnt/proc
	mount --move /tmp /mnt/tmp
	echo "Mount dev, sys, tmp and proc have been moved to /mnt."
}



##################
# Code Execution #
##################

initramfs_prepare

overlayfs_prepare

# Switch Root from InitramFS to OverlayFS
echo "Switching Root from InitramFS to OverlayFS."
exec switch_root /mnt /etc/02_boot.sh
	
echo "(/etc/01_mount) - ERROR [MOUNT_FAILED]"
