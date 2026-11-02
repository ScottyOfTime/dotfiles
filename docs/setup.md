# Setup

## Packages

`pkglist.txt` (pacman) and `aur-pkgslist.txt` (AUR) are the shared set:
hyprland, hypridle, darkman, ghostty, playerctl, brightnessctl, wtype,
flameshot, ttf-jetbrains-mono, stow, … plus bibata-cursor-theme-bin.
Each theme lists its own in `themes/<name>/packages.txt`.

`system.sh` copies `sddm.conf` to `/etc` and enables the system services in
`services.txt` one by one, listing any that failed (run from anywhere; uses
sudo).

`debian-pkgs.txt` maps the Arch names to Debian/Ubuntu ones for `./install`
(see below). Adding a package whose apt name differs, or that isn't in apt,
means adding a line there too.

## Install

```
cd ~/dotfiles
./install          # or ./install <theme>
```

`./install` first lists any packages from `pkglist.txt`, `aur-pkgslist.txt`
and the theme's `packages.txt` that aren't installed, with the command to
install them (`pacman`/`yay`, or `apt` on Debian/Ubuntu; it doesn't install
anything itself), and warns if Hyprland is missing or older than 0.56. Then it links base and
the theme, builds the theme's colours and switches to it (`./theme`). Generated files aren't committed. See
[themes.md](themes.md). After that, `./theme <name>` switches looks.

Any real file already where a link should go (the default `~/.bashrc`,
Ghostty's first-run `config.ghostty`, …) is moved to `<file>.bak` first,
and the script prints each move. Compare them with the repo's versions
afterwards. This is the script's reason to exist: plain `stow` aborts the
whole command on one such file, so nothing is linked. Hyprland then
finds no config, fails to write a default one, and segfaults: SDDM
flashes black and returns to the login screen. Links into this repo
(another theme's, when installing a different one) are left for `./theme`
to swap; moving them would back up a whole folded `~/.local`.

**Don't switch branches in the live checkout.** Everything in `~` links
into it, so `git checkout` swaps out the running config (Hyprland
autoreloads on the change). To work on another branch, use
`git worktree add <dir> <branch>`.

## Another machine

Nothing to set up for the screens: `hyprland.lua` scales each monitor from
its pixel density (rows / physical height), aiming at 81 logical ppi for
external monitors and 140 for laptop panels (`eDP`, `LVDS`, `DSI`), which
sit nearer the eyes; it picks the nearest scale that divides the mode
evenly (others blur), and screens that report no size get Hyprland's
`auto`. That gives the desktop's 108ppi monitors 1.33 and a 14" 1920x1200
laptop 1.2 (1.25 and 1.5 looked too big there). It runs at config load, on
`hyprland.start` and when a monitor is added.

`base/hypr/.config/hypr/hosts/<hostname>.lua` (hostname from
`/proc/sys/kernel/hostname`) is optional, for extras only: workspace
pinning, window rules, `hl.monitor` overrides (it loads after the
scaling), and it may end with `return { autostart = { "app", ... } }`.
Without one a machine gets the base autostart (theme shell, hypridle, a
terminal). Check one with `Hyprland --verify-config -c <file>`.

## Without Hyprland (GNOME etc.)

`./install` and `./theme` only link packages whose app is installed, so
on a GNOME machine you get the shell, editors, Ghostty and its theme
colours, and nothing for Hyprland. `links.sh` holds the package → command
map (`needs()`); packages not in it (`bash`, `palette`, `darkman`) always
link. `fontconfig` counts as Hyprland's: it remaps `sans-serif` and
`monospace` for every app. Hyprland older than 0.56 counts as missing:
without our config it runs its own default instead of segfaulting.

Anything already linked whose app is missing gets unlinked, and both
lists are printed (`unlinked hypr (no Hyprland 0.56+)`, `not linked: …`).
Rerun `./install` after installing or removing an app to bring the links
in line. yazi isn't made the folder handler without Hyprland.

On GNOME the theme's `gnome` package restyles the shell and GTK apps from
the palette and sets its fonts, cursor and wallpaper: see
[gnome.md](gnome.md). Without Hyprland or GNOME the desktop's look is left
alone, and only Ghostty takes the theme.

## Debian and Ubuntu

`./install` checks packages with `dpkg-query` when there's no pacman,
renaming through `debian-pkgs.txt`, and prints an `apt install` line plus
the ones apt doesn't have (anything `apt-cache` can't find counts too, so
an older release shows more). Those need getting by hand:

| Package | Where from |
|---|---|
| **Hyprland 0.56+** | apt's is far older and can't read the Lua config (it finds none and segfaults at login; `./install` warns). Build from source or use a third-party repo, then hypridle/hyprlock from the same place if apt lacks them |
| quickshell (zine, oldschool) | build from source (quickshell.org) |
| ghostty | ghostty.org lists the community `.deb`s |
| fastfetch | in apt from Debian 13 / Ubuntu 25.04; older: the GitHub `.deb` |
| Terminess Nerd Font (oldschool) | `Terminus.zip` from the Nerd Fonts releases, unzipped into `~/.local/share/fonts`, then `fc-cache` |
| Chicago95 cursor (oldschool) | the Chicago95 repo's `Cursors/Chicago95_Cursor_White` into `~/.local/share/icons` (`cursor-2x` looks there, `~/.icons` and `XDG_DATA_DIRS`); without it the theme falls back to Adwaita |
| Bibata cursor (zine, ayu) | the release tarball into `~/.local/share/icons` |
| brave, obsidian, migrate, where-is-my-sddm-theme | their own `.deb`s/repos; all optional |

`system.sh` works too: units that don't exist (`systemd-userdbd.socket`
without the `systemd-userdbd` package) are reported, not fatal. Ubuntu
desktop already has gdm3 as `display-manager.service`, so `sddm` fails to
enable; `sudo dpkg-reconfigure sddm` switches it.

Already portable: the hostname (`/proc`), the distro name and logo
(`/etc/os-release`, fastfetch), the git prompt (`.bashrc` tries each
distro's path), and the theme scripts (fonts found through fontconfig,
cursors in any icon dir). Other distros: the same list applies, but
`./install` stays quiet about packages without pacman or dpkg.

Removing a package: `stow -D -d base -t ~ <name>` before deleting its folder,
or its `~/.config` symlink dangles.
