#!/bin/sh
# AwlsomeLinux Kernel Compile Script

###################
# Kernel Settings #
###################

SRC_DIR=$(pwd)
DOWNLOAD_URL=$(grep -i ^KERNEL_SOURCE_URL .config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



####################
# Get Linux Kernel #
####################

echo "--- KERNEL BEGIN ---"

cd source

# Downloads the latest Linux Kernel and puts it in the Source Directory.
echo "Downloading Kernel Source Bundle from Kernel.org"
wget -c $DOWNLOAD_URL

# Delete Kernel Work Directory
echo "Removing Old Kernel Work Area. Please wait..."
rm -rf ../work/kernel
mkdir ../work/kernel

# Extract Linux Kernel to '/work/kernel/linux-[version]'.
tar -xvf $ARCHIVE_FILE -C ../work/kernel

cd $SRC_DIR



######################
# Build Linux Kernel #
######################

cd work/kernel

# Prepare Kernel Install Area.
rm -rf kernel_installed
mkdir kernel_installed

# Change Directory to the Kernel Source Directory.
cd $(ls -d linux-*)

# Clean Kernel Source including Configuration Files.
echo "Cleaning Kernel Source Area..."
make mrproper -j $NUM_JOBS

# Create Kernel Configuration.
make defconfig -j $NUM_JOBS
echo "Generated Default Kernel Configuration."

# Change the Name of System to awlsomelinux.
sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"awlsomelinux\"/" .config

# Enable OverlayFS Support.
sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config

# Disable all Kernel Compression Options.
sed -i "s/.*\\(CONFIG_KERNEL_.*\\)=y/\\#\\ \\1 is not set/" .config 

# Enable 'xz' Kernel Compression Option.
sed -i "s/.*CONFIG_KERNEL_XZ.*/CONFIG_KERNEL_XZ=y/" .config

# Enable VESA Framebuffer for Graphical Support.
sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config

# Enable Boot Logo for Linux Kernel.
sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/CONFIG_LOGO_LINUX_CLUT224=y/" .config

# Disable Debugging in Kernel ==> Smaller Kernel.
sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config

# Compile the Kernel.
echo "Building Linux Kernel..."
make \
	CFLAGS="-0s -s -fno-stack-protector -U_FORTIFY_SOURCE" \
	bzImage -j $NUM_JOBS

# Install Kernel File.
cp arch/x86/boot/bzImage \
	$SRC_DIR/work/kernel/kernel_installed/kernel
	
# Install Kernel Headers for GNU C Library (glibc).
echo "Generating Kernel Headers..."
make \
	INSTALL_HDR_PATH=$SRC_DIR/work/kernel/kernel_installed \
	headers_install -j $NUM_JOBS
	
cd $SRC_DIR

echo "--- KERNEL END ---"
