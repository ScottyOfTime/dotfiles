# oldschool

An amber terminal: phosphor amber on near-black and a flat, text-only
shell after uint23's sxwm setup: no gaps, no borders, a solid `key: value` bar,
dmenu-style strips, a tty login as the lock screen. Lives in
`themes/oldschool/`; switch with `./theme oldschool`.

## The look

- **One phosphor.** Everything is amber (`fg`); `dim` is low-intensity
  text, `bright` is hot phosphor for prompts and
  emphasis, `red` is errors only. Selection is **reverse video**: an
  amber fill with `bg` text (focused workspace, picked menu item, active
  Ghostty and herdr tabs; herdr's `accent` is `fg`, not `bright`).
- **Flat and square.** `Box` is a panel rectangle with a 2px border; no
  rounding, shadows, blur or animations anywhere (Hyprland animations
  are off). Windows: no gaps and no borders. When a workspace has more
  than one window, a 3px `fg` strip (`Focus.qml`) sits along the top of
  the focused one.
- **Terminal.** Ghostty with 2px padding (balanced, padding takes the
  background colour), Terminus (`ttf-terminus-nerd`, "Terminess Nerd
  Font Mono") at 18pt with antialiasing off, ligatures off, and a steady
  block cursor in `fg` (not `bright`: a brighter-than-text cursor glares). Tabs are a flat text line with `|`
  separators, the current one in reverse video.
- **htop** uses its built-in Monochrome scheme (`htop/.config/htop/htoprc`,
  a theme stow package), so it draws in the terminal's amber with
  `#`/`*`/`|` meters. Changing settings in htop rewrites this file, in the
  repo.
- **Text, not widgets.** Bar modules are `key: value`; progress is
  `[#########-----------]` (`Meter`); buttons are `[prev] [play] [next]`.
- **tty-isms.** Logging in is a CRT powering on over every screen: a
  beam opens to a full amber screen and fades, a boot log prints (the real
  kernel, CPU and RAM, `[  OK  ]` units, `<host> login: <user>`,
  `ready.`), then the screen rolls down off the desktop behind a scanline;
  about three seconds, covering apps as they start. Once per Hyprland
  session; a click skips it. The wallpaper is the bare tube with
  `host · arch linux <kernel>`, `ready.` and a blinking block cursor. The
  lock screen is the distro's fastfetch logo, big and centred, over the
  user name and, centred under it, the password as `*`s (only the stars
  are centred; the blinking block trails them);
  a wrong one prints `Login incorrect` under it. Only the primary screen (the one at 0,0) shows it; the
  others are blank `bg`.
- **Terminus everywhere**: the terminal (18pt, 24 physical px), the
  Quickshell UI (`Theme.fontSize` 15px, 20 physical, with
  `Text.NativeRendering` so Qt hints it onto the pixel grid), GTK
  (11.25pt, also 20 physical) and hyprlock.
- **Light mode** is dark brown ink on tractor-feed printer paper: the
  wallpaper has alternating bands and sprocket holes down both edges.

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
| `line` | `3d2810` | `cbb894` | the bar's underline, box edges |
| `bright` | `ffd27a` | `a85400` | prompts, emphasis |
| `red` | `ff5533` | `b8361a` | errors |

`blue`, `orange`, `yellow`, `green`, `cyan`, `purple` exist for the
terminal and editors only, warm-shifted. Cursor theme: whiteglass, the classic X11 arrow (`xcursor-themes`).

## Quickshell

`themes/oldschool/quickshell/.config/quickshell/`, same IPC targets and
binds as zine ([zine-quickshell.md](zine-quickshell.md)).

| File | What |
|---|---|
| `Bar.qml` | A classic status line split by `\|`: workspaces (focused in reverse video), `> title`, then `mus` (click for the player), `vol` (click mutes, scroll changes), `cpu`, `mem`, `net`, date, time |
| `Focus.qml` | The focused-window strip: an overlay layer placed from the window's `lastIpcObject`, refreshed on Hyprland window events; click-through |
| `Strip.qml` | dmenu-style strip over the bar: `bright` prompt, optional search field, matches in a row; arrows/Tab move, Enter picks, Esc closes, digits pick when not searchable |
| `Launcher.qml` | `run` strip over the desktop entries (`SUPER+Space`) |
| `PowerMenu.qml` | `session` strip: 1 lock, 2 suspend, 3 log out, 4 reboot, 5 shut down (`SUPER+Escape`) |
| `Osd.qml` | `v: 50% [##########----------]` box under the bar; `b:` for brightness |
| `Notifications.qml` | One log line each under the bar, top-right: `[HH:mm] app: summary - body` plus `[action]`s; red and sticky when critical; click dismisses |
| `MusicPopup.qml` | Track, artist · album, text progress bar, `[prev] [play] [next]` |
| `Lock.qml` | Logo (`fastfetch --pipe -s none`, so any distro), user and masked password on the screen at 0,0; PAM `login`, identical to zine's |
| `Overview.qml` | Every window as a `WS CLASS TITLE` row, like `ps`; up/down/Tab, Enter focuses, Esc or a click outside closes (`SUPER+Tab`) |
| `Boot.qml` | The login power-on and boot log; `$XDG_RUNTIME_DIR/oldschool-booted` holds the Hyprland instance signature it last played for; `qs ipc call boot replay` shows it again |
| `Wallpaper.qml` | The `ready.` banner; on paper bands and sprocket holes in light mode |
| `Tty.qml` | Host, kernel, user and the blinking cursor, shared by the wallpaper and lock |
| `Box.qml`, `Label.qml`, `Meter.qml` | Flat bordered box, text, text progress bar |
| `Stats.qml` | cpu, memory and network from `/proc` every 2s |

## Rules learned the hard way

- **No screen shader.** A whole-screen CRT shader (bloom, scanlines, then
  a monochrome phosphor remap) was tried and dropped: it made apps hard
  to use. If one comes back: GLSL ES 3.00, declare `precision highp int`
  (mediump ints are 16 bits and silently drop a packed hex's red byte),
  and give bloom a soft, relative falloff (a fixed ring of taps outlined
  Discord's hover states; a fixed threshold washed light mode out).
- **Toggle options by reloading, not by dispatching `hl.config`.**
  `hyprctl dispatch 'hl.config({...})'` applies but logs a config error
  every time, and the next reload discards it anyway.
- **`lastIpcObject` is a snapshot.** A toplevel's position and size only
  update after `Hyprland.refreshToplevels()`; `Focus.qml` calls it on the
  window events from `Hyprland.rawEvent`.
- **Pixel fonts need their native size** (12, 14, 16, 18, 20, 22, 24, 28,
  32 physical px for Terminus). Ghostty here draws 1.33 physical px per
  point, so Terminus's 24px size is 18pt (13.5pt is its
  thin 18px size); in-between sizes smear strokes. `font-family` only
  applies to new windows; a reload changes the size of open ones.
- **Lock prompt lines are separate labels.** One centred text block
  re-centres every line as the password grows, so the user name jumped
  half a cell per key; each is its own label, centred at a rounded x so
  the pixel font stays sharp.
- **`$XDG_RUNTIME_DIR` outlives a logout** while any user process lingers
  (herdr's server, say), so a bare "already ran" flag there skipped the
  boot screen on every login after the first; compare the Hyprland
  instance signature instead.
- **Some names are reserved.** A QML method called `escape` is an
  "illegal method name", and `qs ipc call <target> show` runs `qs ipc
  show` instead of the function, so don't name IPC functions `show`.
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
