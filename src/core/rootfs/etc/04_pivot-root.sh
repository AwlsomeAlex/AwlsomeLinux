#!/bin/sh

# AwlsomeLinux Initialization Chart:
#
# /init
#  |
#  +--(1) /etc/01_mount.sh
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
#                       +--(3) /bin/login (Alt + F2)
#                       |
#                       +--(4) /bin/login (Alt + F3)
#                       |
#                       +--(5) /bin/sh (Alt + F4 [Recovery/Debug Shell])
#                       |
#                       +--(5) /bin/login (Alt + F4 [PUBLIC RELEASES ONLY])
#                           |
#                           +--(6) /etc/04_pivot-root.sh [EXPERIMENTAL!]  (this file)

cd /

mkdir n

mount -t tmpfs none /n

cp -a bin sbin usr lib lib64 var /n

cd n

mkdir -p dev/pts proc sys tmp old

mount --move /dev/pts dev/pts
mount --move /dev dev
mount --move /proc proc
mount --move /sys sys
mount --move /tmp tmp

pivot_root . old

chroot . /bin/sh
