# portal

A clean test chamber crossed with Frutiger Aero / Y2K: a tiled wall,
frosted glass panels, HUD-style readouts, a glossy blue player and the two
portal colours. Tuned light-first; dark mode follows. Everything lives in
`themes/portal/`; switch with `./theme portal`.

## The look

- **Two accents.** Blue is focus, selection and progress; orange is
  attention: the active workspace on another monitor, playing audio,
  warnings, critical notifications. Red is only for errors. The other
  terminal colours (yellow, green, cyan, purple) never appear in the UI.
- **Frosted glass panels.** Translucent (`Theme.glass`), thin seam border,
  a 1px sheen along the top, 4px corners, no tilt. Hyprland blurs what's
  behind the shell's layers, so the power menu and overview backdrops are
  frosted too. A panel swings out of the wall on its bottom hinge when it
  appears and back in when it goes. Lit panels (focused workspace, picked
  menu item, the launcher) glow in their colour.
- **Readout headers.** Widgets and popups open with a small-caps title on
  the left, metadata on the right and a hairline under both (`Readout`):
  `launcher · 73 apps`, `session · up 3h`, `firefox · 16:34`.
- **Desktop widgets** on the wallpaper (behind windows): a clock (time,
  the workspace number in blue, date, day/week/uptime) top-left and a
  system column (processor ring + sparkline, memory, storage, network)
  top-right. The lock screen shows the clock only.
- **JetBrains Mono everywhere**: bold for text, ExtraBold for numbers,
  small capitals (`Caps`) for labels. An Adwaita Sans signage font was
  tried and dropped.
- **References stay in the visuals.** The portals, hazard stripes and
  pictograms carry the theme; all text is plain (`password`, `search`, app
  names). A full-immersion pass with announcer lines and in-game wording
  was tried and dialled back as too much, and a big test chamber sign
  with hazard pictograms was dropped from the wallpaper as too busy.
- **Windows.** 2px blue→orange gradient border with a matching glow on the
  focused window, soft shadow, 6/14 gaps, 4px rounding. Animations settle
  with a small overshoot (`arm` curve), never a bounce.

## Palette

`themes/portal/colorscheme/portal.toml` is the source; `build.py` writes
the palette `.env` files, Ghostty themes, herdr config and vim/airline
colours (same pipeline as zine, see [zine-pipeline.md](zine-pipeline.md)).

| Role | Dark | Light | Used for |
|---|---|---|---|
| `bg` | `14171a` | `e3e9ef` | wall tiles |
| `panel` | `1d2226` | `f8fafc` | panels (as glass) |
| `surface` | `2a3035` | `d3dce5` | hover, empty tracks |
| `fg` | `e8ecee` | `18202a` | text |
| `dim` | `838d94` | `6c7884` | labels, secondary text |
| `ink` | `e8ecee` | `18202a` | pictograms |
| `line` | `2c3338` | `bfcad5` | panel seams, borders, wall grid |
| `blue` | `2ea6ff` | `0b84e8` | portal one |
| `orange` | `ff8a1f` | `ec6a00` | portal two |
| `red` | `ff5a4c` | `d4322a` | errors |

Derived in `Theme.qml.tmpl`: `onLit` (text on a blue/orange fill), `glass`
and `glassHover` (translucent panel fills), `sheen` (the top highlight) and
`glint` (light in both modes: print and gloss on the blue player).

## Quickshell

`themes/portal/quickshell/.config/quickshell/`, same IPC targets and binds
as zine ([zine-quickshell.md](zine-quickshell.md)).

| File | What |
|---|---|
| `Panel.qml` | The building block: `fill`, `edge` (3px strip, bottom or `edgeLeft`), `glow`, `radius`, `padX/Y`, `out` (swing in/out), `delay` (ms before the first swing), `clicked`/`wheeled`/`hovered` |
| `Label.qml`, `Caps.qml` | Text; Caps is the small spaced-capital label |
| `Pictogram.qml`, `Icons.qml` | Filled 24px SVG-path pictograms (portal, player and power icons) |
| `PortalMark.qml` | Blue + orange portal pair, the theme's mark |
| `Hazard.qml` | Diagonal warning stripes (critical notifications) |
| `Chamber.qml` | Wallpaper (also behind the lock, with `telemetry: false`): tiled wall flips in, the two `Portal`s open, then the widgets swing out |
| `Chrono.qml` | Clock widget; `workspace` is the monitor's |
| `Telemetry.qml` | System widget: processor, memory, storage, network cards |
| `Readout.qml` | Title / metadata header with a hairline |
| `Meter.qml`, `Ring.qml`, `Sparkline.qml` | Bar, round gauge and history line; turn orange past 75%, red past 90% |
| `Portal.qml` | A glowing oval that irises open |
| `Stats.qml` | cpu (+history), memory, swap, net down/up (+history), load, freq, temp (cpu hwmon found by name), uptime, disk every 2s/60s |
| `Bar.qml` | Mark (opens the launcher), workspaces, window title, clock, audio, vol/cpu/mem/net |
| `MusicPopup.qml` | Glossy blue player: round gloss buttons beside a dark screen with art, track, time and progress |
| `Launcher.qml` | Readout, search and app list, centred |
| `Osd.qml` | Volume/brightness as a 20-cell progress bar |
| `Notifications.qml` | App name, summary, body; blue edge; critical ones orange with hazard stripes and no timeout |
| `Lock.qml` | Wallpaper + a password panel; PAM `login`, identical to zine's |
| `PowerMenu.qml` | Session readout over five pictogram panels; arrows or 1–5, Enter, Esc |
| `Overview.qml` | Readout over live window monitors grouped by workspace |

## Rules learned the hard way

- **Some names are reserved in QML.** A property called `print` is an
  "illegal property name", and an id called `print` "masks a global
  JavaScript property"; either stops the whole shell loading.
- **Setting `transform` or `opacity` on a `Panel` replaces its swing.**
  Put a jolt or nudge on a wrapper item instead (see `Lock.qml`).
- **Properties can clash with built-in FINAL ones.** A `top` property on
  a `Shape` fails with "Cannot override FINAL property"; pick another name.
- **Editing `Theme.qml.tmpl` needs a re-render** (`theme.sh $(darkman get)`)
  before new colours exist; until then they're `undefined` and QML warns
  "Unable to assign [undefined] to QColor".
- **The frosted look depends on the `frosted-shell` layer rule**'s
  `ignore_alpha`, which keeps the blur to the panels instead of the whole
  clear layer. Wallpaper widgets sit on the background layer, which has
  nothing under it to blur.
- **herdr keeps its old colours after `./theme portal`** until
  `herdr server reload-config`.
- Everything in zine's rules applies: no `SpringAnimation`, restart `qs`
  for new files, test the lock with `qs ipc call lock preview`.
