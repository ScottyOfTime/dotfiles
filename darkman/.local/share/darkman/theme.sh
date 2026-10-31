#!/bin/sh
mode=$1
[ "$mode" = dark ] || [ "$mode" = light ] || exit 1
cfg=$HOME/.config
palette=$cfg/palette/$mode.env

set -a; . "$palette"; set +a

gsettings set org.gnome.desktop.interface color-scheme prefer-$mode
gsettings set org.gnome.desktop.interface accent-color "$gtk_accent"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono 10'
gsettings set org.gnome.desktop.interface document-font-name 'JetBrains Mono 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
# only the palette's variables, so hyprlock's own $ATTEMPTS etc. survive
vars=$(sed -n 's/^\([a-z_]*\)=.*/$\1/p' "$palette" | tr '\n' ' ')
for f in waybar/colors.css fuzzel/colors.ini hypr/colors.lua hypr/hyprlock.conf mako/config wob/wob.ini; do
    envsubst "$vars" < "$cfg/$f.tmpl" > "$cfg/$f"
done

export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ | head -1)
hyprctl reload >/dev/null
hyprctl setcursor "$cursor" 24 >/dev/null
pkill waybar
hyprctl dispatch 'hl.dsp.exec_cmd("waybar")'
hyprctl dispatch 'hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")'
hyprctl dispatch 'hl.dsp.exec_cmd("~/.config/hypr/scripts/wob.sh")'
makoctl reload 2>/dev/null
