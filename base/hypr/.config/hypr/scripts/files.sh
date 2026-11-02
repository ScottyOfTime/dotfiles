#!/bin/sh
# mod+E: close the open Files window(s), else open one. Ghostty would
# answer a close with an in-window "close terminal?" prompt since yazi is
# running, hence --confirm-close-surface=false on every Files launcher
open=$(hyprctl clients | awk '/^Window /{w=$2} /^\tclass: com\.scotty\.files$/{print w}')
if [ -n "$open" ]; then
    for w in $open; do
        hyprctl dispatch "hl.dsp.window.close({ window = \"address:0x$w\" })" >/dev/null
    done
else
    hyprctl dispatch 'hl.dsp.exec_cmd("ghostty --class=com.scotty.files --confirm-close-surface=false -e yazi")' >/dev/null
fi
