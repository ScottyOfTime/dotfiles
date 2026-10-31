# oldschool

An amber CRT terminal: phosphor amber on near-black, a whole-screen CRT
shader (scanlines, bloom, vignette), and a flat, text-only shell after
uint23's sxwm setup: no gaps, a 2px border, a solid `key: value` bar,
dmenu-style strips, a tty login as the lock screen. Lives in
`themes/oldschool/`; switch with `./theme oldschool`.

## The look

- **One phosphor.** Everything is amber (`fg`); `dim` is low-intensity
  text, `bright` is hot phosphor for focused borders, prompts and
  emphasis, `red` is errors only. Selection is **reverse video**: an
  amber fill with `bg` text (focused workspace, picked menu item, active
  Ghostty tab).
- **The CRT shader** (`hypr-theme/crt.frag`, Hyprland `screen_shader`)
  covers the whole screen, windows and video included: a darker line
  every third physical row, light bleeding from bright pixels into darker
  neighbours, and a vignette. No curvature (clicks would land off what you
  see) and no flicker. `SUPER+F12` toggles it (`hypr-theme/crt`): off
  is a `~/.local/state/oldschool-crt-off` file that `theme.lua` checks, so
  it stays off across reloads and light/dark switches.
- **Flat and square.** `Box` is a panel rectangle with a 2px border; no
  rounding, shadows, blur or animations anywhere (Hyprland animations
  are off). Windows: 0 gaps, 2px `bright` border.
- **Text, not widgets.** Bar modules are `key: value`; progress is
  `[#########-----------]` (`Meter`); buttons are `[prev] [play] [next]`.
- **tty-isms.** The wallpaper is the bare tube with
  `host · arch linux <kernel>`, `ready.` and a blinking block cursor. The
  lock screen is a login prompt (`Arch Linux <kernel> (tty1)`,
  `<host> login: <user>`, `Password:`) that, like a real one, never echoes
  the password; a wrong one prints `Login incorrect`.
- **JetBrains Mono everywhere.** No bitmap font is installed.
- **Light mode** is dark brown ink on warm paper, same structure.

Tried and dropped on the way here (as "portal"): blue/orange Portal
accents, Portal in-jokes and announcer lines, a test chamber sign, glowing
portals on the wallpaper, Frutiger Aero glass panels, desktop widgets, a
glossy Y2K player, and a faint grid wallpaper (1px lines render unevenly
at the 1.33 monitor scale).

## Palette

`themes/oldschool/colorscheme/oldschool.toml` is the source; `build.py`
writes the palette `.env` files, Ghostty themes, herdr config and
vim/airline colours (same pipeline as zine, see
[zine-pipeline.md](zine-pipeline.md)).

| Role | Dark | Light | Used for |
|---|---|---|---|
| `bg` | `0b0806` | `efe6d2` | the tube: wallpaper, lock, overview; text on reverse video |
| `panel` | `120d08` | `f8f1e2` | bar, strips, boxes |
| `surface` | `2b1c0c` | `e2d6ba` | workspace shown on an unfocused monitor |
| `fg` | `ffb52e` | `3a2408` | phosphor: text, reverse-video fill |
| `dim` | `9a6a24` | `8c6c40` | keys, titles, secondary text |
| `line` | `3d2810` | `cbb894` | unfocused borders, the bar's underline |
| `bright` | `ffd27a` | `a85400` | focused borders, prompts, emphasis |
| `red` | `ff5533` | `b8361a` | errors |

`blue`, `orange`, `yellow`, `green`, `cyan`, `purple` exist for the
terminal and editors only, warm-shifted. Cursor theme: Bibata-Modern-Amber.

## Quickshell

`themes/oldschool/quickshell/.config/quickshell/`, same IPC targets and
binds as zine ([zine-quickshell.md](zine-quickshell.md)).

| File | What |
|---|---|
| `Bar.qml` | Workspaces (focused in reverse video), window title, then `m:` (click for the player) `v:` (click mutes, scroll changes) `cpu:` `mem:` `net:` `d:` `t:` |
| `Strip.qml` | dmenu-style strip over the bar: `bright` prompt, optional search field, matches in a row; arrows/Tab move, Enter picks, Esc closes, digits pick when not searchable |
| `Launcher.qml` | `run` strip over the desktop entries (`SUPER+Space`) |
| `PowerMenu.qml` | `session` strip: 1 lock, 2 suspend, 3 log out, 4 reboot, 5 shut down (`SUPER+Escape`) |
| `Osd.qml` | `v: 50% [##########----------]` box under the bar; `b:` for brightness |
| `Notifications.qml` | Boxes top-right: `app · time`, summary, body, `[action]`s; `bright` border, red and sticky when critical; click dismisses |
| `MusicPopup.qml` | Track, artist · album, text progress bar, `[prev] [play] [next]` |
| `Lock.qml` | tty login prompt; PAM `login`, identical to zine's |
| `Overview.qml` | Live window thumbnails titled `workspace: title`; arrows/Tab, Enter, Esc (`SUPER+Tab`) |
| `Wallpaper.qml` | The tube with the `ready.` banner |
| `Tty.qml` | Host, kernel, user and the blinking cursor, shared by the wallpaper and lock |
| `Box.qml`, `Label.qml`, `Meter.qml` | Flat bordered box, text, text progress bar |
| `Stats.qml` | cpu, memory and network from `/proc` every 2s |

## Rules learned the hard way

- **Screen shaders are GLSL ES 3.00**: `#version 300 es`, `in vec2
  v_texcoord`, `uniform sampler2D tex`, `out vec4 fragColor`; get the
  resolution from `textureSize(tex, 0)` and physical rows from
  `gl_FragCoord`. Screenshots (`grim`) include the shader.
- **Toggle options by reloading, not by dispatching `hl.config`.**
  `hyprctl dispatch 'hl.config({...})'` applies but logs a config error
  every time, and the next reload discards it anyway.
- **Bloom needs a soft falloff.** Sampling one ring of pixels at a fixed
  distance draws a hard outline around anything whose brightness changes
  (Discord's hover states showed as a "border"); weight a 5x5 neighbourhood
  by distance instead.
- **Bloom must be relative.** Adding glow above a fixed brightness
  threshold washed light mode out to a haze; adding only
  `max(glow - colour, 0)` halos text and leaves flat areas alone.
- **Some names are reserved in QML.** A property called `print` is an
  "illegal property name", an id called `print` "masks a global
  JavaScript property", and a `top` property on a `Shape` "cannot override
  FINAL property"; each stops the whole shell loading.
- **Editing `Theme.qml.tmpl` needs a re-render** (`theme.sh $(darkman get)`)
  before new colours exist; until then QML warns "Unable to assign
  [undefined] to QColor".
- **Thin lines on a fractional scale** (1.33 here) land between pixels and
  render as a mix of thick and faint; avoid 1px decorative patterns.
- **Renaming a live theme**: disable autoreload, run its `stop`, `stow -D`
  its packages, `git mv`, then `./theme <new>` (the old name in
  `~/.local/state/dotfiles-theme` no longer exists, so nothing else is
  unstowed).
- **herdr keeps its old colours after `./theme`** until
  `herdr server reload-config`.
- Everything in zine's rules applies: no `SpringAnimation`, restart `qs`
  for new files, test the lock with `qs ipc call lock preview`.
