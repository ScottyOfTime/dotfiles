#!/bin/sh
if [ "$1" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    cp ~/.config/waybar/style.dark.css ~/.config/waybar/style.css
    cp ~/.config/fuzzel/fuzzel.dark.ini ~/.config/fuzzel/fuzzel.ini
    sed -i "s/let ayucolor='light'/let ayucolor='dark'/" ~/.vimrc
    pkill waybar
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ | head -1)
    hyprctl dispatch exec waybar
elif [ "$1" = "light" ]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    cp ~/.config/waybar/style.light.css ~/.config/waybar/style.css
    cp ~/.config/fuzzel/fuzzel.light.ini ~/.config/fuzzel/fuzzel.ini
    sed -i "s/let ayucolor='dark'/let ayucolor='light'/" ~/.vimrc
    pkill waybar
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ | head -1)
    hyprctl dispatch exec waybar
fi
