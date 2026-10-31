# Hyprland

Config is Lua: `hypr/.config/hypr/hyprland.lua` (Hyprland 0.56). `hyprctl
dispatch` takes Lua expressions, e.g. `hyprctl dispatch 'hl.dsp.exec_cmd("x")'`.
Type stubs: `/usr/share/hypr/stubs/hl.meta.lua`.

Colours come from `colors.lua`, rendered by darkman (fallback values are
inline in `hyprland.lua`).

## Look and feel

See [theme.md](theme.md) for gaps/borders/shadows. Also:

- Key repeat 250ms delay, 40/s. Cursor hides while typing, no warps.
- Workspace back-and-forth: pressing the current workspace's number returns
  to the previous one.
- Swallowing: windows launched from Ghostty replace it until closed.
- Animations: windows pop in from 80% with an overshoot curve (`pop`),
  workspaces slide horizontally, scratchpads slide vertically, layers slide.
  The wallpaper and the Quickshell launcher layers are excluded (`no_anim`).

## Keybinds (`SUPER` = mod)

| Keys | Action |
|---|---|
| `mod+Return` | Ghostty |
| `mod+Space` | launcher |
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
| `mod+B` | toggle bar |
| `mod+T` | toggle light/dark |
| `mod+L` | lock |
| `mod+Escape` | power menu |
| `mod+minus` | type an en dash |
| `Print` | flameshot region screenshot to `~/screenshots` + clipboard |
| media keys | volume, brightness, playerctl (OSD shows automatically) |
| `mod+shift+Q` | exit Hyprland (`hl.dsp.exit()`; the old `hyprctl dispatch exit` is a no-op in Lua mode) |

Workspaces 1–2 are on DP-2 (left), 3–4 on DP-3 (right).

## Window and layer rules

Discord → workspace 3, Steam → `special:magic`, Spotify → `special:music`,
flameshot overlay floats at the origin, the drop-down Ghostty
(`com.scotty.dropdown`) floats 70%x55% at the top on `special:dropdown`.

## Scripts (`hypr/scripts/`)

- `dropdown.sh`: toggles the drop-down terminal, launching it the first time
  (launched non-silent so it gets focus).

## Idle and locking

`hypridle.conf`: lock after 10 min, screens off at 11, lock before sleep,
screens on after waking. Locking goes through Quickshell (`qs ipc call lock
lock`). Video and games inhibit idle. `hyprlock.conf.tmpl` is the themed
fallback locker.
