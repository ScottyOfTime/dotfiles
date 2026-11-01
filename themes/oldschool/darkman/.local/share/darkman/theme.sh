#!/bin/sh
mode=$1
[ "$mode" = dark ] || [ "$mode" = light ] || exit 1
# open vim/nvim watch this file and reload their colours when it changes
state=${XDG_STATE_HOME:-$HOME/.local/state}
mkdir -p "$state" && echo "$mode" > "$state/theme-mode"
cfg=$HOME/.config
palette=$cfg/palette/$mode.env

set -a; . "$palette"; set +a

gsettings set org.gnome.desktop.interface color-scheme prefer-$mode
gsettings set org.gnome.desktop.interface accent-color "$gtk_accent"
# chicago95 only ships 32px: cursor-2x makes a copy with 64 and 96px too,
# see docs/oldschool.md for the size
~/.config/hypr-theme/cursor-2x "$cursor"
# without chicago95 there's no copy; the default cursor at 32 is huge
size=32
[ -d "$HOME/.local/share/icons/$cursor" ] || { cursor=Adwaita; size=24; }
~/.config/hypr-theme/terminus-outline
gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
gsettings set org.gnome.desktop.interface cursor-size "$size"
# 11.25pt is 15px, 20 physical at 1.33x: a native terminus size
gsettings set org.gnome.desktop.interface font-name 'Terminess Nerd Font 11.25'
gsettings set org.gnome.desktop.interface document-font-name 'Terminess Nerd Font 11.25'
gsettings set org.gnome.desktop.interface monospace-font-name 'Terminess Nerd Font Mono 11.25'
# only the palette's variables (and $HOME), so hyprlock's own $ATTEMPTS etc. survive
vars="$(sed -n 's/^\([a-z_]*\)=.*/$\1/p' "$palette" | tr '\n' ' ') \$HOME"
for f in quickshell/Theme.qml hypr-theme/colors.lua hypr-theme/hyprlock.conf ghostty-theme/tabs.css ghostty-theme/config; do
    envsubst "$vars" < "$cfg/$f.tmpl" > "$cfg/$f"
done

export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
hyprctl reload >/dev/null
hyprctl setcursor "$cursor" "$size" >/dev/null
pkill -SIGUSR2 -x ghostty
