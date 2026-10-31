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

## Keybinds (`SUPER` = mod)

Marked † are bound by the theme (zine shown).

| Keys | Action |
|---|---|
| `mod+Return` | Ghostty |
| `mod+Space` | launcher † |
| `mod+grave` | drop-down terminal (toggle) |
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
| `mod+minus` | type an en dash |
| `Print` | flameshot region screenshot to `~/screenshots` + clipboard |
| media keys | playerctl and mic mute in base; volume/brightness † (they drive the theme's OSD) |
| `mod+shift+Q` | exit Hyprland (`hl.dsp.exit()`; the old `hyprctl dispatch exit` is a no-op in Lua mode) |

Workspaces 1–2 are on DP-2 (left), 3–4 on DP-3 (right).

## Window and layer rules

Discord → workspace 3, Steam → `special:magic`, Spotify → `special:music`,
flameshot overlay floats at the origin, the drop-down Ghostty
(`com.scotty.dropdown`) floats 70%x55% at the top on `special:dropdown`.

## Scripts (`base/hypr/.config/hypr/scripts/`)

- `dropdown.sh`: toggles the drop-down terminal, launching it the first time
  (launched non-silent so it gets focus).

## Idle and locking

`hypridle.conf`: lock after 10 min, screens off at 11, lock before sleep,
screens on after waking. Locking runs the theme's `~/.config/hypr-theme/lock`.
Video and games inhibit idle.
