#!/bin/sh
## AwlsomeLinux Overlayfs Init Script 
## Based on Ivandavidov's Minimal Linux Live Project (GNU GPLv3)

## Print First Init Message.
cat /etc/msg/03_init_01.txt

## Wait for Keyboard Strike or 5 Seconds.
read -t 5 -n1 -s key

if [ "$key" = "" ] ; then
	## Using /etc/inittab as reference.
	echo "Executing /sbin/init as PID 1."
	exec /sbin/init
else
	# Print Second Init Message.
	cat /etc/msg/03_init_02.txt
	
	if [ "$PID_SHELL" = "true" ] ; then
		## PID1_SHELL flag is set which means Terminal is already in control.
		unset PID1_SHELL
		exec sh
	else
		## Activate Interactive Shell.
		exec setsid cttyhack sh
	fi
fi

echo "(/etc/03_init.sh) - ERROR CODE 0x0003 [OVERLAY INIT ERROR]"

## Wait until Keyboard has been Striked.
read -n1 -s
