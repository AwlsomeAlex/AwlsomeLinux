#!/bin/sh

time sh overlay_clean.sh
time sh overlay_glibc_full.sh
time sh overlay_links.sh
time sh overlay_dropbear.sh
