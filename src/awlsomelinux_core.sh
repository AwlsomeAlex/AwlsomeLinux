#!/bin/sh

## AwlsomeLinux Core Creation Script
## Created by AwlsomeAlex (GNU GPLv3)

##############################
# -------------------------- #
# AwlsomeLinux Configuration #
# -------------------------- #
##############################



##########################
# AwlsomeLinux Variables #
##########################

SRC_DIR=$(pwd)
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



##############################
# AwlsomeLinux Main Packages #
##############################

KERNEL_DOWNLOAD_URL=http://kernel.org/pub/linux/kernel/v4.x/linux-4.4.25.tar.xz



############################
# ------------------------ #
# AwlsomeLinux Core Script #
# ------------------------ #
############################



##################
# Kernel Compile #
##################

get_kernel() {
	echo "Get Kernel"
}

build_kernel() {
	echo "Build Kernel"
}



#################
# Glibc Compile # 
#################

get_glibc() {
	echo "Get Glibc"
}

build_glibc() {
	echo "Build Glibc"
}

prepare_glibc() {
	echo "Prepare Glibc"
}



###################
# Busybox Compile #
###################

get_busybox() {
	echo "Get Busybox"
}

build_busybox() {
	echo "Build Busybox"
}



###################
# RootFS Creation #
###################

prepare_src() {
	echo "Prepare Source Code"
}

generate_rootfs() {
	echo "Generate RootFS"
}

pack_rootfs() {
	echo "Pack RootFS"
}



####################
# Extract Syslinux #
####################

get_syslinux() {
	echo "Get Syslinux"
}

