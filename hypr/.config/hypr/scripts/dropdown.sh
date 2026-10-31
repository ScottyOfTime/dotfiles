#!/bin/sh
hyprctl clients | grep -q 'class: com.scotty.dropdown' ||
    hyprctl dispatch 'hl.dsp.exec_cmd("ghostty --class=com.scotty.dropdown")' >/dev/null
hyprctl dispatch 'hl.dsp.workspace.toggle_special("dropdown")' >/dev/null
