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
	echo -e "\e[1;32m(Pass) \e[0mSupressed Kernel Messages."
	# Prepare and Mount InitramFS
	mount -t devtmpfs none /dev -o size=64k,mode=0755
	mount -t proc none /proc
	mount -t sysfs none /sys
	sysctl -w kernel.hotplug=/sbin/mdev
	mount -t tmpfs none /tmp -o mode=1777
  	mkdir -p /dev/pts
	mount -t devpts none /dev/pts
	mdev -s
	echo -e "\e[1;32m(Pass) \e[0mMounted InitramFS."
}



#####################
# OverlayFS Prepare #
#####################

overlayfs_prepare() {
	# Prepare OverlayFS Root Directory
	mount -t tmpfs none /mnt
	echo -e "\e[1;32m(Pass) \e[0mPrepared OverlayFS Root Filesystem."
	# Create Folders for Root Directory
	mkdir /mnt/dev
	mkdir /mnt/sys
	mkdir /mnt/proc
	mkdir /mnt/tmp
	mkdir /mnt/var
	echo -e "\e[1;32m(Pass) \e[0mCore OverlayFS Directories Created."
	# Copy Root Directory to /mnt (RAM)
	cp -a bin etc lib lib64 root sbin src usr var /mnt 2>/dev/null
	echo -e "\e[1;32m(Pass) \e[0mInitramFS Copied to /mnt."
	# Define Variables for OverlayFS
	DEFAULT_OVERLAY_DIR="/tmp/overlay/overlay"
	DEFAULT_UPPER_DIR="/tmp/overlay/rootfs"
	DEFAULT_WORK_DIR="/tmp/overlay/work"
	# Search for Overlay Content
	echo -e "\e[1;94m(****) \e[0mSearching Available Devices for OverlayFS..."
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
			echo -e "\e[1;32m(Pass) \e[0mOverlayFS Directory Found on '$DEVICE'."
			touch $DEVICE_MNT/overlay/rootfs/rwtest.pid 2>/dev/null
			if [ -f $DEVICE_MNT/overlay/rootfs/rwtest.pid ] ; then
				# Read/Write Mode
				echo -e "\e[1;32m(Pass) \e[0mOverlayFS is Mounted as Read/Write on '$DEVICE'."
				rm -f $DEVICE_MNT/overlay/rootfs/rwtest.pid
				OVERLAY_DIR=$DEFAULT_OVERLAY_DIR
				OVERLAY_MNT=$DEVICE_MNT
				UPPER_DIR=$DEVICE_MNT/overlay/rootfs
				WORK_DIR=$DEVICE_MNT/overlay/work
			else
				# Read Only Mode
				echo -e "\e[1;32m(Pass) \e[0mOverlayFS is Mounted as Read Only on '$DEVICE'."
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
				echo -e "\e[1;31m(Fail) \e[0mOverlayFS Mount Failed. \e[1m(Formatted Under vFat?)\e[0m"
				umount $OVERLAY_MNT 2>/dev/null
				rmdir $OVERLAY_MNT 2>/dev/null
				rmdir $DEFAULT_OVERLAY_DIR 2>/dev/null
				rmdir $DEFAULT_UPPER_DIR 2>/dev/null
				rmdir $DEFAULT_WORK_DIR 2>/dev/null
			else
				echo -e "\e[1;32m(Pass) \e[0mOverlayFS Data on '$DEVICE' Merged to /mnt."
				break
			fi
		else
			echo -e "\e[1;95m(Skip) \e[0mDevice '$DEVICE' has No Overlay Structure."
		fi
		
		umount $DEVICE_MNT 2>/dev/null
		rm -rf $DEVICE_MNT 2>/dev/null
	done
	# Move Critical File Systems to '/mnt'
	mount --move /dev /mnt/dev
	mount --move /sys /mnt/sys
	mount --move /proc /mnt/proc
	mount --move /tmp /mnt/tmp
	echo -e "\e[1;32m(Pass) \e[0mMounted /dev, /sys, /tmp and /proc to /mnt."
}



##################
# Code Execution #
##################

initramfs_prepare

overlayfs_prepare

# Switch Root from InitramFS to OverlayFS
echo -e "\e[1;94m(****) \e[0mSwitching Root to OverlayFS..."
exec switch_root /mnt /etc/02_init.sh
	
echo -e "\e[1;31m(Fail) \e[0mMount Script Failed."
