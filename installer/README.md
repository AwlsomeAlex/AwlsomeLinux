# AwlsomeLinux Installer

## What is AwlsomeLinux Installer?
AwlsomeLinux Installer is a WIP Side-Project of AwlsomeLinux to add the ability to install AwlsomeLinux on
Thumb Drives, and in reality Hard Drives as well. The process is quite simple, but complicated at the same
time, that's why I'm drawing a diagram for later. The installer will be very simple, not creating an
actual Mounted Filesystem, but use ext4/ext3/ext2 as a place to mount, so all file will reside in the
OverlayFS, but be accessible when loaded by the initramfs. The drawback being it will be slower and won't
be **Physically** installed, but it's a start until I know what I'm doing.

## Dependencies:
I am currently working on an Arch Remix which will include a simple desktop (IceWM or LxQT) and will help
the user throughout the Install Process. I'm using ArchLinux due to the ability to pick between x86 and
x86_64 on one physical ISO, meaning the disk will be larger, but easier/simpler. Eventually when
AwlsomeLinux becomes self-hosted the install process can be carried out on the Live CD, but until then
this will have to do.
