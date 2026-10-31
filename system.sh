#!/bin/bash
cd "$(dirname "$0")" || exit 1
sudo cp sddm.conf /etc/sddm.conf
xargs -a services.txt sudo systemctl enable
