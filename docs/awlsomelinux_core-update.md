# AwlsomeLinux Core Update Process (Another Minimal Package Manager - Core Updater)
The AwlsomeLinux Core Update Process is a simple yet complicated method (along with untested) of updating AwlsomeLinux but leaving the OverlayFS intact.

## The ONLY Way:
The only way this could possibly work is if the mount for AwlsomeLinux is read/write. This is tested impossible with AwlsomeLinux in the LiveCD state, but due to the ability for a user to (crudely) install AwlsomeLinux, that specific mountpoint (/tmp/mnt/device) can be accessed with read/write permission.

## What's going on?
The only way so far this can be achieved is if (/tmp/mnt/device) is read/write. If so we can continue. Basically this mountpoint is used early in boot to overlay the Core and the OverlayFS, but for some odd reason is never closed, thankfully. Due to this any modification made to this directory will alter the Filesystem (ext2) and save the changes.

## The Plan:
The plan is simple (we kill the Batman.) all we need to do is download an updated version of 'kernel.xz' (Contains the Linux Kernel) and an updated version of 'core.xz' (Contains Linux Kernel Firmware/Modules/Headers). Once these are included, the Bootloader (Syslinux) will add these two componients into the boot menu. This method could "MAYBE" also be used to update Busybox, but probably not GlibC as that is too difficult to update (Without breaking things) and will probably be fully moved to the OverlayFS (Eventually).

## What's the catch?
THIS IS NOT TESTED TO ANYPOINT! Thats the first thing, the second thing is I'm not sure how an updated Linux Kernel will react to any programs residing in the OverlayFS (I'm assuming nothing should go wrong, due to nothing "HOPEFULLY" breaking between kernel releases). 

## How this will be achived:
A program using Ncurses and Dialog (Once Added) will be created called 'ampm-core' and that will be used to select which Kernel to add/update/remove, and will automatically change the Bootmenu. The idea will be this:

There will be a compressed file called 'AwlsomeLinux-4.4.0-yy.xz' and it will contain the following:
* Updated Linux Kernel (kernel-4.4.0-yy.xz)
* Updated Core (core-4.4.0-yy.xz)
* Updated Syslinux Bootloader (syslinux.cfg)
* Update Script [Tells everything what to do] (update-4.4.0-yy.sh)

Once added, the Update Script will remove the only Configuration, copy the new one in, and copy in the new componients. A method of removal will be added after a reboot in the menu.
