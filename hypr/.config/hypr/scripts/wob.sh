#!/bin/sh
# (re)start wob reading from its fifo, so it picks up a new wob.ini
sock=$XDG_RUNTIME_DIR/wob.sock
pkill -f "tail -f $sock"
pkill -x wob
[ -p "$sock" ] || mkfifo "$sock"
tail -f "$sock" | wob
