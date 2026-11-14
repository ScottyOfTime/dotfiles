# billy

2000s punk, low tech, graffiti: a brick wall bombed edge to edge (a
BILLY piece, the distro's logo as a second piece, a throw-up, stencils,
tags), and a shell of black gaffer tape written on in paint marker, with
spray paint, label-maker tape and a mixtape. Nothing leaves gaps: the bar
runs edge to edge along the top and windows tile with no gaps. Lives in
`themes/billy/`; switch with `./theme billy`.
The colour pipeline is zine's ([zine-pipeline.md](zine-pipeline.md)):
`colorscheme/billy.toml` → `build.py` → darkman templates. The shell is
its own.

## The look

- **One can of paint in the UI, two on the wall.** The UI uses the
  neutrals and the hot pink `accent`. The wallpaper also sprays `acid`
  (the terminal's green: the BILLY piece, stencils, splats); `red` is
  errors, high load and a wrong password.
- **Straight, flat, unshadowed.** Nothing in the shell is tilted and
  nothing casts a shadow (zine's scraps do both): tape is stuck on
  square, and writing is the decoration.
- **Low tech motion.** Things go up in hard steps instead of gliding:
  `Coat` shows its contents in three opacity steps, the launcher moves
  in four, the power menu's words go up one at a time, sprays come on in
  three coats. There's no `OutBack`, no overshoot. Hyprland's curves are
  short and straight, with no shadow, blur or dimming. Windows are square
  and tile with no gaps, with a 2px border: `accent` when focused,
  `surface` otherwise.
- **Wallpaper (`Wall.qml`, also the lock's background).** A brick wall
  on a 2560x1440 canvas scaled to fill, with every part of it painted:
  - the oldest layer: grey buffed-over patches and faded tags;
  - big soft splats of pink and acid with drips;
  - stencils (stars, `PUNX NOT DEAD`) with overspray;
  - a throw-up: `PNX` in chrome bubble letters, a fat ink outline and a
    pink ring;
  - the **BILLY piece** (`Glyph`): hand-built blocky letters, leant
    forward, with a paper cloud outline, a 3D block, a two-tone acid face,
    shines, fat drips and an acid crown;
  - the **distro's logo** as a pink piece (`LogoPiece`, below);
  - scrawls (an arrow, a squiggle, a heart, crosses, an underline) and
    marker tags on top. Tags that should stand out are `fg`, so they read
    in both modes.

  `LogoPiece` takes the logo named by `/etc/os-release`'s `LOGO`
  (`/usr/share/pixmaps/<LOGO>.svg`, else the icon theme) and builds
  everything from the logo's own shape (`Silhouette`), so any distro gets
  the same treatment:
  - an ink then paper **cloud outline** (the shape grown by blurring it
    and keeping everything above a low threshold);
  - a **3D block** of offset copies in a darkened accent;
  - a **two-tone face**: light pink fading into the accent, then a hard
    split into a darker pink below the middle;
  - **drips**: narrow vertical strips of the shape stretched downwards,
    so each run starts at the shape's lower edge in its column;
  - pink and acid **overspray** specks.
- **Bar (`Bar.qml`).** Gaffer tape run along the top edge, edge to edge
  and flush (no margins, no torn ends), written on in white paint marker: the workspaces (the focused one
  circled in pink, drawn in four strokes, overshooting where it closes;
  one shown on another monitor underlined), the window title, the time
  in pink and the date in the middle, then the player, `vol`, `cpu`,
  `mem` and `net` split by `x`s.
- **Launcher (`SUPER+Space`).** A slab of gaffer tape stuck up from the
  bottom edge, written on in marker; the pick is a stripe of pink.
- **Power menu (`SUPER+Escape`).** Lock, sleep, log out, reboot and shut
  down stencilled across a darkened screen; the pick gets a spray of pink
  with drips. Keys 1–5, arrows, Enter.
- **OSD.** Volume and brightness as tally marks in marker on gaffer tape,
  one per 5%, with the fifth stroke of each group in pink (red past 100%).
- **Music popup.** A cassette: the track in marker on the label, the art
  stuck on it, reels that turn in 30° clicks while it plays, label-tape
  buttons underneath.
- **Notifications.** Strips of gaffer tape, top right, the summary in
  marker; critical ones are written in pink over a spray of pink and stay
  until clicked.
- **Lock.** The wall, with `password` on label tape and the password
  punched out as `*`s below it; every key jolts the tape sideways. A
  wrong password turns the prompt into red `wrong xN` tape. On success
  the tape peels off in steps and the session unlocks. Same PAM and
  crash-relock logic as zine ([zine-quickshell.md](zine-quickshell.md)).
- **Ghostty** tabs are label tape: black strips, the current one pink.

## Components

| File | What |
|---|---|
| `Gaffer.qml` | black gaffer tape: torn ends, a cloth weave |
| `Marker.qml` | paint-marker writing (Liberation Sans, black italic) |
| `Scribble.qml` | a hand-drawn loop, drawn in in four strokes |
| `Dymo.qml` | label-maker tape (lock, power menu keys, buttons): raised capitals (`Text.Raised`), scissor-cut ends from `seed`; `hot` sprays the accent behind it |
| `Spray.qml` | a spray-painted patch: overlapping blurred bursts, overspray specks, drips |
| `Coat.qml` | shows its children in three hard steps, `order` beats after it's created |
| `Silhouette.qml` | a fill (colour or gradient) cut out by a mask, with a threshold |
| `Glyph.qml` | one letter of the BILLY piece, from polygons on a 220-high grid |
| `LogoPiece.qml` | the distro's logo as a piece |
| `Wall.qml` | the wallpaper and lock background |

## Rules

- **Shape effects come from blurring a mask and thresholding it.**
  `Silhouette` keeps the mask's pixels above `threshold`. The logo blurred
  a little and cut at 0.5 drops its thin details (Arch's ™ sign turned
  into jagged noise in the outline); that shape blurred a lot and cut low
  grows into a smooth cloud outline. Growing the outline from offset
  copies instead leaves a saw-tooth edge.
- **Don't read pixels back from a `Canvas` for this.** Canvas draws an SVG
  file at its own scale, so the points didn't line up with the `Image`.
  On the lock surface a grab's `itemgrabber:` URL never loads, and an
  invisible canvas never paints. Drips are stretched strips of the shape
  instead: no pixel reading.
- **Give flat-colour layers a tiny texture.** Each `Silhouette` layers its
  fill; at full size, dozens of them for the outline and the block would
  cost a texture each the size of the logo. `layer.textureSize` is 2x2
  unless it's the gradient face.
- **The logo needs room for its blur.** The masks have
  `autoPaddingEnabled: false` so they line up with the logo, so the logo
  sits inside a margin of the piece (20% of its size) or the cloud is cut
  off at the edges.
- **On the tape, use faded `paper`, not `dim`.** The tape is `ink` in
  both modes, and light mode's `dim` is too dark to read on it.
- **Test it hidden, in a nested Hyprland.** Start `Hyprland -c` on a
  config holding only the theme's `theme.lua` (not base's, whose autostarts
  would start a second shell). Your session needs a window rule that sends
  class `aquamarine` to a special workspace, silently, with no initial
  focus. Then in the nested instance (`hyprctl --instance <sig>`), `output
  create headless` and `output remove WAYLAND-1`: it keeps running on the
  headless output only, with no window in your session. Run `qs -p`,
  `grim -o`, `wtype` and apps there with its `WAYLAND_DISPLAY` and
  `HYPRLAND_INSTANCE_SIGNATURE`; input stays inside it. The lock marker
  in `$XDG_RUNTIME_DIR` is shared with the real session, so only use
  `preview`.
- **Fonts.** JetBrains Mono for label tape and stencils, Liberation Sans
  (black italic) as the marker hand; without `ttf-liberation` Qt falls back to
  another sans.
