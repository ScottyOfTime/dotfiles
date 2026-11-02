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
- **vim/nvim:** `ayu`, a colorscheme rendered from the palette
  (`vim-theme/.config/vim-theme/colors/ayu.vim.tmpl`; no ayu-vim plugin); **herdr:** Ayu Dark over one-dark.

Colours are hand-written in `palette/{dark,light}.env` (`on_accent` is the
text on the accent, for GNOME, see gnome.md); darkman renders the
`.tmpl` files from them. Needs `themes/ayu/packages.txt` installed (mako and
wob were uninstalled when zine replaced them).
