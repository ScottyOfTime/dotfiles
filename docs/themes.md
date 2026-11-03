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
If stowing the new theme fails (a conflicting file), it restows the old
one and restarts its shell rather than leave Hyprland without a theme.
`./theme --packages <name>` prints a theme's stow packages (`./install`
uses it).

Only packages whose app is installed (and that `./install`'s menu didn't
skip) are stowed, and ones already linked that shouldn't be get unstowed,
both reported (`lib/links.sh`, shared with
`./install`; see [setup.md](setup.md#without-hyprland-gnome-etc)). So
Hyprland and Quickshell steps are skipped where they don't exist.

Install a theme's apps from its `packages.txt` first.

## What a theme provides

Every folder in a theme is a stow package except `colorscheme/`,
`system/` (system-level extras run by hand with sudo, never by `./theme`)
and `preview/` (the README's pictures). Files are `packages.txt` and
`README.md` (not stowed).

### README and previews

Each theme's `README.md` shows it in both modes and lists its palette;
the root `README.md` shows each theme's dark screenshot and colour strip.
`lib/previews [theme...]` redraws `preview/palette.svg` and
`preview/strip.svg` from the palette `.env` files and refills the hex
columns of the README's role table (between its `<!-- palette -->`
markers; the "Used for" column is kept, and a new role gets an empty
one). Run it after changing a palette.

`preview/dark.png` and `light.png` are `grim -o <monitor>` shots of the
same staged workspace (fastfetch, nvim on `lib/theme.sh`, yazi on
`themes/`). Stage it on an empty workspace with
`hl.dsp.exec_cmd(cmd, { workspace = "9 silent" })`: a plain `exec_cmd`
opens on whichever monitor the mouse is on. Keep private things out of
the shot: no LAN IP in fastfetch (`-s` without `LocalIp`), no process
list.

| Path (after stowing) | Required | Purpose |
|---|---|---|
| `~/.config/hypr-theme/theme.lua` | yes | Loaded at the end of base `hyprland.lua` (inside `pcall`): look, animations, cursor env, layer rules, and binds for the theme's own UI |
| `~/.config/hypr-theme/start` | yes | Starts the theme's bar/wallpaper/daemons; run at login and on switch |
| `~/.config/hypr-theme/stop` | yes | Stops them; run when switching away |
| `~/.config/hypr-theme/special` | no | Called with a scratchpad name by base's `special.sh` (`mod+S`, `mod+M`) to toggle it with the theme's own effect; exit non-zero to fall back to a plain toggle |
| `~/.config/hypr-theme/lock` | yes | Locks the session; `SUPER+L` and hypridle call it |
| `~/.config/ghostty-theme/config` | no | Included by base Ghostty config (optional include): colours, padding, `gtk-custom-css` |
| `~/.local/share/darkman/theme.sh` | yes | Darkman hook: applies a light/dark mode to the theme's apps. It sources `lib/theme.sh`, which writes the mode to `$XDG_STATE_HOME/theme-mode` (vim/nvim read it at startup), loads the palette and gives `desktop` (gsettings), `render` (every linked `.tmpl`) and `reload` (Hyprland, GNOME, Ghostty); the theme adds only what's its own |
| `~/.config/palette/{dark,light}.env` | by convention | Colours the darkman script renders templates from |
| `~/.config/vim-theme/theme.vim` | no | Sourced by vim and nvim (dir is prepended to runtimepath): sets the colorscheme and airline theme; without it they use their default colours (there is no plugin colorscheme) |
| `~/.config/yazi/theme.toml` | no | yazi colours, rendered from `theme.toml.tmpl` by `theme.sh` (yazi only reads it at startup) |
| `~/.config/btop/` | no | btop config and `themes/palette.theme`, rendered from `palette.theme.tmpl` by `theme.sh` |
| `~/.config/herdr/config.toml` | no | herdr colours (file-level link; `~/.config/herdr` also holds herdr's runtime files) |
| `gnome/` package | no | The theme on GNOME: shell stylesheet extension and GTK 4 colours, rendered by `theme.sh` and applied by `lib/gnome-look` ([gnome.md](gnome.md)) |

A new package for an app that might not be installed needs a line in
`needs()` in `lib/links.sh`, or it's always linked. `theme.sh` has to cope with
any of them missing: it skips templates that aren't there and calls
`hyprctl` only while Hyprland runs, and sets `gsettings` (fonts, cursor,
accent, dark mode) only where Hyprland is installed or the theme's `gnome`
package is linked ([gnome.md](gnome.md)); elsewhere the theme reaches only
Ghostty. Anything it needs from an unlinked package it
takes from the repo, through `readlink -f "$0"` (oldschool's
`terminus-outline`, which makes Ghostty's font).

### Keys a theme binds

Base deliberately leaves these to the theme (binding a key in both would
clash): `SUPER+Space` (launcher), `SUPER+B` (bar), volume up/down/mute and
brightness keys (they drive the theme's OSD), and any extras (zine:
`SUPER+Escape` power menu, `SUPER+Tab` overview; oldschool also
`SUPER+SHIFT+F` font picker). `SUPER+L` is in base and
calls the theme's `lock`.

## Making a new theme

1. `cp -r themes/zine themes/<name>` (or start from `ayu`).
2. Add its generated files (anything rendered from a `.tmpl`) to
   `.gitignore`. Rewrite its `README.md`, run `lib/previews <name>` and
   retake the screenshots (above).
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
- A vim colorscheme must set `background` before `hi clear`. `hi clear`
  resets nvim's built-in groups (`@variable`, `Added`, ...) for the current
  `background`, so the other order leaves them in the old mode's colours
  after `:Theme` switches modes. A fresh start hides this.
