#!/bin/sh

# AwlsomeLinux Initialization Chart:
#
# /init
#  |
#  +--(1) /etc/01_mount.sh
#          |
#          +--(2) /etc/02_init.sh (this file)
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
echo -e "\e[1;32m(Pass) \e[0mSwitch Root to OverlayFS Successful."
echo -e "\e[1;94m(****) \e[0mExecuting /sbin/init as PID 1..."
exec /sbin/init

echo -e "\e[1;31m(Fail) \e[0mInit Script Failed."
	
