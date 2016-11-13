#!/bin/sh

## AwlsomeLinux Overlay Creation Script
## Created by AwlsomeAlex (GNU GPLv3)

##############################
# -------------------------- #
# AwlsomeLinux Configuration #
# -------------------------- #
##############################

SRC_DIR=$(pwd)

##########################
# AwlsomeLinux Variables #
##########################


#############################
# ------------------------- #
# AwlsomeLinux Image Script #
# ------------------------- #
##############################


###########################
# GLIBC Full Installation #
###########################

install_glibc() {
	echo "== GLIBC Full Installation (Start) =="
	
	# Check if Glibc is Built
	if [ ! -d $SRC_DIR/core/install/glibc ] ; then
		echo "GLIBC Full Installation Failed - GLIBC was never built. Please build GLIBC!"
		exit 1
	fi
	
	# Prepare GLIBC Full Installation Work Area
	rm -rf overlay/work/glibc
	rm -rf overlay/install/glibc
	mkdir overlay/work/glibc
	mkdir overlay/work/glibc/lib
	mkdir overlay/install/glibc
	mkdir overlay/install/glibc/lib
	
	# Change Directory to 'core/install/glibc_prepared/lib'
	cd core/install/glibc_prepared/lib
	
	# Copy all GLIBC Libraries to OverlayFS
	find . -type l -exec cp {} $SRC_DIR/overlay/work/glibc/lib \;
	echo "All GLIBC Libraries have been copied."
	
	cd $SRC_DIR/overlay/work/glibc/lib

	for FILE_DEL in $(ls *.so)
		do
			FILE_KEEP=$(ls $FILE_DEL.*)

		if [ ! "$FILE_KEEP" = "" ] ; then
			# We remove the shorter file and replace it with symbolic link.
			rm $FILE_DEL
			ln -s $FILE_KEEP $FILE_DEL
		fi
	done
	echo "Duplicate Libraries have been replaced with soft links."
	
	strip -g *
	echo "All Libraries have been reduced in File Size."
	
	cp -r $SRC_DIR/overlay/work/glibc/lib $SRC_DIR/overlay/install/glibc
	echo "GLIBC Full Installation has been installed to the OverlayFS."
	
	cd $SRC_DIR
	
	echo "== GLIBC Full Installation (Stop) =="
}

######################
# OverlayFS Creation #
######################
overlayfs_create() {
	
	echo "== OverlayFS Creation (Start) =="

	# Create OverlayFS Directories
	mkdir $SRC_DIR/overlay/overlayfs/etc
	mkdir $SRC_DIR/overlay/overlayfs/lib

	# Copy Packages to OverlayFS
	cp -r $SRC_DIR/overlay/install/glibc/* $SRC_DIR/overlay/overlayfs
	
	echo "The OverlayFS Directory has been created."
	
	cd $SRC_DIR
	
	echo "== OverlayFS Creation (Stop) =="
	
}

######################
# Root User Creation #
######################
generate_user() {
	
	echo "== Generate Root User (Start) =="
	
	# Create User Files
	touch $SRC_DIR/overlay/overlayfs/etc/passwd
	touch $SRC_DIR/overlay/overlayfs/etc/group
	
	# Add group 0 for root.
	echo "root:x:0:" \
			> $SRC_DIR/overlay/overlayfs/etc/group
			
	# Add user root with password 'toor'.
	echo "root:AprZpdBUhZXss:0:0:AwlsomeLinux Root,,,:/root:/bin/sh" \
		> $SRC_DIR/overlay/overlayfs/etc/passwd
	
	# Generate Root Directory '/root' for Root User
	mkdir -p $SRC_DIR/overlay/overlayfs/root
	
	# Create new Inittab for Root User. (Allows Login only if OverlayFS is mounted.)
	touch $SRC_DIR/overlay/overlayfs/etc/inittab
	
	echo "::sysinit:/etc/03_boot.sh" > $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::restart:/sbin/init" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::shutdown:echo -e "\n\e[1;94m(****) \e[0mSyncing OverlayFS..."" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::shutdown:sync" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::shutdown:echo -e "\e[1;94m(****) \e[0mUnmounting All Filesystems..."" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::shutdown:umount -a -r" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::shutdown:echo -e "\e[1;94m(****) \e[0mShutting Down AwlsomeLinux..."" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::shutdown:sleep 1" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::ctrlaltdel:/sbin/reboot" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::once:cat /etc/welcome.txt" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "::respawn:/bin/cttyhack /bin/login" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "tty2::once:cat /etc/welcome.txt" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "tty2::respawn:/bin/login" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "tty3::once:cat /etc/welcome.txt" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "tty3::respawn:/bin/login" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "tty4::once:cat /etc/welcome.txt" >> $SRC_DIR/overlay/overlayfs/etc/inittab
    echo "tty4::respawn:/bin/sh" >> $SRC_DIR/overlay/overlayfs/etc/inittab
	
	echo "== Generate Root User (Stop) =="
	
}


install_glibc

overlayfs_create

generate_user
