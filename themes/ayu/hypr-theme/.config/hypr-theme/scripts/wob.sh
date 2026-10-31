#!/bin/sh
sock=$XDG_RUNTIME_DIR/wob.sock
pkill -f "tail -f $sock"
pkill -x wob
[ -p "$sock" ] || mkfifo "$sock"
tail -f "$sock" | wob
