# A simple Makefile for configuring and building AwlsomeLinux.
# This script will have multiple operations which will help
# the user generate a fully operational AwlsomeLinux Image.

# For additional operations, please run the following command:
# 'make help'

.DEFAULT_GOAL := help

all: clean
	@echo "Executing the main AwlsomeLinux Creation Script..."
	@time sh awlsomelinux_core.sh 2>&1 | tee awlsomelinux.log

clean:
	@echo "Removing AwlsomeLinux Core Packages' Source Files..."
	@rm -rf core/source
	@echo "Removing AwlsomeLinux Core Packages' Work Files..."
	@rm -rf core/work
	@echo "Removing AwlsomeLinux Core Pre-Generated Packages..."
	@rm -rf core/core
	@echo "Removing Pre-Generated AwlsomeLinux ISO Image..."
	@rm -rf awlsomelinux.iso
	@echo "Removing AwlsomeLinux Image Directory Content..."
	@rm -rf image/*
	@echo "Removing AwlsomeLinux Overlay Packages' Source Files..."
	@rm -rf overlay/source
	@echo "Removing AwlsomeLinux Overlay Packages' Work Files..."
	@rm -rf overlay/work
	@echo "Removing AwlsomeLinux Overlay Pre-Generated Packages..."
	@rm -rf overlay/overlay
	@echo "Remvoing AwlsomeLinux Build Log File..."
	@rm -rf awlsomelinux.log

qemu:


src:


help:
	@echo ""
	@echo " make all	Clean the Workspace and Generate AwlsomeLinux Image."
	@echo ""
	@echo " make clean 	Remove all Generated Files."
	@echo ""
	@echo " make src	Generate '.tar.xz' source archive of AwlsomeLinux"
	@echo ""
	@echo " make qemu	Run AwlsomeLinux in QEMU."
	@echo ""
	@echo " make help	This is the default target."
	@echo ""
