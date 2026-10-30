#!/bin/sh
# (re)start swaybg with the wallpaper for the current darkman mode
mode=$(darkman get 2>/dev/null || echo dark)
pkill -x swaybg
exec swaybg -m fill -i ~/wallpapers/"$mode".png
