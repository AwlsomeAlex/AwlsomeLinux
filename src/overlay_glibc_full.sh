#!/bin/sh
# AwlsomeLinux Overlay GLIBC Full Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)



##############################
# GLIBC Full Library Install #
##############################

echo "--- OVERLAY_GLIBC BEGIN ---"

# Checks if GLIBC has been Compiled.

if [ ! -d $SRC_DIR/work/glibc/glibc_prepared ] ; then
	echo "GLIBC Full Build Impossible - GLIBC is missing. Please build GLIBC first!"
	exit 1
fi

# Cleans/Creates Overlay GLIBC Folder.

echo "Preparing Overlay GLIBC Directory. Please wait..."
rm -rf work/overlay/glibc
mkdir -p work/overlay/glibc/lib

cd work/glibc/glibc_prepared/lib

# Copy all Libraries to GLIBC Overlay Directory.

find . -type l -exec cp {} $SRC_DIR/work/overlay/glibc/lib \;
echo "All Libraries have been copied."

cd $SRC_DIR/work/overlay/glibc/lib

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

cp -r $SRC_DIR/work/overlay/glibc/lib $SRC_DIR/work/src/overlay
echo "All Libraries have been installed to the OverlayFS."

cd $SRC_DIR

echo "--- OVERLAY_GLIBC END ---"


