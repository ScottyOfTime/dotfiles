# Themes

A theme is a folder of stow packages in `themes/<name>/`. `base/` never
changes between themes.

## Switching

```
./theme          # list; * marks the active one
./theme ayu      # switch
```

It runs the old theme's `~/.config/hypr-theme/stop`, unstows its packages,
stows the new ones, records the name in `~/.local/state/dotfiles-theme`,
runs the new `~/.local/share/darkman/theme.sh` for the current mode
(renders colours, reloads Hyprland) and runs `~/.config/hypr-theme/start`.

Install a theme's apps from its `packages.txt` first.

## What a theme provides

Every folder in a theme is a stow package except `colorscheme/`. Files are
`packages.txt` (not stowed).

| Path (after stowing) | Required | Purpose |
|---|---|---|
| `~/.config/hypr-theme/theme.lua` | yes | Loaded at the end of base `hyprland.lua` (inside `pcall`): look, animations, cursor env, layer rules, and binds for the theme's own UI |
| `~/.config/hypr-theme/start` | yes | Starts the theme's bar/wallpaper/daemons; run at login and on switch |
| `~/.config/hypr-theme/stop` | yes | Stops them; run when switching away |
| `~/.config/hypr-theme/lock` | yes | Locks the session; `SUPER+L` and hypridle call it |
| `~/.config/ghostty-theme/config` | no | Included by base Ghostty config (optional include): colours, padding, `gtk-custom-css` |
| `~/.local/share/darkman/theme.sh` | yes | Darkman hook: applies a light/dark mode to the theme's apps |
| `~/.config/palette/{dark,light}.env` | by convention | Colours the darkman script renders templates from |

### Keys a theme binds

Base deliberately leaves these to the theme (binding a key in both would
clash): `SUPER+Space` (launcher), `SUPER+B` (bar), volume up/down/mute and
brightness keys (they drive the theme's OSD), and any extras (zine:
`SUPER+Escape` power menu, `SUPER+Tab` overview). `SUPER+L` is in base and
calls the theme's `lock`.

## Making a new theme

1. `cp -r themes/zine themes/<name>` (or start from `ayu`).
2. Add its generated files (anything rendered from a `.tmpl`) to
   `.gitignore`.
3. Edit freely; only `themes/<name>/` changes, so an experiment branch
   merges without touching base or other themes.
4. `./theme <name>`.

## Gotchas

- Stow folds a whole folder into one symlink when only one package owns
  it. That's why theme parts of Hyprland and Ghostty live in their own
  folders (`hypr-theme`, `ghostty-theme`) instead of inside base's: two
  stow trees can't share a folded directory.
- Ghostty's theme paths must be absolute and `~` isn't expanded, so zine's
  `ghostty-theme/config` is a template that gets `${HOME}`. Relative
  `config-file` / `gtk-custom-css` paths resolve from the including file's
  location (not its symlink target).
- Hyprland reloads on save. While restructuring live config files, disable
  it first: `hyprctl dispatch 'hl.config({ misc = { disable_autoreload = true } })'`
  (prints an error but applies; the next `hyprctl reload` restores it).
