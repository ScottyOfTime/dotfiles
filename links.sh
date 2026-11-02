# sourced by ./install and ./theme: which stow packages to link, from the
# apps installed, so a machine without Hyprland (GNOME, …) gets only the
# configs it can use

# Hyprland older than 0.56 can't read the Lua config and segfaults on it;
# without ours it writes and runs its own default
hypr_ok() {
    set -- $(Hyprland --version 2>/dev/null | sed -n '1s/^Hyprland \([0-9]*\)\.\([0-9]*\).*/\1 \2/p')
    [ -n "$1" ] && { [ "$1" -gt 0 ] || [ "$2" -ge 56 ]; }
}

# the command(s) a package configures, any one is enough; none: always link
needs() {
    case $1 in
        hypr|hypr-theme) echo Hyprland ;;
        quickshell) echo qs ;;
        ghostty-theme) echo ghostty ;;
        vim-theme) echo vim nvim ;;
        fastfetch|ghostty|nvim|vim|herdr|htop|btop|yazi|waybar|fuzzel|mako|wob) echo "$1" ;;
    esac
}

wanted() {
    set -- $(needs "$1")
    [ $# = 0 ] && return 0
    for c; do
        if [ "$c" = Hyprland ]; then hypr_ok && return 0
        elif command -v "$c" >/dev/null; then return 0; fi
    done
    return 1
}

# is any file of package $2 in dir $1 linked into ~ (directly or through a
# folded parent directory)?
linked() {
    (cd "$1/$2" && find . \( -type f -o -type l \) -print) | while read -r f; do
        [ "$(readlink -f "$HOME/$f")" = "$(readlink -f "$1/$2/$f")" ] && { echo y; break; }
    done | grep -q y
}

# pick <dir> <packages...>: sets $use to the wanted ones, unlinks unwanted
# ones that are linked, and says what it left out
pick() {
    dir=$1; shift; use= out=
    for p; do
        if wanted "$p"; then use="$use $p"; continue; fi
        why="$p (no $(needs "$p" | sed 's/ / or /g; s/^Hyprland$/Hyprland 0.56+/'))"
        if linked "$dir" "$p"; then
            stow -D -d "$dir" -t "$HOME" "$p" && echo "unlinked $why"
        else
            out="$out, $why"
        fi
    done
    [ -n "$out" ] && echo "not linked: ${out#, }"
    return 0
}
