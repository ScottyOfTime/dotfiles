# oldschool

An amber terminal: phosphor amber on near-black and a flat, text-only
shell after uint23's sxwm setup: no gaps, no borders, a solid `key: value` bar,
dmenu-style strips, a tty login as the lock screen. Lives in
`themes/oldschool/`; switch with `./theme oldschool`.

## The look

- **One phosphor.** Everything is amber (`fg`); `dim` is low-intensity
  text, `bright` is hot phosphor for small text accents, `red` is errors only. Selection is **reverse video**: an
  amber fill with `bg` text (focused workspace, picked menu item, active
  Ghostty and herdr tabs; herdr's `accent` is `fg`, not `bright`).
- **Flat and square.** `Box` is a panel rectangle with a 2px border; no
  rounding, shadows, blur or animations anywhere (Hyprland animations
  are off). Windows: no gaps and no borders, except a 2px `fg` outline on the
  floating terminals (drop-down and Files). When a workspace has more
  than one window, a 3px `fg` strip (`Focus.qml`) sits along the top of
  the focused one (not on the outlined floating terminals,
  where it would thicken the top edge).
- **Terminal.** Ghostty with 2px padding (balanced, padding takes the
  background colour), Terminus at 12.375pt (22 physical px), unhinted, as "Terminess Outline": a copy
  `hypr-theme/terminus-outline` makes (from `theme.sh`, once) of the
  installed `ttf-terminus-nerd` without its embedded bitmaps, so Ghostty
  smooths it like the shell instead of drawing the bitmaps pixel-sharp; ligatures off, and a steady
  block cursor in `fg` (not `bright`: a brighter-than-text cursor glares). Tabs are a flat text line with `|`
  separators, the current one in reverse video, in bold, in the shell's font and
  size from the font strip (`ui_font`/`ui_points` in `tabs.css.tmpl`), not
  the terminal's.
- **htop** uses its built-in Monochrome scheme (`htop/.config/htop/htoprc`,
  a theme stow package), so it draws in the terminal's amber with
  `#`/`*`/`|` meters. Changing settings in htop rewrites this file, in the
  repo.
- **btop** has square corners and block graphs, amber from `dim` up to
  `fg`, red only at the top of CPU, temperature and process graphs.
- **yazi** is amber on amber: reverse-video hover, `bright` directories,
  square ends (the preset's rounded caps clashed) and yazi's own Nerd Font
  icons with their colours stripped, so they're amber too. The icon list
  is copied from yazi's preset: re-copy it if a yazi update adds icons.
- **Text, not widgets.** Bar modules are `key: value`; progress is
  `[#########-----------]` (`Meter`); buttons are `[prev] [play] [next]`.
- **tty-isms.** Login and unlock warm the desktop up like a tube: it shows
  at once at a third, then two thirds, then full brightness (`Reveal.qml`;
  a CRT power-on with snow, a beam and a typed boot log before it was too
  much and dropped). Opening a scratchpad (`mod+S`, `mod+M`) warms up
  that screen the same way, a little faster; hiding one is instant. GTK
  animations are off too (`enable-animations false`, set by `theme.sh`),
  so Ghostty's tabs switch without sliding. Locking
  cuts straight to black, then the logo and prompt are drawn in like a
  slow scan (0.38s: 4px rows top to bottom, each left to right, by
  shrinking two `bg` masks). The wallpaper is the bare tube with the
  distro's fastfetch logo burned in: about 60% of the screen's height,
  centred, in `line` (barely brighter than the glass), in both modes. The
  lock screen is the distro's fastfetch logo, big and centred, over the
  user name and, centred under it, the password as `*`s (only the stars
  are centred; the blinking block trails them);
  a wrong one prints `Login incorrect` under it. Only the primary screen (the one at 0,0) shows it; the
  others are blank `bg`.
- **Terminus everywhere**, slightly smoothed: the terminal (12.375pt, 22
  physical px), the
  Quickshell UI (`Theme.fontPoints` 11.25pt, 20 physical, with
  `Text.NativeRendering`, slightly smoothed), GTK
  (11.25pt, also 20 physical) and hyprlock.
- **Or any monospace font.** `SUPER+SHIFT+F` opens a searchable `font`
  strip of Terminus plus every installed monospace family (`hypr-theme/font
  --list`: `fc-list` with `spacing=mono`, `lang=en` to drop emoji and
  SignWriting, which are tagged monospace), the current one pre-selected.
  The family is stored in `~/.local/state/oldschool-font`; `hypr-theme/font
  <family>` writes it and re-runs `theme.sh`, which renders it into
  `Theme.qml`, Ghostty's config and GTK. Terminus keeps its tuned sizes and
  unhinted outline copy; any other font is 10.5pt in the shell and GTK and
  12pt hinted in Ghostty, and JetBrains Mono (wide, tall x-height, so it
  looks bigger) 10 and 11.5pt. The shell and GTK change at once; Ghostty
  resizes open windows but only new ones get the new family.
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
| `comment` | `ac7a2c` | `7e6038` | editor comments: `dim` was too faded to read code comments in |
| `line` | `3d2810` | `cbb894` | the bar's underline, box edges |
| `bright` | `ffd27a` | `a85400` | small text accents only: the clock and hovered `[buttons]`. Fills and frames are `fg`: paler `bright` ones looked harsh next to `fg` |
| `red` | `ff5533` | `b8361a` | errors |

`blue`, `orange`, `yellow`, `green`, `cyan`, `purple` exist for the
terminal and editors only, warm-shifted. Cursor: the Windows 95 arrow (`xcursor-chicago95-git`, AUR) as
`Chicago95_Cursor_White_2x`, a copy `hypr-theme/cursor-2x` builds into
`~/.local/share/icons` (from `theme.sh`, once) with every pixel repeated
2x and 3x, in its own white and black (the script can tint it, e.g.
`cursor-2x <name> ffb52e`; amber was tried and dropped). It keeps the untinted originals in
`original/` beside the copy, so it still works if the package is removed. Chicago95 only ships 32px and nothing scales a cursor up, so
any size setting left it tiny. Where Chicago95 isn't installed there's no copy, and the
default cursor at size 32 is huge, so `theme.sh` falls back to Adwaita
at 24 (and `theme.lua` sizes its env from the theme name). GTK asks for size x2 at 1.33x (its
buffer scale), so size 48 drew the 96px copy at 64 physical: too big;
size 32 draws the 64px copy at ~43 physical.

## Login screen (optional, system-level)

`themes/oldschool/system/`, run by hand, never by `./theme`:
`sudo ./install-sddm` installs an SDDM theme that is the lock screen: the
distro's fastfetch logo (baked in at install, as the greeter can't run
fastfetch), the user, the password as `*`s with a blinking block, `Login
incorrect (n)` in `red`, and the scan-in. It renders `sddm/Main.qml.tmpl`
from the dark palette into `/usr/share/sddm/themes/oldschool` and sets
`Current=oldschool` in `/etc/sddm.conf` (backed up once as
`sddm.conf.oldschool-bak`). `sudo ./uninstall-sddm` restores it. Sizes are
physical pixels (SDDM runs unscaled), matching the lock's at 1.33x.

Rules for the greeter: each screen is a separate window with its own
state, so the prompt shows on whichever one SDDM focuses (`Window.active`;
the primary until one is), not just the primary, or typing lands on a blank
screen. A plain item needs `forceActiveFocus()` to get keys. Test mode has
no last user, so fall back to the first in `userModel`. Preview with
`sddm-greeter-qt6 --test-mode --theme <dir>` (logs go to the journal).

## Ideas, not done

- **Boot theme.** A GRUB theme from the palette (Terminus via
  `grub-mkfont`, reverse-video selection) plus the amber console through
  kernel options (`vt.default_red/grn/blu`, `fbcon=font:TER16x32`, the
  kernel's built-in Terminus) was tried and left boot broken, so it was
  removed. If revisited: test in a VM or with `grub-emu`/one-shot boot
  entries first, change one thing at a time, and keep the uninstall path.

## Quickshell

`themes/oldschool/quickshell/.config/quickshell/`, same IPC targets and
binds as zine ([zine-quickshell.md](zine-quickshell.md)).

| File | What |
|---|---|
| `Bar.qml` | A classic status line split by `\|`: workspaces (focused in reverse video), `> title`, then `mus` (click for the player), `vol` (click mutes, scroll changes), `bat` (laptops only: UPower's display device when it's a laptop battery; `+` charging, `bright` at 30%, `red` at 15%), `cpu`, `mem`, `net`, date, time |
| `Focus.qml` | The focused-window strip: an overlay layer placed from the window's `lastIpcObject` (refreshed once per window event in `shell.qml`); click-through |
| `Strip.qml` | dmenu-style strip over the bar: prompt in reverse video like the picked item (as dmenu), optional search field, matches in a row; arrows/Tab move, Enter picks, Esc closes, digits pick when not searchable |
| `Launcher.qml` | `run` strip over the desktop entries (`SUPER+Space`) |
| `FontMenu.qml` | Searchable `font` strip of monospace families from `hypr-theme/font --list` (`SUPER+SHIFT+F`); picking runs `hypr-theme/font <family>` |
| `PowerMenu.qml` | `session` strip: 1 lock, 2 suspend, 3 log out, 4 reboot, 5 shut down (`SUPER+Escape`) |
| `Osd.qml` | `v: 50% [##########----------]` box under the bar; `b:` for brightness |
| `Notifications.qml` | One log line each under the bar, top-right: `[HH:mm] app: summary - body` plus `[action]`s; red and sticky when critical; click dismisses |
| `MusicPopup.qml` | Track, artist · album, text progress bar, `[prev] [play] [next]` |
| `Lock.qml` | Logo (`Tty.logo`), user and masked password on the screen at 0,0; PAM `login`, identical to zine's |
| `Overview.qml` | Every window as a `WS CLASS TITLE` row, like `ps`; up/down/Tab, Enter focuses, Esc or a click outside closes (`SUPER+Tab`) |
| `Wallpaper.qml` | The burned-in logo (`Tty.logo`), sized to ~60% of the screen's height |
| `Special.qml` | `qs ipc call special toggle <name>` (from `hypr-theme/special`): blanks the focused screen with `Reveal`, dispatches the toggle 40ms later so the window never shows at full brightness first, then warms up (260ms). Hiding is a plain toggle. Tracks open scratchpads per monitor from `activespecialv2` |
| `Reveal.qml` | The warm-up: a `bg` overlay stepping 1, 2/3, 1/3, 0 opacity; on login once per Hyprland session (`$XDG_RUNTIME_DIR/oldschool-revealed` holds the instance signature, as the runtime dir outlives a logout) and after unlocking (`Lock` emits `leaving`); `play(delay, screen, ms)` limits it to one screen for `Special`; `qs ipc call reveal replay` |
| `Tty.qml` | Singleton: host (`/proc/sys/kernel/hostname`), kernel, user, distro (`/etc/os-release`) and logo (`fastfetch --pipe -s none`, any distro), read once; shared by the wallpaper and lock |
| `Blink.qml` | A block cursor's blink timer; consumers run it only while it's on screen (the lock only on the prompt's screen), as every toggle redraws the window |
| `Box.qml`, `Label.qml`, `Meter.qml` | Flat bordered box, text, text progress bar |
| `Stats.qml` | cpu, memory and network from `/proc` every 2s, paused while the bar is hidden |

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
  32 physical px for Terminus). Ghostty draws pt x 4/3 x the 1.33x scale
  (1.78 physical px per point), so its 20px size is 11.25pt and 22px 12.375pt; 15pt
  came out ~27px, bigger than the shell and smeared. Measure on a
  screenshot rather than trusting the arithmetic; in-between sizes smear strokes. `font-family` only
  applies to new windows; a reload changes the size of open ones.
- **Lock prompt lines are separate labels.** One centred text block
  re-centres every line as the password grows, so the user name jumped
  half a cell per key; each is its own label, centred at a rounded x so
  the pixel font stays sharp.
- **Qt's Terminus is a touch heavier than Ghostty's.** At 1.33x, Qt lays
  text out in logical units, so glyphs land on fractional physical pixels
  and antialiasing spreads a 1px stroke over two greyish ones (screenshot
  histograms show the greys; Ghostty's are pure on/off). Full hinting
  changes nothing visible; `antialiasing: false` snaps strokes to uneven
  pixels and is much harder to read; `CurveRendering` is thinner and
  closer to Ghostty but loses the slight smoothing, which is preferred.
  Live with it.
- **Ghostty draws a font's embedded bitmaps when it has them**, snapping
  to the nearest bitmap size, so no size or `freetype-load-flags` setting
  changes Terminus (`ttf-terminus-nerd` carries `EBDT`/`EBLC`): 21px drew
  exactly like 22px, and smoothing did nothing. Qt draws the outlines.
  Sharp Qt text at 20px on 1.33x isn't possible (7.5 logical px per
  character), so both sides smooth instead: `terminus-outline` drops the
  bitmap tables and renames the family. Ghostty's command-line options are
  overridden by the theme's `config-file`, so test with
  `--config-default-files=false`.
- **One IPC handler per target.** A handler in a per-screen component
  registers once per screen (even with `enabled: false`, or loaded only on
  the focused monitor, which races at startup) and warns on every reload;
  `shell.qml` owns the one `music` handler and bars react to its counter.
- **Snap sizes to physical pixels**, or 1px lines flicker in and out (at
  1.25 a 26px bar is 32.5 pixels). Inside a window use `Theme.px(value,
  dpr)` (the window's `devicePixelRatio`, or `QsWindow.window?.
  devicePixelRatio` from an item); it may be fractional. Window sizes and
  layer margins must also be whole logical pixels (a 26.25 bar is cut to
  26, its underline half outside), so use `Theme.whole(value, dpr)`: the
  next size up that's whole both ways (27 at 1.33, 28 at 1.25, 30 at 1.2).
- **Unhint the terminal font.** With Ghostty's default (light) hinting,
  Terminus at 22px snaps to the grid: dots and colons become thin slivers
  and edges come out near-sharp (121 grey levels on a test line against
  278 unhinted), though 20 and 21px stay smooth either way.
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
  If a `.qml` using a new property saved first, Quickshell has already
  reloaded against the old `Theme` and keeps it cached ("Unable to assign
  [undefined]" in `qs log`, the shell silently falls back): restart `qs`.
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
