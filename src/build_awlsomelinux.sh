#!/bin/sh


echo "Checking Depenedencies (Apt)"
sudo apt install wget make gawk gcc bc syslinux genisoimage g++ build-essential libncurses-dev
sleep 5
time sh 00_clean.sh
time sh 01_kernel.sh
time sh 02_glibc.sh
time sh 03_busybox.sh
time sh 04_src.sh
time sh 05_rootfs.sh
time sh 06_syslinux.sh
time sh 07_image.sh
clear
echo "AwlsomeLinux has now been built!"

