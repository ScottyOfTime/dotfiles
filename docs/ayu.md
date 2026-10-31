# ayu

The earlier rice: Ayu colours, flat and gapless, the pieces from before
Quickshell.

- **Bar:** waybar (`waybar/`), accent underline, workspace highlights.
- **Launcher:** fuzzel (`SUPER+Space`).
- **Notifications:** mako. **Volume/brightness:** wob, fed through a fifo
  by the theme's media key binds (`hypr-theme/scripts/wob.sh`).
- **Wallpaper:** a solid `bg` colour via swaybg (`scripts/wallpaper.sh`).
- **Lock:** hyprlock, password box only (`hyprlock -c
  ~/.config/hypr-theme/hyprlock.conf`).
- **Windows:** no gaps or borders, soft shadow, 8% dim when unfocused;
  Hyprland's stock animations.
- **Ghostty:** built-in `Ayu` / `Ayu Light`, accent selection, no padding.

Colours are hand-written in `palette/{dark,light}.env`; darkman renders the
`.tmpl` files from them. Needs `themes/ayu/packages.txt` installed (mako and
wob were uninstalled when zine replaced them).
