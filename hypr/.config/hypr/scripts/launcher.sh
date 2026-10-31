#!/bin/sh
pkill -x fuzzel && exit
~/.config/hypr/scripts/scrap.py &
fuzzel
kill $!
