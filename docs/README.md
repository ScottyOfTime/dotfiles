# Dotfiles docs

Arch + Hyprland desktop themed as **zine**: a cut-and-paste print look with
paper scraps, strips of tape, hard offset shadows and slightly tilted
everything, in warm neutrals with a single orange accent. It follows
light/dark mode through darkman.

| Doc | Covers |
|---|---|
| [theme.md](theme.md) | The look: palette, colour roles, shapes, type, wallpaper |
| [theming-pipeline.md](theming-pipeline.md) | How colours flow from one file into every app, and how to theme a new one |
| [quickshell.md](quickshell.md) | Bar, launcher, popups, notifications, lock screen |
| [hyprland.md](hyprland.md) | Window manager: look, animations, keybinds, rules, idle/lock, scripts |
| [apps.md](apps.md) | Ghostty, bash prompt, nvim, fastfetch, fonts, cursor |
| [setup.md](setup.md) | Installing on a machine, stow packages, branches |

## Layout at a glance

```
colorscheme/        zine.toml (all colours) + build.py
palette/            generated palette files, one per mode
darkman/            theme.sh: applies a mode to every app
quickshell/         the shell: bar, launcher, osd, notifications, lock
hypr/               hyprland.lua, hyprlock/hypridle, helper scripts
ghostty/            terminal config, tab css, generated zine themes
bash/ nvim/ vim/    shell and editors
fastfetch/ fontconfig/ herdr/
pkglist.txt aur-pkgslist.txt services.txt system.sh sddm.conf
```

Every top-level folder except `colorscheme/` and `docs/` is a GNU stow
package mirroring `$HOME`.
