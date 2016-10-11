#!/bin/sh
## AwlsomeLinux Core Mount Initialization Script 
## Based on Ivandavidov's Minimal Linux Live Project (GNU GPLv3)

## Turn off Most Kernel Messages.
dmesg -n 1
echo "Most Kernel messages have been iqnored."

## Mount Core Filesystems.
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t tmpfs none /tmp -o mode=1777
mount -t sysfs none /sys

mkdir -p /dev/pts

mount -t devpts none /dev/pts

echo "Mounted all Core Filesystems."
