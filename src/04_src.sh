#!/bin/sh
# AwlsomeLinux Source Compile Script

####################
# Compile Settings #
####################

SRC_DIR=$(pwd)



##################
# Prepare Source #
##################

echo "--- SRC BEGIN ---"

cd work

echo "Preparing Source Files and Folders. Please wait..." 

# Remove old Sources
rm -rf src
mkdir src

# Copy all Sources file and folders to 'work/src'.
cp ../*.sh src
cp ../.config src
cp ../README src
cp ../*.txt src
cp -r ../rootfs src
cp -r ../overlay src

# Delete the '.gitignore' files used to make directories appear in Git.
find * -type f -name '.gitignore' -exec rm {} +

echo "Source Files/Folders have been prepared."

cd $SRC_DIR

echo "--- SRC END ---"
