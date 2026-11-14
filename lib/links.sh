# sourced by ./install, ./theme and ./uninstall: which stow packages to
# link, from the apps installed (so a machine without Hyprland, e.g. GNOME,
# gets only the configs it can use) and what ./install's menu left out
state=${XDG_STATE_HOME:-$HOME/.local/state}
skipfile=$state/dotfiles-skip

# every folder in a theme is a stow package except colorscheme/, system/,
# preview/ (the README's pictures) and pvetui/ (merged into pvetui's own
# config by lib/pvetui, never linked)
packages() { find "themes/$1" -mindepth 1 -maxdepth 1 -type d ! -name colorscheme ! -name system ! -name preview ! -name pvetui -printf '%f\n'; }

# unrender <theme> [-v]: delete what theme.sh rendered from the theme's
# .tmpl files into real folders (~/.config/yazi): those outlive the links,
# and stop the next theme's from linking. Ones inside a folded link went
# with it
unrender() {
    for pkg in $(packages "$1"); do
        (cd "themes/$1/$pkg" && find . -name '*.tmpl') | while read -r f; do
            out=$HOME/${f#./}; out=${out%.tmpl}
            [ -f "$out" ] || continue
            case $(readlink -f "$out") in "$PWD"/*) continue ;; esac
            rm "$out" && [ -n "$2" ] && echo "removed ~/${out#$HOME/} (rendered by the theme)"
        done
    done
    return 0
}

# Hyprland older than 0.56 can't read the Lua config and segfaults on it;
# without ours it writes and runs its own default
hypr_ok() {
    set -- $(Hyprland --version 2>/dev/null | sed -n '1s/^Hyprland \([0-9]*\)\.\([0-9]*\).*/\1 \2/p')
    [ -n "$1" ] && { [ "$1" -gt 0 ] || [ "$2" -ge 56 ]; }
}

# light or dark right now: darkman's when it runs; else GNOME's Dark Style
# (the mode switch there, docs/gnome.md); else the last one rendered
current_mode() {
    darkman get 2>/dev/null && return
    if command -v gnome-shell >/dev/null; then
        case $(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null) in
            *prefer-dark*) echo dark; return ;;
            ?*) echo light; return ;;
        esac
    fi
    m=$(cat "$state/theme-mode" 2>/dev/null)
    case $m in light|dark) echo "$m" ;; *) echo dark ;; esac
}

# the command(s) a package configures, any one is enough; none: always link
needs() {
    case $1 in
        # fontconfig remaps sans/mono for every app: only for the Hyprland look
        hypr|hypr-theme|fontconfig) echo Hyprland ;;
        quickshell) echo qs ;;
        tmux-theme) echo tmux ;;
        gnome) echo gnome-shell ;;
        ghostty-theme) echo ghostty ;;
        vim-theme) echo vim nvim ;;
        fastfetch|ghostty|nvim|vim|tmux|herdr|htop|btop|yazi|waybar|fuzzel|mako|wob) echo "$1" ;;
    esac
}

# one line for ./install's menu, by base/<pkg> or theme/<pkg>
about() {
    case $1 in
        */bash) echo "prompt, aliases, PATH" ;;
        */fastfetch) echo "system info layout" ;;
        */fontconfig) echo "JetBrains Mono as every app's sans/mono" ;;
        */ghostty) echo "terminal settings" ;;
        */hypr) echo "Hyprland: binds, rules, idle" ;;
        */nvim) echo "Neovim config and plugins" ;;
        */tmux) echo "tmux: mouse, vi keys, splits in the same folder" ;;
        */vim) echo "Vim config" ;;
        base/yazi) echo "file manager: keys, file picker, folder handler" ;;
        theme/yazi) echo "yazi colours" ;;
        */btop) echo "btop colours" ;;
        */ghostty-theme) echo "terminal colours and font" ;;
        */herdr) echo "herdr colours" ;;
        */htop) echo "htop layout and colours" ;;
        */hypr-theme) echo "Hyprland look, lock, theme binds" ;;
        */quickshell) echo "bar, launcher, notifications, lock" ;;
        */tmux-theme) echo "tmux colours" ;;
        */vim-theme) echo "vim/nvim colours" ;;
        */gnome) echo "GNOME shell + GTK app colours, fonts, wallpaper" ;;
        */waybar|*/fuzzel|*/mako|*/wob) echo "${1#*/} config and colours" ;;
        *) echo "${1#*/}" ;;
    esac
}

theme_about() {
    case $1 in
        graffiti) echo "2000s punk: a bombed brick wall, gaffer tape, paint marker" ;;
        zine) echo "neo-brutalist zine: paper, ink, hard shadows" ;;
        oldschool) echo "amber terminal, flat text shell" ;;
        ayu) echo "ayu colours, waybar and fuzzel" ;;
        *) echo "$1" ;;
    esac
}

# the theme can't work without these, so the menu doesn't offer them
required() { case $1 in darkman|palette) return 0 ;; esac; return 1; }

# base/<pkg> or theme/<pkg> (any theme): what dotfiles-skip lists
key() { case $1 in base) echo "base/$2" ;; *) echo "theme/$2" ;; esac; }
skipped() { grep -qx "$1" "$skipfile" 2>/dev/null; }

# the app is there (Hyprland only counts at 0.56+)
has_app() {
    set -- $(needs "$1")
    [ $# = 0 ] && return 0
    for c; do
        if [ "$c" = Hyprland ]; then hypr_ok && return 0
        elif command -v "$c" >/dev/null; then return 0; fi
    done
    return 1
}

wanted() { has_app "$2" && ! skipped "$(key "$1" "$2")"; }

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
        if wanted "$dir" "$p"; then use="$use $p"; continue; fi
        if has_app "$p"; then why="$p (skipped in ./install)"
        else why="$p (no $(needs "$p" | sed 's/ / or /g; s/^Hyprland$/Hyprland 0.56+/'))"; fi
        if linked "$dir" "$p"; then
            stow -D -d "$dir" -t "$HOME" "$p" && echo "unlinked $why"
        else
            out="$out, $why"
        fi
    done
    [ -n "$out" ] && echo "not linked: ${out#, }"
    return 0
}

# choose <title> <tag> <description> <ON|OFF> ...: a checklist (whiptail,
# else a numbered menu); prints the chosen tags, fails if cancelled
choose() {
    title=$1; shift
    if command -v whiptail >/dev/null; then
        h=$(( $# / 3 )); [ $h -gt 16 ] && h=16
        # whiptail draws on stdout and answers on stderr: swap them
        whiptail --title dotfiles --separate-output --checklist \
            "$title (space toggles, enter accepts)" $(( h + 8 )) 76 $h "$@" 3>&1 1>&2 2>&3
        return
    fi
    n=0
    while [ $# -gt 0 ]; do
        n=$((n + 1)); eval "tag$n=\$1 desc$n=\$2 on$n=\$3"; shift 3
    done
    while :; do
        echo "$title" >&2
        i=0; while [ $i -lt $n ]; do
            i=$((i + 1)); eval "t=\$tag$i d=\$desc$i o=\$on$i"
            mark=' '; [ "$o" = ON ] && mark=x
            printf '  %2d [%s] %-22s %s\n' $i "$mark" "$t" "$d" >&2
        done
        printf 'numbers to toggle, a all, n none, enter to accept, q to quit: ' >&2
        read -r ans || return 1
        case $ans in
            "") break ;;
            q) return 1 ;;
            a|n) v=ON; [ "$ans" = n ] && v=OFF
                 i=0; while [ $i -lt $n ]; do i=$((i + 1)); eval "on$i=$v"; done ;;
            *) for i in $ans; do
                   case $i in *[!0-9]*) continue ;; esac
                   [ "$i" -ge 1 ] && [ "$i" -le $n ] || continue
                   eval "o=\$on$i"; if [ "$o" = ON ]; then eval "on$i=OFF"; else eval "on$i=ON"; fi
               done ;;
        esac
    done
    i=0; while [ $i -lt $n ]; do
        i=$((i + 1)); eval "[ \"\$on$i\" = ON ] && echo \"\$tag$i\""
    done
    return 0
}

# choose_one <title> <tag> <description> ...: a radio list, else a numbered
# prompt; the first tag is the default
choose_one() {
    title=$1; shift
    if command -v whiptail >/dev/null; then
        # tag description pairs become whiptail's tag description state triples
        c=$(( $# / 2 )) on=ON; h=$c; [ $h -gt 10 ] && h=10
        while [ $c -gt 0 ]; do t=$1 d=$2; shift 2; set -- "$@" "$t" "$d" $on; on=OFF; c=$((c - 1)); done
        whiptail --title dotfiles --radiolist "$title" $(( h + 8 )) 76 $h "$@" 3>&1 1>&2 2>&3
        return
    fi
    n=0
    while [ $# -gt 0 ]; do n=$((n + 1)); eval "tag$n=\$1"; printf '  %d) %-12s %s\n' $n "$1" "$2" >&2; shift 2; done
    printf '%s [1]: ' "$title" >&2
    read -r ans || return 1
    [ -z "$ans" ] && ans=1
    case $ans in *[!0-9]*) return 1 ;; esac
    [ "$ans" -ge 1 ] && [ "$ans" -le $n ] || return 1
    eval "echo \"\$tag$ans\""
}
