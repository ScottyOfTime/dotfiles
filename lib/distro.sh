# sourced by ./install and system/setup: the one place that tells Arch from
# Debian/Ubuntu. Each lib/distro/<name>.sh defines
#   missing_packages <theme>   print what to install (it installs nothing)
#   service_hint <units>       what to do about units that didn't enable
# packages/arch.txt and aur.txt are the shared set in Arch names, plus the
# theme's packages.txt (first word of each line)
names() { awk '!/^#/ && NF {print $1}' "$@"; }

if command -v pacman >/dev/null; then distro=arch
elif command -v dpkg-query >/dev/null; then distro=debian
else distro=
fi
if [ -n "$distro" ]; then
    . "lib/distro/$distro.sh"
else
    missing_packages() { :; }
    service_hint() { echo "not enabled:$1"; }
fi
