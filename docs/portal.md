# portal

A clean Aperture test chamber: white (or lights-down) wall panels, black
signage print, and the two portal colours. Everything lives in
`themes/portal/`; switch with `./theme portal`.

## The look

- **Two accents.** Blue is focus, selection and progress; orange is
  attention: the active workspace on another monitor, playing audio,
  warnings, critical notifications. Red is only for errors. The other
  terminal colours (yellow, green, cyan, purple) never appear in the UI.
- **Panels, not scraps.** Flat, seamed, 4px corners, no tilt. A panel
  swings out of the wall on its bottom hinge when it appears and back in
  when it goes. Lit panels (focused workspace, picked menu item, the
  launcher) glow in their colour.
- **Signage type.** Adwaita Sans throughout the UI (one family): bold for
  text, Black for numbers, small spaced capitals (`Caps`) for labels. The
  terminal stays JetBrains Mono (base).
- **Full immersion.** Workspaces are chambers, the window title is "now
  testing", notifications open with an announcer line, the launcher is an
  apparatus request form, the power menu is a set of procedures, the
  overview is the observation deck. Lines live in `Quips.qml`.
- **Windows.** 2px blue→orange gradient border with a matching glow on the
  focused window, soft shadow, 6/14 gaps, 4px rounding. Animations settle
  with a small overshoot (`arm` curve), never a bounce.

## Palette

`themes/portal/colorscheme/portal.toml` is the source; `build.py` writes
the palette `.env` files, Ghostty themes, herdr config and vim/airline
colours (same pipeline as zine, see [zine-pipeline.md](zine-pipeline.md)).

| Role | Dark | Light | Used for |
|---|---|---|---|
| `bg` | `14171a` | `dfe2e3` | chamber wall |
| `panel` | `1d2226` | `f6f7f7` | panels, signs |
| `surface` | `2a3035` | `ccd1d4` | hover, empty cells |
| `fg` | `e8ecee` | `1b1f22` | text |
| `dim` | `838d94` | `737b81` | labels, secondary text |
| `ink` | `e8ecee` | `1b1f22` | sign print, pictograms |
| `line` | `2c3338` | `bcc2c6` | panel seams, borders |
| `blue` | `2ea6ff` | `0b84e8` | portal one |
| `orange` | `ff8a1f` | `ec6a00` | portal two |
| `red` | `ff5a4c` | `d4322a` | errors |

Text on a blue/orange fill uses `Theme.onLit` (bg in dark, panel in light).

## Quickshell

`themes/portal/quickshell/.config/quickshell/`, same IPC targets and binds
as zine ([zine-quickshell.md](zine-quickshell.md)).

| File | What |
|---|---|
| `Panel.qml` | The building block: `fill`, `edge` (3px strip, bottom or `edgeLeft`), `glow`, `radius`, `padX/Y`, `out` (swing in/out), `delay` (ms before the first swing), `clicked`/`wheeled`/`hovered` |
| `Label.qml`, `Caps.qml` | Text; Caps is the small spaced-capital label |
| `Pictogram.qml`, `Icons.qml` | Filled 24px SVG-path pictograms (chamber hazards, power icons) |
| `PortalMark.qml` | Blue + orange portal pair, the theme's mark |
| `Hazard.qml` | Diagonal warning stripes |
| `Quips.qml` | Announcer lines; `pick(list, n)` is stable per number |
| `Chamber.qml` | Wallpaper (also behind the lock): tiled wall flips in, then the `Sign` swings out and the two `Portal`s open |
| `Sign.qml` | The chamber sign; its number is the monitor's workspace and flips when it changes; lit pictograms vary per chamber |
| `Portal.qml` | A glowing oval that irises open |
| `Bar.qml` | Mark (opens the launcher), chambers, now testing, clock, audio, vol/cpu/mem/net |
| `MusicPopup.qml` | Enrichment audio: art, track, progress, prev/play/next |
| `Launcher.qml` | Apparatus request form, centred |
| `Osd.qml` | Volume/brightness as a 20-cell progress bar |
| `Notifications.qml` | Announcements, blue edge; critical ones orange with hazard stripes and no timeout |
| `Lock.qml` | Chamber + verification panel; PAM `login`, identical to zine's |
| `PowerMenu.qml` | Five procedure signs; arrows or 1–5, Enter, Esc |
| `Overview.qml` | Observation deck: live window monitors grouped by chamber |

## Rules learned the hard way

- **Some names are reserved in QML.** A property called `print` is an
  "illegal property name", and an id called `print` "masks a global
  JavaScript property"; either stops the whole shell loading.
- **Setting `transform` or `opacity` on a `Panel` replaces its swing.**
  Put a jolt or nudge on a wrapper item instead (see `Lock.qml`).
- **herdr keeps its old colours after `./theme portal`** until
  `herdr server reload-config`.
- Everything in zine's rules applies: no `SpringAnimation`, restart `qs`
  for new files, test the lock with `qs ipc call lock preview`.
