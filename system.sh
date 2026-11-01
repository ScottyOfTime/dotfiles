#!/bin/bash
cd "$(dirname "$0")" || exit 1
sudo cp sddm.conf /etc/sddm.conf
# one at a time: systemctl enables none of a list if one unit is missing
# (e.g. systemd-userdbd isn't installed by default on Debian)
while read -r unit; do
    [ -n "$unit" ] && { sudo systemctl enable "$unit" || failed="$failed $unit"; }
done < services.txt
# Debian/Ubuntu point display-manager.service at the DM they installed with
[ -n "$failed" ] && echo "not enabled:$failed (for sddm on Debian/Ubuntu: sudo dpkg-reconfigure sddm)"
true
