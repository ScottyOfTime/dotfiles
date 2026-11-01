# Setup

## Packages

`pkglist.txt` (pacman) and `aur-pkgslist.txt` (AUR) are the shared set:
hyprland, hypridle, darkman, ghostty, playerctl, brightnessctl, wtype,
flameshot, ttf-jetbrains-mono, stow, … plus bibata-cursor-theme-bin.
Each theme lists its own in `themes/<name>/packages.txt`.

`system.sh` copies `sddm.conf` to `/etc` and enables the system services in
`services.txt` (run from anywhere; uses sudo).

## Install

```
cd ~/dotfiles
./install          # or ./install <theme>
```

`./install` first lists any packages from `pkglist.txt`, `aur-pkgslist.txt`
and the theme's `packages.txt` that aren't installed, with the command to
install them (it doesn't install anything itself). Then it links base and
the theme, builds the theme's colours and switches to it (`./theme`). Generated files aren't committed. See
[themes.md](themes.md). After that, `./theme <name>` switches looks.

Any real file already where a link should go (the default `~/.bashrc`,
Ghostty's first-run `config.ghostty`, …) is moved to `<file>.bak` first,
and the script prints each move. Compare them with the repo's versions
afterwards. This is the script's reason to exist: plain `stow` aborts the
whole command on one such file, so nothing is linked. Hyprland then
finds no config, fails to write a default one, and segfaults: SDDM
flashes black and returns to the login screen.

**Don't switch branches in the live checkout.** Everything in `~` links
into it, so `git checkout` swaps out the running config (Hyprland
autoreloads on the change). To work on another branch, use
`git worktree add <dir> <branch>`.

## Another machine

Monitors, workspace placement and autostarted apps are per machine:
`base/hypr/.config/hypr/hosts/<hostname>.lua` (hostname from
`/proc/sys/kernel/hostname`; `/etc/hostname` is missing on some systems).
The file may end with `return { autostart = { "app", ... } }`. A machine
without one gets one auto-scaled monitor, no pinned workspaces and only
the base autostart (theme shell, hypridle, a terminal). `hosts/scotty-laptop.lua` sets the laptop's 1920x1200
screen to 1.25 (auto picked 1.5, which made everything huge). To add
one, copy `hosts/scotty-desktop.lua`, rename it, and use `hyprctl monitors` for the output names. Check it with
`Hyprland --verify-config -c <file>`.

## Other distros

Arch is the target; elsewhere expect to do these by hand:

- **Packages.** `pkglist.txt`, `aur-pkgslist.txt` and each theme's
  `packages.txt` are Arch names, and `./install`'s missing-package check
  uses `pacman -T` (it stays quiet without pacman). Install the
  equivalents yourself.
- **Hyprland 0.56 or newer**, for the Lua config. Most distros lag Arch;
  an older Hyprland finds no config and segfaults at login. Quickshell,
  darkman, Ghostty and herdr may need a third-party repo or a build.
- **`system.sh`** assumes systemd and SDDM.

Already portable: the hostname (`/proc`), the distro name and logo
(`/etc/os-release`, fastfetch), the git prompt (`.bashrc` tries each
distro's path), and the theme scripts (fonts found through fontconfig,
cursors in `/usr/share/icons`).

Removing a package: `stow -D -d base -t ~ <name>` before deleting its folder,
or its `~/.config` symlink dangles.
