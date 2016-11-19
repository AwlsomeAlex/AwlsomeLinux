# A simple Makefile for configuring and building AwlsomeLinux.
# This script will have multiple operations which will help
# the user generate a fully operational AwlsomeLinux Image.

# For additional operations, please run the following command:
# 'make help'

.DEFAULT_GOAL := help

all: clean
	@echo "Executing AwlsomeLinux Creation Scripts..."
	@time sh awlsomelinux_core.sh 2>&1 | tee awlsomelinux_core.log
	@time sh awlsomelinux_image.sh 2>&1 | tee awlsomelinux_image.log
	
core:
	@echo "Cleaning Out Core Directories Only..."
	@rm -rf core/core
	@mkdir core/core
	@rm -rf core/source
	@mkdir core/source
	@rm -rf core/work
	@mkdir core/work
	@rm -rf core/install
	@mkdir core/install
	@rm -rf awlsomelinux.iso
	@rm -rf awlsomelinux_core.log
	@echo "Executing AwlsomeLinux Core Creation Script Only..."
	@time sh awlsomelinux_core.sh 2>&1 | tee awlsomelinux_core.log
	
image:
	@echo "Cleaning Out Image Directory Only..."
	@rm -rf isoimage/*
	@rm -rf awlsomelinux.iso
	@rm -rf awlsomelinux_image.log
	@echo "Executing AwlsomeLinux Image Creation Script Only..."
	@time sh awlsomelinux_image.sh 2>&1 | tee awlsomelinux_image.log

overlay:
	@echo "Cleaning Out Overlay Directory Only..."
	@rm -rf overlay/*
	@rm -rf awlsomelinux_overlay.log
	@mkdir overlay/work overlay/source overlay/install
	@mkdir overlay/install/usr
	@echo "Executing AwlsomeLinux Overlay Creation Script Only..."
	@time sh awlsomelinux_overlay.sh 2>&1 | tee awlsomelinux_overlay.log

clean:
	@echo "Removing AwlsomeLinux Core Packages' Source Archives..."
	@rm -rf core/source
	@mkdir core/source
	@echo "Removing AwlsomeLinux Core Packages' Work Files..."
	@rm -rf core/work
	@mkdir core/work
	@echo "Removing AwlsomeLinux Core Packages' Install Directory..."
	@rm -rf core/install
	@mkdir core/install
	@echo "Removing AwlsomeLinux Core Core Packing Directory..."
	@rm -rf core/core
	@mkdir core/core
	@echo "Removing Pre-Generated Core Archive..."
	@rm -rf core/core.cpio.xz
	@echo "Removing Pre-Generated AwlsomeLinux ISO Image..."
	@rm -rf awlsomelinux.iso
	@echo "Removing AwlsomeLinux Image Directory Content..."
	@rm -rf isoimage/*
	@echo "Removing AwlsomeLinux Overlay Packages' Source Archives..."
	@rm -rf overlay/source
	@mkdir overlay/source
	@echo "Removing AwlsomeLinux Overlay Packages' Work Files..."
	@rm -rf overlay/work
	@mkdir overlay/work
	@echo "Removing AwlsomeLinux Overlay Packages' Install Directory..."
	@rm -rf overlay/install
	@mkdir overlay/install
	@echo "Removing AwlsomeLinux Overlay OverlayFS Packing Directory..."
	@rm -rf overlay/overlayfs
	@mkdir overlay/overlayfs
	@echo "Remvoing AwlsomeLinux Build Log File..."
	@rm -rf awlsomelinux_core.log
	@rm -rf awlsomelinux_image.log
	@rm -rf awlsomelinux_overlay.log

qemu64:
	@if [ ! -f ./awlsomelinux.iso ]; then echo "AwlsomeLinux Image not found. Please run 'make all'"; exit 1; fi
	@echo "Launching QEMU..."
	@qemu-system-x86_64 -m 256M -cdrom awlsomelinux.iso -boot d -vga std
	
qemu32:
	@if [ ! -f ./awlsomelinux.iso ]; then echo "AwlsomeLinux Image not found. Please run 'make all'"; exit 1; fi
	@echo "Launching QEMU..."
	@qemu-system-i386 -m 256M -cdrom awlsomelinux.iso -boot d -vga std

help:
	@echo ""
	@echo " make all	Clean the Workspace and Generate AwlsomeLinux Image."
	@echo ""
	@echo " make core	Generate the core.xz ONLY."
	@echo ""
	@echo " make image	Compile the ISO Image ONLY."
	@echo ""
	@echo " make overlay	Generate the OverlayFS ONLY."
	@echo ""
	@echo " make clean 	Remove all Generated Files."
	@echo ""
	@echo " make qemu(bit)	Run AwlsomeLinux in QEMU (bit is the architecture of AwlsomeLinux which was compiled [Host])."
	@echo ""
	@echo " make help	Shows this message, also the default (blank) target."
	@echo ""
