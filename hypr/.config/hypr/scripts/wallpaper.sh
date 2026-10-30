#!/bin/sh
# (re)start swaybg with a solid background from the current darkman mode's palette
mode=$(darkman get 2>/dev/null || echo dark)
. ~/.config/palette/"$mode".env
pkill -x swaybg
exec swaybg -c "#$bg"
