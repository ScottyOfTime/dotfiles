# Quickshell

The whole zine shell UI is Quickshell (QML), in
`themes/zine/quickshell/.config/quickshell/`.
It replaced waybar, fuzzel, wob, mako, swaybg + the ImageMagick wallpaper
script and (as primary locker) hyprlock.
Started by the theme's `hypr-theme/start`, which runs `qs` in a loop that
restarts it if it crashes and keeps its stderr in `~/.local/state/qs.log`
(Qt's fatal errors only go there, never to `qs log`). `stop` kills the loop
(`$XDG_RUNTIME_DIR/qs-supervisor.pid`) and then `qs`; a clean `qs` exit
(status 0) also ends it. Oldschool uses the same scripts.

## Files

| File | What |
|---|---|
| `shell.qml` | Root: one `Bar` per screen, plus `Launcher`, `Osd`, `Notifications`, `Lock`, `PowerMenu`. `bar` IPC toggle |
| `Scrap.qml` | The building block (below) |
| `Wallpaper.qml` | Background-layer window per screen showing `Collage` |
| `Collage.qml` | The wallpaper collage; `Piece.qml` (drop-in animation) and `Poly.qml` (outlined polygon with hard shadow) build it; `grain.png` is the tiled paper grain |
| `Label.qml` | Text in the theme font, bold, ink by default |
| `Theme.qml.tmpl` | Palette singleton, rendered by darkman (`Theme.qml` is generated) |
| `Stats.qml` | CPU / memory / network from `/proc` every 2s, paused while the bar is hidden |
| `Bar.qml` | Workspaces, window title, collage clock, music, volume, cpu, mem, net |
| `MusicPopup.qml` | Album art "photo", track info, progress, prev/play/next |
| `Launcher.qml` | App search on one scrap, rises from the bottom edge |
| `Osd.qml` | Volume (from Pipewire) and brightness (over IPC) popup |
| `Notifications.qml` | Notification server; scraps stacked top-right |
| `Lock.qml` | Session lock: live collage + password scrap (kicks a little on every key press; on success turns orange, says "unlocked" and falls away before the session unlocks), PAM `login` |
| `Overview.qml` | `SUPER+Tab`: every window as a live-captured tilted "photo", grouped by workspace; arrows/Tab/hover pick, Enter/click focuses, Esc closes |
| `PowerMenu.qml` | Dimmed overlay with lock / suspend / log out / reboot / shut down scraps; arrows or 1–5, Enter, Esc |

## Scrap

```qml
Scrap {
    fill: Theme.panel   // background colour (default Theme.paper)
    tilt: -3            // rotation in degrees, animated
    seed: 21            // picks the ragged cut; different seed = different shape
    ragged: 2.5         // corner jitter in px
    shadow: 3           // hard shadow offset in ink
    padX: 12; padY: 5
    tape: true; tapeWidth: 30
    supersample: false  // render content at 3x then rotate: antialiases
                        // straight/clipped lines inside (used by the launcher)
    onClicked: ...      // also: wheeled(event), hovered (bool)
    Label { text: "content" }
}
```

Give every scrap its own `seed`; tilts alternate sign between neighbours.

## IPC

| Command | Does |
|---|---|
| `qs ipc call launcher toggle` | `SUPER+Space` |
| `qs ipc call bar toggle` | `SUPER+B` |
| `qs ipc call lock lock` | `SUPER+L`, hypridle |
| `qs ipc call lock preview` | locks for 6s then unlocks itself; safe way to look/test |
| `qs ipc call osd brightness <0-100>` | brightness keys |
| `qs ipc call music toggle` | music popup on the focused monitor |
| `qs ipc call power toggle` | `SUPER+Escape` |
| `qs ipc call overview toggle` | `SUPER+Tab` |

## Rules learned the hard way

- **No `SpringAnimation`.** It steps at a fixed 60Hz internally and judders
  on these 100Hz monitors. Use `NumberAnimation` with `Easing.OutBack`.
- **Brand-new `.qml` files need a restart** (`pkill qs; qs &`); edits to
  existing files hot-reload.
- **Clickable things inside a scrap work** because Scrap's own MouseArea sits
  beneath its content. Keep it that way.
- **Read `/proc` synchronously** (`FileView { blockLoading: true }`), or the
  first reload comes back empty.
- **`Hyprland.toplevels` is empty until `Hyprland.refreshToplevels()`**, and
  its addresses lack the `0x` Hyprland's `address:` selector needs.
- **Qt's JS lacks some newer builtins** (e.g. `Object.fromEntries`).
- **`expireTimeout` is milliseconds**, as the spec sends it; multiplying by
  1000 left notifications with their own timeout (e.g. Flameshot) up for an hour.
- **Notification bodies are plain text** (`bodyMarkupSupported: false`).
- **Lock screen PAM** uses the system `login` config. A custom
  `configDirectory` makes `include` lines resolve inside it and fail every
  attempt; that once locked the user out. Verify any PAM change in a
  separate instance that aborts at the "Password:" prompt, and check
  `journalctl` for PAM errors. Unexpected PAM errors show as
  "auth broken" on the lock screen rather than "wrong password".

- **`qs` can die when every monitor disconnects.** On DPMS off both DP
  monitors drop off the bus (DP deep sleep), Hyprland briefly has no
  outputs, and `qs` has exited silently there (no core dump), taking the
  lock with it. `Lock.qml` writes `locked` to `$XDG_RUNTIME_DIR/qs-locked`
  while the session is locked and relocks on startup if it's set, so the
  restarted `qs` takes the lock back over (`allow_session_lock_restore`).
  `lockNow()` and the unlock timer write the marker (`locked` /
  `unlocked`) themselves: written from `WlSessionLock.onLockedChanged`,
  the unlock never reached the file, it stayed `locked`, and the next
  reload or restart (even editing a `.qml` file) locked the session.
  The cause is in `~/.local/state/qs.log` next time.
- **Find a screen's Hyprland monitor by name.** `Hyprland.monitorFor(screen)`
  keeps a dead object after the monitors disconnect and come back, so a
  bar's workspace filter stopped matching and the left bar showed none.
  `Bar.qml` and `Focus.qml` look it up in `Hyprland.monitors` by name,
  which re-resolves. Turning off DP deep
  sleep in the monitors' menus avoids the disconnect.

## Recovery if the lock breaks

`allow_session_lock_restore` is on in Hyprland. From a TTY
(`Ctrl+Alt+F2`): `hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("hyprlock -c ~/.config/hypr-theme/hyprlock.conf")'`
and unlock with hyprlock, which stays installed and themed for this.
