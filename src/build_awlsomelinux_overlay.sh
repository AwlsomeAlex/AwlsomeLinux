#!/bin/sh

time sh overlay_clean.sh
time sh overlay_glibc_full.sh
time sh overlay_links.sh
time sh overlay_dropbear.sh
time sh overlay_ncurses.sh
time sh overlay_nano.sh
time sh overlay_mll_utils.sh
