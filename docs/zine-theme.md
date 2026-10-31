# The zine theme

Inspired by a zine-style web page: cream paper, black slabs, a grainy orange
banner, heavy type and hard shadows. Adapted into a neo-brutalist desktop:
rounded windows with ink outlines, and UI made of tilted paper scraps.

## Principles

- **Strict colour.** The UI uses neutrals plus one accent (orange). The
  other inks exist for terminal colours and for errors (red) only.
- **Scraps, not boxes.** UI elements are ragged quads, genuinely rotated a
  few degrees, each with a hard (unblurred) offset shadow in ink. Each has
  its own cut, so neighbours never match.
- **Tape** marks something as "stuck on": the launcher, the window title,
  urgent notifications, the album art photo, the lock screen field.
- **Motion pops.** Things overshoot and settle (`OutBack` easing), fast:
  roughly 200–260ms in, 130ms out.
- **Readable type.** One family, JetBrains Mono, bold for UI. Mixed
  typefaces were tried and dropped as hard to read.
- **Minimal lock screen.** Just a password field.

## Palette

Defined in `themes/zine/colorscheme/zine.toml`. Hex values:

| Role | Dark | Light | Used for |
|---|---|---|---|
| `bg` | `1f1c19` | `f1e6d6` | page, wallpaper base |
| `panel` | `2a2622` | `e8dbc7` | scraps: bar modules, launcher, popups |
| `surface` | `36312c` | `dccdb6` | hover, workspace shown on another monitor |
| `fg` | `ecdfcc` | `2a2420` | body text |
| `dim` | `8a7f70` | `8a7d6c` | secondary text, placeholders |
| `ink` | `0b0a09` | `2a2420` | outlines, hard shadows, text on light scraps |
| `paper` | `ecdfcc` | `fbf6ee` | light scraps in both modes (inactive workspaces, clock minutes, music) |
| `accent` | `e08a43` | `b9632a` | focus, active workspace, selection, tape, focused window shadow |
| `red` | `d9705f` | `b54a3c` | errors, critical load |

Riso inks (terminal only): `mustard`, `sage`, `teal`, `blue`, `rose`, `plum`.
The terminal background is darker than `bg` in dark mode (`161412`) so the
page around windows reads lighter.

The accent took many rounds: peachy (pink-leaning) and fully saturated
oranges were both rejected. Keep it yellow-leaning, moderately saturated.

## Window look (Hyprland)

8px inner / 16px outer gaps, 10px rounding, 2px ink border, a sharp 6px
offset shadow in the accent under the focused window only, 8% dimming of
unfocused windows.

## Wallpaper

Drawn live by Quickshell (`Collage.qml`, shown by `Wallpaper.qml` on the
background layer and reused by the lock screen). A collage on `bg`: grey
card, dark circle, orange banner with the hostname, pale tape strip, dim
halftone dots, each with an ink outline and hard ink shadow, plus tiled
paper grain (`grain.png`, the one image asset). Coordinates are on a
2560x1440 canvas scaled to fill each screen. Each piece (`Piece.qml`) drops
in from above with a twist, one after another, whenever the collage is
created: at login, on every light/dark switch (Quickshell reloads) and when
locking.
