# billy

2000s punk, low tech, graffiti: the distro's logo sprayed on a bare
wall, and a shell made from label-maker tape, spray paint, photocopies
and duct tape. Lives in `themes/billy/`; switch with `./theme billy`.
The colour pipeline is zine's ([zine-pipeline.md](zine-pipeline.md)):
`colorscheme/billy.toml` → `build.py` → darkman templates. The shell is
its own.

## The look

- **One can of paint.** The UI uses the neutrals and the hot pink
  `accent`. `acid` (the terminal's green) appears only in the
  wallpaper's overspray; `red` is errors, high load and a wrong password.
- **Low tech motion.** Things go up in hard steps instead of gliding:
  `Coat` shows its contents in three opacity steps, the launcher moves
  in four, the power menu's words go up one at a time, sprays come on in
  three coats. There's no `OutBack`, no overshoot. Hyprland's curves are
  short and straight, with no shadow, blur or dimming. Windows are square
  with a 3px border: `accent` when focused, `surface` otherwise.
- **Wallpaper (`Wall.qml`, also the lock's background).** The logo
  named by `/etc/os-release`'s `LOGO` (`/usr/share/pixmaps/<LOGO>.svg`,
  else the icon theme), about half the screen's height, tilted 4°, on a
  plain `bg` wall with photocopier grain. It's built from the logo's own
  shape (`Silhouette`), so any distro gets the same treatment:
  - an ink then paper **cloud outline** (the shape grown by blurring it
    and keeping everything above a low threshold);
  - a **3D block** of offset copies in a darkened accent;
  - a **two-tone face**: light pink fading into the accent, then a hard
    split into a darker pink below the middle;
  - **drips**: narrow vertical strips of the shape stretched downwards,
    so each run starts at the shape's lower edge in its column;
  - pink and acid **overspray** specks, and a small marker tag in the
    corner.
- **Bar (`Bar.qml`).** No bar, just label-maker strips (`Dymo`) stuck on
  the wall: workspaces as `01`, `02` (the focused one with pink letters
  and a spray of pink behind; one shown on another monitor on `surface`
  tape), the window title on white tape, the time on pink tape, then the
  date, the player, `vol`, `cpu`, `mem` and `net`.
- **Launcher (`SUPER+Space`).** A photocopied sheet taped up from the
  bottom edge, with the pick marked by a pink highlighter.
- **Power menu (`SUPER+Escape`).** Lock, sleep, log out, reboot and shut
  down stencilled across a darkened screen; the pick gets a spray of pink
  with drips. Keys 1–5, arrows, Enter.
- **OSD.** Volume and brightness as tally marks on a scrap of paper, one
  per 5%, with the fifth stroke of each group in pink (red past 100%).
- **Music popup.** A cassette: the track in marker on the label, the art
  stuck on it, reels that turn in 30° clicks while it plays, label-tape
  buttons underneath.
- **Notifications.** Taped-up photocopies, top right; critical ones get
  a spray of pink and stay until clicked.
- **Lock.** The wall, with `password` on label tape and the password
  punched out as `*`s below it; every key jolts the tape sideways. A
  wrong password turns the prompt into red `wrong xN` tape. On success
  the tape peels off in steps and the session unlocks. Same PAM and
  crash-relock logic as zine ([zine-quickshell.md](zine-quickshell.md)).
- **Ghostty** tabs are label tape: black strips, the current one pink.

## Components

| File | What |
|---|---|
| `Dymo.qml` | label-maker tape: raised capitals (`Text.Raised`), scissor-cut ends from `seed`; `hot` sprays the accent behind it |
| `Spray.qml` | a spray-painted patch: overlapping blurred bursts, overspray specks, drips |
| `Coat.qml` | shows its children in three hard steps, `order` beats after it's created |
| `Tape.qml` | a strip of duct tape |
| `Silhouette.qml` | a fill (colour or gradient) cut out by a mask, with a threshold |
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
- **Fonts.** JetBrains Mono for tape and stencils, Liberation Sans (bold,
  italic) as the marker hand; without `ttf-liberation` Qt falls back to
  another sans.
