# GNOME

On a GNOME machine without Hyprland (Ubuntu), each theme restyles GNOME
instead of replacing it: same palette, fonts and cursor, GNOME's layout.
Written against GNOME Shell 46 (Ubuntu 24.04).

## What changes

| Part | How |
|---|---|
| Top bar, menus, quick settings, calendar, notifications, OSD, dialogs, alt-tab, dock | A stylesheet loaded on top of the session's shell theme (Yaru on Ubuntu) by our extension `dotfiles-look@scotty` |
| GTK 4 / libadwaita apps (Files, Settings, Text Editor, …) | `~/.config/gtk-4.0/gtk.css` redefines libadwaita's named colours |
| Fonts, cursor, dark mode, animations | `gsettings`, as on Hyprland |
| Wallpaper | A solid palette `bg` (`org.gnome.desktop.background`); zine's collage is drawn by Quickshell, so there's no GNOME equivalent |
| Ghostty, editors, yazi, btop | Unchanged: their theme packages work anywhere |

Shapes follow the theme: zine's floating surfaces are square with a 2px ink
outline and a hard 4px ink shadow, oldschool's square and flat with a 1px
`line` border and selection in reverse video, ayu keeps GNOME's shapes.

## Files

Each theme has a `gnome/` stow package, linked only where `gnome-shell` is
installed (`needs()` in `links.sh`):

```
gnome/.local/share/gnome-shell/extensions/dotfiles-look@scotty/
    metadata.json  extension.js  stylesheet.css.tmpl
gnome/.config/dotfiles-gnome/gtk.css.tmpl
gnome/.config/gtk-4.0/gtk.css          @import of ../dotfiles-gnome/gtk.css
```

The theme's `theme.sh` sees the linked extension, applies the `gsettings`
and runs `gnome-look <mode>` (repo root), which renders both templates
from the palette, sets the wallpaper, turns user extensions on, adds ours
to `org.gnome.shell enabled-extensions` (so the shell enables it by itself
when it finds it at login) and cycles it (disable, enable) so the shell
rereads the stylesheet. If enabling fails it prints `gnome-extensions`'
own error and `gnome-extensions info`.

## First run

1. `./install <theme>` (or `./theme <theme>`). It ends with "GNOME hasn't
   seen the dotfiles-look@scotty extension yet": on Wayland the shell only
   scans for new extensions at login.
2. Log out and back in, then `./theme <theme>` once more. From then on
   switching themes or modes restyles the shell immediately.
3. Restart open GTK apps to pick up their colours (GTK reads `gtk.css` at
   startup).

Dark/light follows darkman (`darkman toggle`, or its schedule), which
reruns `theme.sh`. GNOME's own Dark Style toggle only flips GTK's
`color-scheme`, not our colours: use darkman instead.

## Rules

- **Override, don't replace.** A User Themes shell theme replaces the whole
  stylesheet, so it has to restyle everything and breaks with each GNOME
  release; an extension's `stylesheet.css` is loaded on top of the current
  theme with higher priority, so ours only sets what differs.
- **`metadata.json` lists `"shell-version": ["46"]`.** After a GNOME upgrade
  the shell refuses the extension until the new version is added (and
  selectors may need checking: the shell's CSS changes between releases).
- **GTK colours go through a folded directory.** `gtk-4.0/` must be a real
  folder (GTK and apps write there), so the rendered colours live in
  `~/.config/dotfiles-gnome`, a link into the theme, and `gtk.css` only
  imports them. Rendered straight into `gtk-4.0` they'd survive unlinking
  the theme. `./theme` creates `gtk-4.0` and the `extensions` folder
  before stowing so neither gets folded into the repo.
- **No accent through `gsettings` on 46.** `accent-color` is GNOME 47+; the
  stylesheet and `gtk.css` carry the accent instead.
- **GTK 3 apps aren't recoloured.** Adwaita's GTK 3 theme doesn't read
  named colours for its own widgets; most GNOME 46 apps are GTK 4.
- **Untested on a live GNOME here**: the GTK CSS parses with GTK 4, the
  shell CSS was written against GNOME 46's selectors but not seen
  rendered. Check `journalctl --user -b | grep -i dotfiles-look` for
  stylesheet errors, and screenshot both modes.
