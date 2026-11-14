# sourced by each theme's darkman theme.sh with the mode as $1: loads the
# palette, and has the steps every theme takes
mode=$1
[ "$mode" = dark ] || [ "$mode" = light ] || exit 1
here=$(readlink -f "$0")
root=${here%/themes/*}
themedir=${here%%/darkman/*}
# vim/nvim read this at startup; :Theme reloads open ones (docs/apps.md)
state=${XDG_STATE_HOME:-$HOME/.local/state}
mkdir -p "$state" && echo "$mode" > "$state/theme-mode"
palette=$HOME/.config/palette/$mode.env
set -a; . "$palette"; set +a
cursor_size=24
# the theme's gnome package (GNOME without Hyprland, docs/gnome.md)
ext=$HOME/.local/share/gnome-shell/extensions/dotfiles-look@scotty
# the desktop look is for Hyprland, or GNOME through the gnome package;
# elsewhere only Ghostty takes the theme (through ghostty-theme)
look=; { command -v Hyprland >/dev/null || [ -e "$ext/metadata.json" ]; } && look=1

# desktop <animations> <font> <points> [<mono font> [<mono points>]]:
# GTK/GNOME's dark style, accent, animations, cursor and fonts
desktop() {
    [ -n "$look" ] || return 0
    i=org.gnome.desktop.interface
    gsettings set $i color-scheme prefer-$mode
    # GNOME 46 has no accent-color key (47+); gnome-look colours its accent
    gsettings set $i accent-color "$gtk_accent" 2>/dev/null
    gsettings set $i enable-animations "$1"
    gsettings set $i cursor-theme "$cursor"
    gsettings set $i cursor-size "$cursor_size"
    gsettings set $i font-name "$2 $3"
    gsettings set $i document-font-name "$2 $3"
    gsettings set $i monospace-font-name "${4:-$2} ${5:-$3}"
}

# render [<var>...]: every .tmpl of the theme's linked packages, filled in
# from the palette, $HOME and the named (exported) variables only, so
# hyprlock's own $ATTEMPTS etc. survive
render() {
    vars="$(sed -n 's/^\([a-z_]*\)=.*/$\1/p' "$palette" | tr '\n' ' ') \$HOME"
    for v; do vars="$vars \$$v"; done
    (cd "$themedir" && find . -mindepth 3 -name '*.tmpl' ! -path './system/*' ! -path './colorscheme/*') |
    while read -r f; do
        f=${f#./*/}
        [ -e "$HOME/$f" ] && envsubst "$vars" < "$HOME/$f" > "$HOME/${f%.tmpl}"
    done
    t=$themedir/pvetui/theme.yml.tmpl
    [ -f "$t" ] && envsubst "$vars" < "$t" | "$root/lib/pvetui"
    return 0
}

# reload: Hyprland (and its cursor) while it runs, GNOME's shell stylesheet
# when the gnome package is linked, Ghostty, herdr and tmux
reload() {
    if pgrep -x Hyprland >/dev/null; then
        export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/$(id -u)/hypr/ | head -1)
        hyprctl reload >/dev/null
        hyprctl setcursor "$cursor" "$cursor_size" >/dev/null
    fi
    [ -e "$ext/metadata.json" ] && "$root/lib/gnome-look" "$mode"
    pkill -SIGUSR2 -x ghostty
    # herdr's server keeps the colours it started with
    command -v herdr >/dev/null && herdr server reload-config >/dev/null 2>&1
    # tmux reads its config only when its server starts
    tmux has-session 2>/dev/null && tmux source-file -q ~/.config/tmux-theme/theme.conf
    # yazi reads its theme only at startup, and mod+E's keeps running:
    # filespad.sh restarts it in place on SIGUSR1
    for y in $(pgrep -x yazi); do
        grep -qz '^DOTFILES_FILES_PAD=1$' "/proc/$y/environ" 2>/dev/null && kill -USR1 "$y"
    done
    return 0
}
