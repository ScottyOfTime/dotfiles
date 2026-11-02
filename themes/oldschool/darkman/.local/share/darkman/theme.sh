#!/bin/sh
lib=$(readlink -f "$0"); . "${lib%/themes/*}/lib/theme.sh"

# the helpers run from the repo, not ~/.config/hypr-theme: Ghostty's font
# is wanted where hypr-theme isn't linked (no Hyprland) too
helpers=$themedir/hypr-theme/.config/hypr-theme
"$helpers/terminus-outline"
if [ -n "$look" ]; then
    # chicago95 only ships 32px: cursor-2x makes a copy with 64 and 96px too,
    # see docs/oldschool.md for the size
    "$helpers/cursor-2x" "$cursor"
    cursor_size=32
    # without chicago95 there's no copy; the default cursor at 32 is huge
    [ -d "$HOME/.local/share/icons/$cursor" ] || { cursor=Adwaita; cursor_size=24; }
fi

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
    # a hand-patched Terminess may have only one of the two families
    fc-list -q "$gtk_font" || gtk_font=$gtk_mono
    fc-list -q "$gtk_mono" || gtk_mono=$gtk_font
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

desktop false "$gtk_font" "$ui_points" "$gtk_mono"
render font ui_font ui_points term_font term_points term_flags
reload
