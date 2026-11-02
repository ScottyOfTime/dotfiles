#!/bin/sh
mode=$1
[ "$mode" = dark ] || [ "$mode" = light ] || exit 1
# open vim/nvim watch this file and reload their colours when it changes
state=${XDG_STATE_HOME:-$HOME/.local/state}
mkdir -p "$state" && echo "$mode" > "$state/theme-mode"
cfg=$HOME/.config
palette=$cfg/palette/$mode.env

set -a; . "$palette"; set +a

# without Hyprland this is another desktop (GNOME, …) whose look is its own
if command -v Hyprland >/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-$mode
    gsettings set org.gnome.desktop.interface accent-color "$gtk_accent"
    gsettings set org.gnome.desktop.interface enable-animations true
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
    gsettings set org.gnome.desktop.interface cursor-size 24
    gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono 10'
    gsettings set org.gnome.desktop.interface document-font-name 'JetBrains Mono 10'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
fi
# only the palette's variables, so hyprlock's own $ATTEMPTS etc. survive
vars=$(sed -n 's/^\([a-z_]*\)=.*/$\1/p' "$palette" | tr '\n' ' ')
for f in waybar/colors.css fuzzel/colors.ini hypr-theme/colors.lua hypr-theme/hyprlock.conf mako/config wob/wob.ini yazi/theme.toml btop/themes/palette.theme; do
    [ -e "$cfg/$f.tmpl" ] && envsubst "$vars" < "$cfg/$f.tmpl" > "$cfg/$f"
done

if pgrep -x Hyprland >/dev/null; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
    hyprctl reload >/dev/null
    hyprctl setcursor "$cursor" 24 >/dev/null
    pkill -SIGUSR2 -x waybar
    hyprctl dispatch 'hl.dsp.exec_cmd("~/.config/hypr-theme/scripts/wallpaper.sh")'
    hyprctl dispatch 'hl.dsp.exec_cmd("~/.config/hypr-theme/scripts/wob.sh")'
    makoctl reload 2>/dev/null
fi
pkill -SIGUSR2 -x ghostty
