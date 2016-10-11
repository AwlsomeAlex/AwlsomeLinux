#!/bin/sh
## AwlsomeLinux Boot Script 
## Based on Ivandavidov's Minimal Linux Live Project (GNU GPLv3)

echo -e "Welcome to AwlsomeLinux! (/sbin/init)"

## Looks for Network Devices and Sets them Up.

for DEVICE in /sys/class/net/* ; do
	echo "Found Network Device ${DEVICE##*/}"
	ip link set ${DEVICE##*/} up
	[ ${DEVICE##*/} != lo ] && udhcpc -b -i ${DEVICE##*/} -s /etc/05_rc.dhcp
done
