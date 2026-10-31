# CLAUDE.md

Personal dotfiles for an Arch + Hyprland desktop themed "zine". Read
`docs/README.md` first; `docs/` describes the theme, pipeline and every
component.

## Keep the docs current

Any change to behaviour, look, keybinds, files, packages or the theming
pipeline must update the matching file in `docs/` in the same commit. If a
change adds a new area, add a doc and link it from `docs/README.md`. Record
hard-won gotchas in the doc's rules section so they aren't relearned.

## Conventions

- Comments only for non-obvious config/code (arcane workarounds, gotchas).
  No narration or section banners.
- Colours come only from `colorscheme/zine.toml` → `build.py` → darkman
  templates. Never hard-code hex in configs; never edit generated files
  (`palette/*.env`, `ghostty/themes/zine-*`, anything with a `.tmpl`).
- The UI uses neutrals + the single accent; riso inks are for the terminal
  and red for errors.
- Quickshell: build UI from `Scrap`; animate with `NumberAnimation` +
  `OutBack`, never `SpringAnimation`; new `.qml` files need `qs` restarted.
- Hyprland config is Lua; `hyprctl dispatch` takes Lua expressions.
- Work on a branch for experiments; commit with clear messages.

## Verifying changes

- Check `hyprctl configerrors`, Quickshell's log, and screenshots
  (`grim -o <monitor>`) in both light and dark mode.
- Anything gating access (lock screen, PAM) must be verified to actually
  prompt for a password in a separate test instance before it's bound as
  the real lock; a wrong-password test proves nothing. Use
  `qs ipc call lock preview` for visual checks.
- Don't use `pkill -f` patterns that also match your own shell command line.
