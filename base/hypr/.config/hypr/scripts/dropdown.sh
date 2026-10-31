#!/bin/sh
if hyprctl clients | grep -q 'class: com.scotty.dropdown'; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("dropdown")' >/dev/null
else
    hyprctl dispatch 'hl.dsp.exec_cmd("ghostty --class=com.scotty.dropdown")' >/dev/null
fi
