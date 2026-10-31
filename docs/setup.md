# Setup

## Packages

`pkglist.txt` (pacman) and `aur-pkgslist.txt` (AUR). Key pieces: hyprland,
quickshell, darkman, ghostty, hypridle, hyprlock (fallback locker), swaybg,
imagemagick (wallpaper), playerctl, brightnessctl, wtype, flameshot,
ttf-jetbrains-mono, bibata-cursor-theme-bin.

`system.sh` copies `sddm.conf` to `/etc` and enables the system services in
`services.txt` (run from anywhere; uses sudo).

## Stow

Every top-level folder except `colorscheme/` and `docs/` is a stow package:

```
cd ~/dotfiles
stow bash darkman fastfetch fontconfig ghostty herdr hypr nvim palette quickshell vim
```

Then render the theme once (generated files aren't committed):

```
./colorscheme/build.py
~/.local/share/darkman/theme.sh $(darkman get)
```

Removing a package: `stow -D <name>` before deleting its folder, or its
`~/.config` symlink dangles.

## Branches

Experiments stack on branches so earlier states are kept:

| Branch | State |
|---|---|
| `main` | original setup |
| `rice` | Ayu palette pipeline, waybar/fuzzel/mako/wob, hyprlock |
| `zine` | zine theme with waybar pills |
| `zine-waybar` | zine waybar with tilted SVG strips |
| `zine-quickshell` | current: everything in Quickshell |

Switching branches doesn't re-render generated files: after `git switch`,
run `stow` for any packages that appeared/disappeared and then
`~/.local/share/darkman/theme.sh $(darkman get)`.
