#!/bin/sh

echo "Welcome to AwlsomeLinux Builder!"
sleep 5
echo "This Script will automatically generate AwlsomeLinux."
sleep 10
clear
echo "Checking Depenedencies (Apt)"
sudo apt install wget make gawk gcc bc syslinux genisoimage g++ build-essential
sleep 5
echo "Lets Begin!"
sleep 5
clear

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
echo "Thank you for using AwlsomeLinux Builder!"
sleep 5
clear
echo "AwlsomeLinux Created by AwlsomeAlex under GNU GPLv3"
echo "Original Project based on Ivandavidov's Minimal Script"
