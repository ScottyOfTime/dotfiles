# Hyprland

Config is Lua: `base/hypr/.config/hypr/hyprland.lua` (Hyprland 0.56), shared
by every theme. It ends by loading the active theme's
`~/.config/hypr-theme/theme.lua` ([themes.md](themes.md)). `hyprctl
dispatch` takes Lua expressions, e.g. `hyprctl dispatch 'hl.dsp.exec_cmd("x")'`.
Type stubs: `/usr/share/hypr/stubs/hl.meta.lua`.

Colours belong to the theme: its `theme.lua` reads `hypr-theme/colors.lua`
(rendered by darkman) with inline defaults filling any missing field.
Hyprland reloads on save, so a new colour referenced before darkman renders
it would otherwise be nil, which puts Hyprland in emergency mode with no
keybinds.

## Feel (base)

Gaps, borders, shadows and animations are the theme's; see its docs.

- Key repeat 250ms delay, 40/s. Cursor hides while typing, no warps.
- Workspace back-and-forth: pressing the current workspace's number returns
  to the previous one.
- Swallowing: windows launched from Ghostty replace it until closed.
- At start: the theme's shell, hypridle and a Ghostty running fastfetch,
  then the host file's `autostart` (the desktop: Discord, Signal, Steam,
  Spotify; see [setup.md](setup.md#another-machine)).

## Keybinds (`SUPER` = mod)

Marked † are bound by the theme (zine shown).

| Keys | Action |
|---|---|
| `mod+Return` | Ghostty |
| `mod+Space` | launcher † |
| `mod+grave` | drop-down terminal (toggle) |
| `mod+E` | Files: yazi, floating in the centre (toggle; kept running on `special:files`) |
| `mod+W` | close window |
| `mod+F` / `mod+V` / `mod+P` | fullscreen / float / pseudo |
| `mod+J` | toggle split |
| `mod+arrows` | focus |
| `mod+shift+arrows` | move window |
| `mod+ctrl+arrows` | resize (repeats) |
| `mod+1..0` / `mod+shift+1..0` | workspace / move to workspace |
| `mod+S` / `mod+shift+S` | scratchpad "magic" (Steam lives here) |
| `mod+M` / `mod+shift+M` | scratchpad "music" (Spotify lives here) |
| `mod+B` | toggle bar † |
| `mod+T` | toggle light/dark |
| `mod+L` | lock (the theme's `hypr-theme/lock`) |
| `mod+Escape` | power menu † (zine) |
| `mod+Tab` | window overview † (zine) |
| `mod+minus` | type an en dash (`wtype`; needs `resolve_binds_by_sym`, see below the table) |
| `Print` | flameshot region screenshot to `~/screenshots` + clipboard |
| media keys | playerctl and mic mute in base; volume/brightness † (they drive the theme's OSD) |
| `mod+shift+Q` | exit Hyprland (`hl.dsp.exit()`; the old `hyprctl dispatch exit` is a no-op in Lua mode) |

`input:resolve_binds_by_sym` is on because `wtype` types through its own
temporary keymap, where the en dash sits on keycode 9. With the option off,
Hyprland reads binds through the normal layout, so SUPER (still held)
plus keycode 9 matched `mod+Escape` and opened the power menu. The bind
fires on press, not release: with the option on, a release bind lets the
`-` press through, so apps got a hyphen before the dash.

Scale is worked out per monitor from its pixel density
([setup.md](setup.md#another-machine)). On the desktop
(`hosts/scotty-desktop.lua`) workspaces 1–2 are on DP-2 (left), 3–4 on
DP-3 (right).

## Window and layer rules

On the desktop Discord and Signal → workspace 3 (host file); Steam → `special:magic`, Spotify → `special:music`,
flameshot overlay floats at the origin, the drop-down Ghostty
(`com.scotty.dropdown`) floats 70%x55% at the top on `special:dropdown`.
yazi as Files floats 60%x60% in the centre: `com.scotty.files` for
folders and the file picker, `com.scotty.filespad` for `mod+E`'s one on
`special:files`. Themes without window borders (oldschool,
ayu) give both a 2px one (`floating-terminal-outline` rule in their
`theme.lua`) so they stand out over a terminal underneath.

## Scripts (`base/hypr/.config/hypr/scripts/`)

- `dropdown.sh`: toggles the drop-down terminal, launching it the first time
  (launched non-silent so it gets focus).
- When the dropdown or `mod+E`'s yazi closes (`exit`, `q`, `mod+W`),
  `hyprland.lua`'s `window.close` handler starts a replacement hidden on its
  special workspace, so the next toggle is instant. It waits 0.3s and skips
  if one is still open, since a close Ghostty answers with its "close
  terminal?" prompt leaves the window up. `window.destroy` passes no window,
  so it can't be used for this. The handler `exec`s Ghostty from `sh` so the
  silent rule `exec_cmd` attaches to that pid still applies.
- `files.sh`: toggles `mod+E`'s yazi on `special:files`, launching it the
  first time. It stays running because a fresh Ghostty takes ~200ms to
  map and a toggle ~30ms. It skips the theme's `special` hook, whose
  warm-up would slow it down again.
- `filespad.sh`: what the pad's Ghostty runs: yazi, restarted when it
  exits with status 138 (`SIGUSR1`, sent after a mode switch to reload its
  theme, see `apps.md`).
- `special.sh <name>`: toggles a scratchpad (`mod+S`, `mod+M`). If the theme
  has an executable `hypr-theme/special` it runs that instead (oldschool
  warms the scratchpad up); if that fails, it toggles directly.

## Idle and locking

`hypridle.conf`: lock after 10 min, screens off at 11, lock before sleep,
screens on after waking. Locking runs the theme's `~/.config/hypr-theme/lock`.
Video and games inhibit idle.
