#!/bin/sh
mode=$1
[ "$mode" = dark ] || [ "$mode" = light ] || exit 1
# vim/nvim read this at startup; :Theme reloads open ones (docs/apps.md)
state=${XDG_STATE_HOME:-$HOME/.local/state}
mkdir -p "$state" && echo "$mode" > "$state/theme-mode"
cfg=$HOME/.config
palette=$cfg/palette/$mode.env

set -a; . "$palette"; set +a
# the theme's gnome package (GNOME without Hyprland, docs/gnome.md)
ext=$HOME/.local/share/gnome-shell/extensions/dotfiles-look@scotty
root=$(readlink -f "$0"); root=${root%/themes/*}
look=; { command -v Hyprland >/dev/null || [ -e "$ext/metadata.json" ]; } && look=1

# the desktop look is for Hyprland, or GNOME through the gnome package;
# elsewhere only Ghostty takes the theme (through ghostty-theme)
if [ -n "$look" ]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-$mode
    # GNOME 46 has no accent-color key (47+); gnome-look colours its accent
    gsettings set org.gnome.desktop.interface accent-color "$gtk_accent" 2>/dev/null
    gsettings set org.gnome.desktop.interface enable-animations true
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
    gsettings set org.gnome.desktop.interface cursor-size 24
    gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono 10'
    gsettings set org.gnome.desktop.interface document-font-name 'JetBrains Mono 10'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
fi
# only the palette's variables (and $HOME), so hyprlock's own $ATTEMPTS etc. survive
vars="$(sed -n 's/^\([a-z_]*\)=.*/$\1/p' "$palette" | tr '\n' ' ') \$HOME"
for f in quickshell/Theme.qml hypr-theme/colors.lua hypr-theme/hyprlock.conf ghostty-theme/tabs.css ghostty-theme/config yazi/theme.toml btop/themes/palette.theme; do
    [ -e "$cfg/$f.tmpl" ] && envsubst "$vars" < "$cfg/$f.tmpl" > "$cfg/$f"
done

if pgrep -x Hyprland >/dev/null; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
    hyprctl reload >/dev/null
    hyprctl setcursor "$cursor" 24 >/dev/null
fi
[ -e "$ext/metadata.json" ] && "$root/gnome-look" "$mode"
pkill -SIGUSR2 -x ghostty
