#!/bin/sh
mode=$(darkman get 2>/dev/null || echo dark)
. ~/.config/palette/"$mode".env
pkill -x swaybg
exec swaybg -c "#$bg"
