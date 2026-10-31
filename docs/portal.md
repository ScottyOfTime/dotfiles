# portal

Old-school and flat, after uint23's sxwm setup: no gaps, a 2px border,
no rounding, shadows, blur or animations, one solid bar of `key: value`
text, dmenu-style strips for menus. Portal's blue and orange are the only
colours. Everything lives in `themes/portal/`; switch with `./theme portal`.

## The look

- **Two accents.** Blue is focus and selection (focused window border,
  focused workspace, picked menu item, progress); orange is attention
  (strip prompts, muted audio, critical notifications, high cpu/mem). Red
  is only for errors.
- **Flat and square.** `Box` is a panel-coloured rectangle with a 2px
  border; nothing tilts, glows, blurs or animates. Windows: 0 gaps, 2px
  blue border, 0 rounding, Hyprland animations off.
- **Text, not widgets.** Bar modules are `key: value` (`v: 50%`,
  `cpu: 3%`, `d: 2026-10-31`, `t: 16 : 45`); progress is a text bar
  (`[#########-----------]`, `Meter`); buttons are `[prev] [play] [next]`.
- **JetBrains Mono everywhere**, regular weight, bold only for the picked
  item.
- **Solid wallpaper** (`bg`), like `xsetroot -solid`.

Tried and dropped along the way: Portal in-jokes and announcer lines, an
Adwaita Sans signage font, a test chamber sign with pictograms, glowing
portals on the wallpaper, Frutiger Aero glass panels with blur, desktop
clock/system widgets, a glossy Y2K music player, and a faint grid
wallpaper (1px lines render unevenly at the 1.33 monitor scale).

## Palette

`themes/portal/colorscheme/portal.toml` is the source; `build.py` writes
the palette `.env` files, Ghostty themes, herdr config and vim/airline
colours (same pipeline as zine, see [zine-pipeline.md](zine-pipeline.md)).

| Role | Dark | Light | Used for |
|---|---|---|---|
| `bg` | `14171a` | `e3e9ef` | wallpaper, lock, overview |
| `panel` | `1d2226` | `f8fafc` | bar, strips, boxes |
| `surface` | `2a3035` | `d3dce5` | workspace shown on an unfocused monitor |
| `fg` | `e8ecee` | `18202a` | text |
| `dim` | `838d94` | `6c7884` | module keys, window title, secondary text |
| `line` | `2c3338` | `bfcad5` | unfocused borders, bar underline |
| `blue` | `2ea6ff` | `0b84e8` | focus, selection, progress |
| `orange` | `ff8a1f` | `ec6a00` | prompts, attention |
| `red` | `ff5a4c` | `d4322a` | errors |

`Theme.onLit` is text on a blue/orange fill (bg in dark, panel in light);
`Theme.bar` is the strip height (26).

## Quickshell

`themes/portal/quickshell/.config/quickshell/`, same IPC targets and binds
as zine ([zine-quickshell.md](zine-quickshell.md)).

| File | What |
|---|---|
| `Bar.qml` | Workspaces (focused filled blue), window title, then `m:` (click for the player) `v:` (click mutes, scroll changes) `cpu:` `mem:` `net:` `d:` `t:` |
| `Strip.qml` | dmenu-style strip over the bar: orange prompt, optional search field, matches in a row; arrows/Tab move, Enter picks, Esc closes, digits pick when not searchable |
| `Launcher.qml` | `run` strip over the desktop entries (`SUPER+Space`) |
| `PowerMenu.qml` | `session` strip: 1 lock, 2 suspend, 3 log out, 4 reboot, 5 shut down (`SUPER+Escape`) |
| `Osd.qml` | `v: 50% [##########----------]` box under the bar; `b:` for brightness |
| `Notifications.qml` | Boxes top-right: `app · time`, summary, body, `[action]`s; blue border, orange and sticky when critical; click dismisses |
| `MusicPopup.qml` | Track, artist · album, text progress bar, `[prev] [play] [next]` |
| `Lock.qml` | A single `password: ***_` box; PAM `login`, identical to zine's |
| `Overview.qml` | Live window thumbnails titled `workspace: title`; arrows/Tab, Enter, Esc (`SUPER+Tab`) |
| `Box.qml`, `Label.qml`, `Meter.qml` | Flat bordered box, text, text progress bar |
| `Wallpaper.qml` | Solid `bg` per screen |
| `Stats.qml` | cpu, memory and network from `/proc` every 2s |

## Rules learned the hard way

- **Some names are reserved in QML.** A property called `print` is an
  "illegal property name", an id called `print` "masks a global
  JavaScript property", and a `top` property on a `Shape` "cannot override
  FINAL property"; each stops the whole shell loading.
- **Editing `Theme.qml.tmpl` needs a re-render** (`theme.sh $(darkman get)`)
  before new colours exist; until then QML warns "Unable to assign
  [undefined] to QColor".
- **Thin lines on a fractional scale** (1.33 here) land between pixels and
  render as a mix of thick and faint; avoid 1px decorative patterns.
- **herdr keeps its old colours after `./theme portal`** until
  `herdr server reload-config`.
- Everything in zine's rules applies: no `SpringAnimation`, restart `qs`
  for new files, test the lock with `qs ipc call lock preview`.
