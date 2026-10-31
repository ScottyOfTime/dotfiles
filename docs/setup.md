# Setup

## Packages

`pkglist.txt` (pacman) and `aur-pkgslist.txt` (AUR) are the shared set:
hyprland, hypridle, darkman, ghostty, playerctl, brightnessctl, wtype,
flameshot, ttf-jetbrains-mono, stow, … plus bibata-cursor-theme-bin.
Each theme lists its own in `themes/<name>/packages.txt`.

`system.sh` copies `sddm.conf` to `/etc` and enables the system services in
`services.txt` (run from anywhere; uses sudo).

## Install

```
cd ~/dotfiles
stow -d base -t ~ bash fastfetch fontconfig ghostty herdr hypr nvim vim
./themes/zine/colorscheme/build.py
./theme zine
```

`./theme` stows the theme's packages and renders its colours (generated
files aren't committed). See [themes.md](themes.md).

Removing a package: `stow -D -d base -t ~ <name>` before deleting its folder,
or its `~/.config` symlink dangles.
