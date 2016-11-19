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
#                       +--(1) /etc/03_boot.sh (this file)
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
#                           +--(6) /etc/04_pivot-root.sh [EXPERIMENTAL!]

echo -e "\e[1;7mAwlsomeLinux Busybox Initialization (Release 1.2.1)\e[0m"
for DEVICE in /sys/class/net/* ; do
	echo -e "\e[1;32m(Pass) \e[0mFound Network Device ${DEVICE##*/}"
	ip link set ${DEVICE##*/} up
	[ ${DEVICE##*/} != lo ] && udhcpc -b -i ${DEVICE##*/} -s /etc/rc.dhcp
done
echo -e "\e[1;32m(Pass) \e[0mAwlsomeLinux has Successfully Booted."
clear
