#!/bin/sh

####################################
#                                  #
# AwlsomeLinux Dependency Resolver #
#                                  #
####################################
#
# Created by AwlsomeAlex (GNU GPLv3)
#

############
# Settings #
############



#############
# Functions #
#############

# Check for Dialog
which dialog &> /dev/null
[ $? -ne 0 ] && echo "Dialog is not installed. Defaulting to APT Dependencies!" && ubuntu_dependency && exit 1

# Delete Temporary Files
deltempfiles() {
    rm -f /tmp/*.aldr
}

# APT - Ubuntu Dependency Resolver
ubuntu_dependency() {
    clear
    echo ""
    echo "============================"
    echo " Ubuntu Dependency Resolver "
    echo "============================"
    echo ""
    sudo apt-get install build-essential wget make gawk gcc bc syslinux genisoimage
    echo ""
    echo "====================================="
    echo " Ubuntu Dependency Resolver Complete!"
    echo "====================================="
    return 0
   }

#############
# Main Menu #
#############