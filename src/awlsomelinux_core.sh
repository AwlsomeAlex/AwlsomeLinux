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
JOB_FACTOR=1
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



##############################
# AwlsomeLinux Main Packages #
##############################

LINUX_DOWNLOAD_URL=http://kernel.org/pub/linux/kernel/v4.x/linux-4.4.25.tar.xz
LINUX_ARCHIVE_FILE=${LINUX_DOWNLOAD_URL##*/}
GLIBC_DOWNLOAD_URL=http://ftp.gnu.org/gnu/glibc/glibc-2.24.tar.bz2
GLIBC_ARCHIVE_FILE=${GLIBC_DOWNLOAD_URL##*/}
BUSYBOX_DOWNLOAD_URL=http://busybox.net/downloads/busybox-1.25.1.tar.bz2
BUSYBOX_ARCHIVE_FILE=${BUSYBOX_DOWNLOAD_URL##*/}

############################
# ------------------------ #
# AwlsomeLinux Core Script #
# ------------------------ #
############################



##########
# Kernel #
##########

get_linux() {
	echo "== Get Linux (Start) =="
	
	# Change Directory to 'core/source'
	cd core/source
	
	# Download Kernel Version Defined in AwlsomeLinux Core Packages
	echo "Downloading Linux Kernel Source Archive..."
	wget -c $LINUX_DOWNLOAD_URL
	
	# Clean out old Linux Kernel Work Directory (If 'make clean' or 'make all' wasn't executed)
	rm -rf $SRC_DIR/core/work/linux
	mkdir $SRC_DIR/core/work/linux
	
	# Extract .xz Archive to 'core/work/linux'
	echo "Extracting Linux Kernel..."
	tar -xvf $LINUX_ARCHIVE_FILE -C $SRC_DIR/core/work/linux
	
	cd $SRC_DIR
	
	echo "== Get Linux (Stop) =="
}

build_linux() {
	echo "== Build Linux (Start) =="
	
	# Change Directory to Linux Work
	cd core/work/linux
	echo "Preparing Linux Kernel Directories..."
	
	# Prepare Linux Install Area
	rm -rf $SRC_DIR/core/install/linux
	mkdir $SRC_DIR/core/install/linux
	
	# Change Directory to Extracted Archive Folder
	cd $(ls -d linux-*)
	
	# Clean Linux Kernel Configuration
	echo "Cleaning Linux Kernel Configuration..."
	make mrproper -j $NUM_JOBS
	
	# Create Default Configuration
	echo "Creating Default Linux Kernel Configuration..."
	make defconfig -j $NUM_JOBS
	
	# Configure Kernel:
	echo "Adding Extra Kernel Arguments for Configuration..."
	sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"awlsomelinux\"/" .config
	sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config
	sed -i "s/.*\\(CONFIG_KERNEL_.*\\)=y/\\#\\ \\1 is not set/" .config 
	sed -i "s/.*CONFIG_KERNEL_XZ.*/CONFIG_KERNEL_XZ=y/" .config
	sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config
	sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/CONFIG_LOGO_LINUX_CLUT224=y/" .config
	sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config
	sed -i "s/.*CONFIG_EFI_STUB.*/CONFIG_EFI_STUB=y/" .config
	grep -q "CONFIG_X86_32=y" .config
	if [ $? = 1 ] ; then
		echo "CONFIG_EFI_MIXED=y" >> .config
	fi
	
	# Build Linux Kernel
	echo "Building Linux Kernel..."
	make \
		CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
		bzImage -j $NUM_JOBS
		
	# Install Linux Kernel
	echo "Installing Linux Kernel..."
	cp arch/x86/boot/bzImage \
		$SRC_DIR/core/install/linux/kernel
		
	# Generate Linux Kernel Header Files
	echo "Generating Linux Kernel Headers..."
	make \
		INSTALL_HDR_PATH=$SRC_DIR/core/install/linux \
		headers_install -j $NUM_JOBS
		
	# Remember Linux Kernel Installed Directory
	LINUX_INSTALLED=$SRC_DIR/core/install/linux
	
	cd $SRC_DIR
		
	echo "== Build Linux (Stop) =="
}



#########
# Glibc # 
#########

get_glibc() {
	echo "== Get Glibc (Start) =="
	
	# Change Directory to 'core/source'
	cd core/source
	
	# Download Glibc Version Defined in AwlsomeLinux Core Packages
	echo "Downloading Glibc Source Archive..."
	wget -c $GLIBC_DOWNLOAD_URL
	
	# Clean out old Glibc Work Directory (If 'make clean' or 'make all' wasn't executed)
	rm -rf $SRC_DIR/core/work/glibc
	mkdir $SRC_DIR/core/work/glibc
	
	# Extract .xz Archive to 'core/work/glibc'
	echo "Extracting Glibc..."
	tar -xvf $GLIBC_ARCHIVE_FILE -C $SRC_DIR/core/work/glibc
	
	cd $SRC_DIR
	
	echo "== Get Glibc (Stop) =="
}

build_glibc() {
	echo "== Build Glibc (Start) =="
	
	# Change Directory to Glibc Work
	cd core/work/glibc
	echo "Preparing Glibc Directories..."
	
	# Change Directory to Extracted Glibc and Remember it
	cd $(ls -d glibc-*)
	GLIBC_SRC=$(pwd)
	cd ..
	
	# Prepare Glibc Object Work Area
	rm -rf glibc_objects
	mkdir glibc_objects
	
	# Prepare Glibc Install Area and Remember it
	rm -rf $SRC_DIR/core/install/glibc
	mkdir $SRC_DIR/core/install/glibc
	GLIBC_INSTALLED=$SRC_DIR/core/install/glibc
	
	# Change Directory to Glibc Object Directory
	cd glibc_objects
	
	# Configure Glibc:
	echo "Configuring Glibc..."
	$GLIBC_SRC/configure \
		--prefix= \
		--with-headers=$LINUX_INSTALLED/include \
		--without-gd \
		--without-selinux \
		--disable-werror \
		CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
	
	# Build Glibc
	echo "Building Glibc..."
	make -j $NUM_JOBS
		
	# Install Glibc
	echo "Installing Glibc..."
	make install \
		DESTDIR=$GLIBC_INSTALLED \
		-j $NUM_JOBS
		
	cd $SRC_DIR
		
	echo "== Build Glibc (Stop) =="
}

prepare_glibc() {
	
	echo "== Prepare Glibc (Start) =="
	
	# Change Directory to Glibc Installed
	cd core/install
	
	# Prepare Glibc
	echo "Preparing Glibc..."
	rm -rf glibc_prepared
	cp -r glibc glibc_prepared
	
	# Change Directory to Glibc Prepared and Remember it
	cd glibc_prepared
	GLIBC_PREPARED=$(pwd)
	
	# Create a /usr directory and link it with Kernel Headers + Functions
	mkdir -p usr
	cd usr
	ln -s ../include include
	ln -s ../lib lib
	cd ../include
	ln -s $LINUX_INSTALLED/include/linux linux
	ln -s $LINUX_INSTALLED/include/asm asm
	ln -s $LINUX_INSTALLED/include/asm-generic asm-generic
	ln -s $LINUX_INSTALLED/include/mtd mtd
	
	cd $SRC_DIR
	
	echo "== Prepare Glibc (Stop) =="
}



###################
# Busybox Compile #
###################

get_busybox() {
	echo "== Get Busybox (Start) =="
	
	# Change Directory to 'core/source'
	cd core/source
	
	# Download Busybox Version Defined in AwlsomeLinux Core Packages
	echo "Downloading Busybox Source Archive..."
	wget -c $BUSYBOX_DOWNLOAD_URL
	
	# Clean out old Busybox Work Directory (If 'make clean' or 'make all' wasn't executed)
	rm -rf $SRC_DIR/core/work/busybox
	mkdir $SRC_DIR/core/work/busybox
	
	# Extract .xz Archive to 'core/work/busybox'
	echo "Extracting Busybox..."
	tar -xvf $BUSYBOX_ARCHIVE_FILE -C $SRC_DIR/core/work/busybox
	
	cd $SRC_DIR
	
	echo "== Get Busybox (Stop) =="
}

build_busybox() {
	echo "== Build Busybox (Start) =="
	
	# Change Directory to Busybox Work
	cd core/work/busybox
	echo "Preparing Busybox Directories..."
	
	# Change Directory to Extracted Busybox
	cd $(ls -d busybox-*)
	
	# Clean Busybox Configuration
	echo "Preparing Busybox..."
	make distclean -j $NUM_JOBS
	
	# Generate Busybox Default Configuration
	echo "Generating Busybox Configuration File..."
	make defconfig -j $NUM_JOBS
	sed -i "s/.*CONFIG_INETD.*/CONFIG_INETD=n/" .config
	
	# Build Busybox
	echo "Building Busybox..."
	make \
		EXTRA_CFLAGS="-Os -s -fno-stack-protector -U_FORITFY_SOURCE" \
		busybox -j $NUM_JOBS
		
	# Install Busybox
	echo "Installing Busybox..."
	make \
		CONFIG_PREFIX="$SRC_DIR/core/install/busybox"
		install -j $NUM_JOBS
		
	cd $SRC_DIR
		
	echo "== Build Busybox (Stop) =="
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

get_linux

build_linux

get_glibc

build_glibc

prepare_glibc
