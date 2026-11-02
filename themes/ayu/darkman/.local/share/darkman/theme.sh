#!/bin/sh
lib=$(readlink -f "$0"); . "${lib%/themes/*}/lib/theme.sh"

desktop true 'JetBrains Mono' 10 'JetBrains Mono' 11
render
reload
if pgrep -x Hyprland >/dev/null; then
    pkill -SIGUSR2 -x waybar
    hyprctl dispatch 'hl.dsp.exec_cmd("~/.config/hypr-theme/scripts/wallpaper.sh")' >/dev/null
    hyprctl dispatch 'hl.dsp.exec_cmd("~/.config/hypr-theme/scripts/wob.sh")' >/dev/null
    makoctl reload 2>/dev/null
fi
true
