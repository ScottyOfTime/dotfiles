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
# the font strip (FontMenu.qml) sets this through hypr-theme/font
font=$(cat "$state/oldschool-font" 2>/dev/null)
case $font in
""|terminus) font=Terminus ;;
jetbrains) font='JetBrains Mono' ;;
esac
case $font in
Terminus)
    # 11.25pt is 15px, 20 physical at 1.33x; 12.375pt is 22 physical in
    # ghostty: native terminus sizes (docs/oldschool.md)
    ui_font='Terminess Nerd Font Mono' ui_points=11.25 gtk_font='Terminess Nerd Font' gtk_mono='Terminess Nerd Font Mono'
    # terminus without its embedded bitmaps (hypr-theme/terminus-outline),
    # which ghostty would draw pixel-sharp instead of smoothing like the
    # shell; hinting squeezes it at 22px: dots become thin slivers
    term_font='Terminess Outline' term_points=12.375 term_flags=no-hinting,no-monochrome ;;
*)
    # wide, with a tall x-height: looks bigger than others at the same size
    case $font in 'JetBrains Mono'*) ui_points=10 term_points=11.5 ;; *) ui_points=10.5 term_points=12 ;; esac
    ui_font=$font gtk_font=$font gtk_mono=$font term_font=$font term_flags=hinting ;;
esac
export font ui_font ui_points term_font term_points term_flags
gsettings set org.gnome.desktop.interface font-name "$gtk_font $ui_points"
gsettings set org.gnome.desktop.interface document-font-name "$gtk_font $ui_points"
gsettings set org.gnome.desktop.interface monospace-font-name "$gtk_mono $ui_points"
# only the palette's variables (and $HOME), so hyprlock's own $ATTEMPTS etc. survive
vars="$(sed -n 's/^\([a-z_]*\)=.*/$\1/p' "$palette" | tr '\n' ' ') \$HOME \$font \$ui_font \$ui_points \$term_font \$term_points \$term_flags"
for f in quickshell/Theme.qml hypr-theme/colors.lua hypr-theme/hyprlock.conf ghostty-theme/tabs.css ghostty-theme/config yazi/theme.toml btop/themes/palette.theme; do
    envsubst "$vars" < "$cfg/$f.tmpl" > "$cfg/$f"
done

export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
hyprctl reload >/dev/null
hyprctl setcursor "$cursor" "$size" >/dev/null
pkill -SIGUSR2 -x ghostty
