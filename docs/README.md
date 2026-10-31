# Dotfiles docs

Arch + Hyprland. Everything practical (shell, editors, keybinds, window
rules) lives once in `base/`; each look is a switchable theme in
`themes/<name>/`, swapped with `./theme <name>`.

| Doc | Covers |
|---|---|
| [setup.md](setup.md) | Installing on a machine, packages, stow |
| [themes.md](themes.md) | How themes plug in, switching, making a new one |
| [hyprland.md](hyprland.md) | Shared Hyprland config: keybinds, rules, idle/lock |
| [apps.md](apps.md) | Ghostty, bash prompt, nvim, fastfetch, fonts |
| [zine-theme.md](zine-theme.md) | **zine**: the look, palette, shapes, wallpaper |
| [zine-pipeline.md](zine-pipeline.md) | **zine**: how colours flow into every app |
| [zine-quickshell.md](zine-quickshell.md) | **zine**: bar, launcher, popups, lock screen, overview |
| [ayu.md](ayu.md) | **ayu**: the earlier waybar/fuzzel rice |

## Layout

```
base/                shared stow packages, always installed
  bash/ nvim/ vim/ herdr/ fastfetch/ fontconfig/
  hypr/              hyprland.lua (binds, rules), hypridle, dropdown script
  ghostty/           config.ghostty (shared terminal settings)
themes/
  zine/              quickshell, palette, darkman, hypr-theme, ghostty-theme,
                     colorscheme/ (zine.toml + build.py), packages.txt
  ayu/               waybar, fuzzel, mako, wob, palette, darkman,
                     hypr-theme, ghostty-theme, packages.txt
theme                switcher script
pkglist.txt aur-pkgslist.txt services.txt system.sh sddm.conf
```

Zine is the current theme. The old experiment branches (`rice`, `zine`,
`zine-waybar`, `zine-quickshell`, `zine-overview`) predate this layout and
are kept only as history.
