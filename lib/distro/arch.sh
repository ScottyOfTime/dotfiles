missing_packages() {
    need=$(names packages/arch.txt "themes/$1/packages.txt" | xargs pacman -T 2>/dev/null)
    aur=$(names packages/aur.txt | xargs pacman -T 2>/dev/null)
    [ -n "$need$aur" ] || return 0
    echo "missing packages (install them, then rerun if anything breaks):"
    [ -n "$need" ] && echo "  sudo pacman -S --needed" $need
    [ -n "$aur" ] && echo "  yay -S --needed" $aur
    return 0
}

service_hint() { echo "not enabled:$1"; }
