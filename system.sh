#!/bin/bash
sudo cp -r ./sddm.conf /etc/sddm.conf
xargs systemctl --user enable < ./services.txt
