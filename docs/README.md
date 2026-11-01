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

## Layout

```
base/                shared stow packages, always installed
  bash/ nvim/ vim/ fastfetch/ fontconfig/
  hypr/              hyprland.lua (binds, rules), hypridle, dropdown script
  ghostty/           config.ghostty (shared terminal settings)
themes/
  zine/              quickshell, palette, darkman, hypr-theme, ghostty-theme,
                     vim-theme, herdr, yazi, btop, colorscheme/ (zine.toml + build.py),
                     packages.txt
  oldschool/         same layout as zine (quickshell, palette, darkman,
                     hypr-theme, ghostty-theme, vim-theme, herdr, yazi, btop, colorscheme/)
  ayu/               waybar, fuzzel, mako, wob, palette, darkman,
                     hypr-theme, ghostty-theme, vim-theme, herdr, yazi, btop, packages.txt
install              first-run setup (links, backs up conflicts, picks a theme)
theme                switcher script
pkglist.txt aur-pkgslist.txt debian-pkgs.txt services.txt system.sh sddm.conf
```
