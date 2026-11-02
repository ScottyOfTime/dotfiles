#!/bin/sh
# a theme may wrap scratchpad toggles (hypr-theme/special <name>)
hook=~/.config/hypr-theme/special
[ -x "$hook" ] && "$hook" "$1" && exit
hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$1\")" >/dev/null
