# AwlsomeLinux Installation Process
The AwlsomeLinux Installation Process is a complex, multi-step installation where the default sets will be installed...

## Installed Componients:
* AwlsomeLinux Core (initramfs)
* AwlsomeLinux Boot (vmlinuz + extlinux)
* AwlsomeLinux Overlay (User + Additional Packages)

### AwlsomeLinux Core:
The AwlsomeLinux Core Package is one of two absolute packages that will be installed with AwlsomeLinux. It contains the bare minimum of AwlsomeLinux Including:
* Boot Directories (/proc, /sys, /dev)
* Busybox Initialization (AwlsomeLinux Initialization Process)
* Default Packages (Busybox, Linux Kernel [Headers/Firmware], GlibC [Bare Minimum])
* Enough to Mount and Boot the OverlayFS

### AwlsomeLinux Boot:
The AwlsomeLinux Boot Package is the second absolute package that will be installed with AwlsomeLinux. It contains the bare minimum of the AwlsomeLinux Boot Process Including:
* vmlinuz (Linux Kernel Executable [bzImage])
* syslinux/extlinux (Syslinux Boot Loader)


### AwlsomeLinux Overlay:
The AwlsomeLinux Overlay Packages is a recommended but optional package that can be installed with AwlsomeLinux. It contains the rest of the InitramFS and (with correct permission) can contain the user's data and additional programs. It contains by default:
* The rest of GlibC (GNU C Library)
* The rest of the Root Filesystem
* User Login Prompt
* Root User Directories/Permissions

## Installation Process:
The AwlsomeLinux Installation Process with be a three-step process which will install all 3 (2 minimum) componients into AwlsomeLinux.
* Step 1 - File System Creation
* Step 2 - XZ Archive Download/Copy
* Step 3 - AwlsomeLinux Configuration

### Step 1 - File System Creation
This step in the AwlsomeLinux Installation will create the required file system for the InitramFS, Boot, and OverlayFS to reside.
* 1. The Requested Location (/dev/sdx) will be formatted.
* 2. The Required Mounts will be created (/dev/sdx1 - Boot, /dev/sdx2 - Root, /dev/sdx3 - Home).
* 3. The Required File System Type will be created (Boot - ext2, Root - ext4, Home - ext4).
* 4. An FSTAB of the mounts will be created for AwlsomeLinux Initialization to boot.
* 5. The Filesystems will be temporary mounted and linked for Step 2.

### Step 2 - XZ Archive Download/Copy
This step in the AwlsomeLinux Installation will download/copy the compressed archives of AwlsomeLinux and place them in their required places.
* 1. The Archives will be Downloaded/Copied 
