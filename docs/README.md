# Dotfiles docs

Arch + Hyprland (Debian/Ubuntu work too, see [setup.md](setup.md)).
Everything practical (shell, editors, keybinds, window rules) lives once in
`base/`; each look is a switchable theme in `themes/<name>/`, swapped with
`./theme <name>`.

| Doc | Covers |
|---|---|
| [setup.md](setup.md) | Installing on a machine, packages, stow, Debian/Ubuntu |
| [themes.md](themes.md) | How themes plug in, switching, making a new one |
| [hyprland.md](hyprland.md) | Shared Hyprland config: keybinds, rules, idle/lock |
| [apps.md](apps.md) | Ghostty, bash prompt, nvim, fastfetch, fonts |
| [zine-theme.md](zine-theme.md) | **zine**: the look, palette, shapes, wallpaper |
| [zine-pipeline.md](zine-pipeline.md) | **zine**: how colours flow into every app |
| [zine-quickshell.md](zine-quickshell.md) | **zine**: bar, launcher, popups, lock screen, overview |
| [oldschool.md](oldschool.md) | **oldschool**: amber terminal, flat borderless text shell (after sxwm) |
| [ayu.md](ayu.md) | **ayu**: the earlier waybar/fuzzel rice |
| [gnome.md](gnome.md) | Each theme on GNOME (Ubuntu): shell stylesheet, GTK colours |

## Layout

```
base/                shared stow packages, always installed
  bash/ nvim/ vim/ fastfetch/ fontconfig/
  hypr/              hyprland.lua (binds, rules), hypridle, dropdown script
  ghostty/           config.ghostty (shared terminal settings)
themes/
  zine/              quickshell, palette, darkman, hypr-theme, ghostty-theme,
                     vim-theme, herdr, yazi, btop, colorscheme/ (zine.toml + build.py),
                     packages.txt, README.md + preview/ (every theme)
  oldschool/         same layout as zine (quickshell, palette, darkman,
                     hypr-theme, ghostty-theme, vim-theme, herdr, yazi, btop, colorscheme/)
  ayu/               waybar, fuzzel, mako, wob, palette, darkman,
                     hypr-theme, ghostty-theme, vim-theme, herdr, yazi, btop, packages.txt
README.md            the themes at a glance; themes/<name>/README.md for each
install              setup: menus for the theme and what to link, backs up conflicts
theme                switcher script
uninstall            undo install: links, .bak files, desktop settings
lib/
  links.sh           which packages get linked, from the apps installed
  theme.sh           what every theme's darkman theme.sh shares (render, reload)
  gnome-look         a theme's GNOME half (docs/gnome.md)
  desktop-settings   save/restore the desktop settings the themes change
  distro.sh          picks distro/arch.sh or distro/debian.sh: the only
                     Arch/Debian branch (package checks, service hints)
  previews           draws each theme's palette into its README (themes.md)
packages/            arch.txt, aur.txt, debian.txt (Arch -> apt names)
system/              setup (sudo: sddm.conf, services.txt)
```
