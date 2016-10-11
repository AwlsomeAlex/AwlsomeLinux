#!/bin/sh
## AwlsomeLinux Overlay and RAM Init Script 
## Based on Ivandavidov's Minimal Linux Live Project (GNU GPLv3)

## Create the Mountpoint in RAM.
mount -t tmpfs none /mnt

## Create all critical directories for the Filesystem.
mkdir /mnt/dev
mkdir /mnt/sys
mkdir /mnt/proc
mkdir /mnt/tmp
mkdir /mnt/var
echo "Created all critical directories."

## Copy root folder into mountpoint.
cp -a bin etc lib lib64 root sbin src usr var /mnt 2>/dev/null

## Code Below NEEDS to be Simplified, as I am only using the Folder Method with Read/Write.

DEFAULT_OVERLAY_DIR="/tmp/minimal/overlay"
DEFAULT_UPPER_DIR="/tmp/minimal/rootfs"
DEFAULT_WORK_DIR="/tmp/minimal/work"

echo "Searching available devices for overlay content..."
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
  if [ -d $DEVICE_MNT/minimal/rootfs -a -d $DEVICE_MNT/minimal/work ] ; then
    # folder
    echo "  Found '/minimal' folder on device '$DEVICE'."
    touch $DEVICE_MNT/minimal/rootfs/minimal.pid 2>/dev/null
    if [ -f $DEVICE_MNT/minimal/rootfs/minimal.pid ] ; then
      # read/write mode
      echo "  Device '$DEVICE' is mounted in read/write mode."

      rm -f $DEVICE_MNT/minimal/rootfs/minimal.pid

      OVERLAY_DIR=$DEFAULT_OVERLAY_DIR
      OVERLAY_MNT=$DEVICE_MNT
      UPPER_DIR=$DEVICE_MNT/minimal/rootfs
      WORK_DIR=$DEVICE_MNT/minimal/work
    else
      # read only mode
      echo "  Device '$DEVICE' is mounted in read only mode."

      OVERLAY_DIR=$DEVICE_MNT/minimal/rootfs
      OVERLAY_MNT=$DEVICE_MNT
      UPPER_DIR=$DEFAULT_UPPER_DIR
      WORK_DIR=$DEFAULT_WORK_DIR
    fi
  elif [ -f $DEVICE_MNT/minimal.img ] ; then
    #image
    echo "  Found '/minimal.img' image on device '$DEVICE'."

    mkdir -p /tmp/mnt/image
    IMAGE_MNT=/tmp/mnt/image

    LOOP_DEVICE=$(losetup -f)
    losetup $LOOP_DEVICE $DEVICE_MNT/minimal.img

    mount $LOOP_DEVICE $IMAGE_MNT
    if [ -d $IMAGE_MNT/rootfs -a -d $IMAGE_MNT/work ] ; then
      touch $IMAGE_MNT/rootfs/minimal.pid 2>/dev/null
      if [ -f $IMAGE_MNT/rootfs/minimal.pid ] ; then
        # read/write mode
        echo "  Image '$DEVICE/minimal.img' is mounted in read/write mode."

        rm -f $IMAGE_MNT/rootfs/minimal.pid

        OVERLAY_DIR=$DEFAULT_OVERLAY_DIR
        OVERLAY_MNT=$IMAGE_MNT
        UPPER_DIR=$IMAGE_MNT/rootfs
        WORK_DIR=$IMAGE_MNT/work
      else
        # read only mode
        echo "  Image '$DEVICE/minimal.img' is mounted in read only mode."

        OVERLAY_DIR=$IMAGE_MNT/rootfs
        OVERLAY_MNT=$IMAGE_MNT
        UPPER_DIR=$DEFAULT_UPPER_DIR
        WORK_DIR=$DEFAULT_WORK_DIR
      fi
    else
      umount $IMAGE_MNT
      rm -rf $IMAGE_MNT
    fi
  fi

  if [ "$OVERLAY_DIR" != "" -a "$UPPER_DIR" != "" -a "$WORK_DIR" != "" ] ; then
    mkdir -p $OVERLAY_DIR
    mkdir -p $UPPER_DIR
    mkdir -p $WORK_DIR

    mount -t overlay -o lowerdir=$OVERLAY_DIR:/mnt,upperdir=$UPPER_DIR,workdir=$WORK_DIR none /mnt 2>/dev/null

    OUT=$?
    if [ ! "$OUT" = "0" ] ; then
      echo "  Mount failed (probably on vfat)."
      
      umount $OVERLAY_MNT 2>/dev/null
      rmdir $OVERLAY_MNT 2>/dev/null
      
      rmdir $DEFAULT_OVERLAY_DIR 2>/dev/null
      rmdir $DEFAULT_UPPER_DIR 2>/dev/null
      rmdir $DEFAULT_WORK_DIR 2>/dev/null
    else
      # All done, time to go.
      echo "  Overlay data from device '$DEVICE' has been merged."
      break
    fi
  else
    echo "  Device '$DEVICE' has no proper overlay structure."
  fi

  umount $DEVICE_MNT 2>/dev/null
  rm -rf $DEVICE_MNT 2>/dev/null
done

## Move critical directories to new mountpoint.
mount --move /dev /mnt/dev
mount --move /sys /mnt/sys
mount --move /proc /mnt/proc
mount --move /tmp /mnt /tmp
echo "Mounted Critical Directories /dev, /sys, /proc, /tmp to /mnt."

## Switches Root from initramfs to overlayfs.
echo "Switching from initramfs root area to overlayfs root area."
exec switch_root /mnt /etc/03_init.sh

echo "(/etc/02_overlay.sh) - ERROR CODE 0x0002 [OVERLAY ERROR]"

## Wait for Keyboard Strike.
read -n1 -s
