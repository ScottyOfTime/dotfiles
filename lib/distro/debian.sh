# packages/debian.txt renames the Arch names that differ: "-" drops one,
# "!" marks it as not in apt (docs/setup.md lists where to get those)
missing_packages() {
    need= byhand=
    for p in $(names packages/arch.txt packages/aur.txt "themes/$1/packages.txt" |
               awk 'NR == FNR { if (!/^#/ && NF) map[$1] = $2; next }
                    { p = ($1 in map) ? map[$1] ":" $1 : $1; k = p; sub(/:.*/, "", k) }
                    k == "-" || k == "!" || !seen[k]++ { print p }' packages/debian.txt -); do
        case $p in
            -:*) continue ;;
            !:*) byhand="$byhand ${p#!:}"; continue ;;
        esac
        p=${p%%:*}
        dpkg-query -W -f='${db:Status-Abbrev}' "$p" 2>/dev/null | grep -q '^ii' && continue
        # not found counts as by hand too: an older release lacks more
        if apt-cache show "$p" >/dev/null 2>&1; then need="$need $p"; else byhand="$byhand $p"; fi
    done
    [ -n "$need$byhand" ] || return 0
    echo "missing packages (install them, then rerun if anything breaks):"
    [ -n "$need" ] && echo "  sudo apt install$need"
    [ -n "$byhand" ] && echo "  not in apt, see docs/setup.md:$byhand"
    return 0
}

# display-manager.service points at the DM the system was installed with
# (gdm3 on Ubuntu), so enabling sddm fails until it's switched
service_hint() {
    echo "not enabled:$1"
    case " $1 " in *" sddm.service "*) echo "  for sddm: sudo dpkg-reconfigure sddm" ;; esac
}
