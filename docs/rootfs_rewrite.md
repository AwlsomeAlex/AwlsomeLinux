# RootFS Initialization Rewrite Documentation
The Rewritten Version of the RootFS InitramFS Initialization into the OverlayFS is to simplify the boot process into one executable script "/init". The purpose of this is to eliminate the need of user input whenever the system boots up, and to use funtions within the script instead of calling upon indivisual scripts.


## Section 1 (InitramFS Boot):

### Paragraph 1 (InitramFS Initialization):
When the system turns on, the Kernel (kernel.xz) and Core InitramFS (core.xz) are called by Syslinux 6.03 Bootloader. Once the Kernel is initalized, it then starts up the "init" script provided by the InitramFS. First thing this script does is call upon the "initramfs_init" function. Inside this function the Kernel Messages are supressed "Due to Clutter" and the InitramFS is mounted on the RAM, including the **devtmpfs (/dev), proc (/proc), tmpfs (/tmp), sysfs (/sys), and devpts (/dev/pts).** Once these are mounted, the system will be at a place where a few extra lines of code would provide the user a barely useable interface **WITHOUT** the InitramFS and the proper mounting of the remaining directories (/etc, /bin, etc.).
