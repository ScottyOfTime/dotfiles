#!/bin/bash
sudo cp -r ./etc/sddm.conf /etc/sddm.conf
xargs systemctl --user enable < ./user-services.txt
