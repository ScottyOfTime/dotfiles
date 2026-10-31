# CLAUDE.md

Personal dotfiles for an Arch + Hyprland desktop. Shared config is in
`base/`; each look is a theme in `themes/<name>/` switched with
`./theme <name>` (zine is current). Read `docs/README.md` first.

## Keep the docs current

Any change to behaviour, look, keybinds, files, packages or the theming
pipeline must update the matching file in `docs/` in the same commit. If a
change adds a new area, add a doc and link it from `docs/README.md`. Record
hard-won gotchas in the doc's rules section so they aren't relearned.

## Conventions

- Comments only for non-obvious config/code (arcane workarounds, gotchas).
  No narration or section banners.
- Practical changes (binds, rules, shell, editors) go in `base/`; anything
  about looks goes in the theme. Base must not bind keys a theme owns (see
  `docs/themes.md`).
- Zine colours come only from `themes/zine/colorscheme/zine.toml` →
  `build.py` → darkman templates. Never hard-code hex in configs; never
  edit generated files (`palette/*.env`, `ghostty-theme/themes/zine-*`,
  zine's herdr `config.toml` and `vim-theme` colours, anything with a
  `.tmpl`).
- The UI uses neutrals + the single accent; riso inks are for the terminal
  and red for errors.
- Quickshell: build UI from `Scrap`; animate with `NumberAnimation` +
  `OutBack`, never `SpringAnimation`; new `.qml` files need `qs` restarted.
- Hyprland config is Lua; `hyprctl dispatch` takes Lua expressions.
- New looks are new theme folders; experiment branches should only touch
  `themes/<name>/`. Commit with clear messages.
- Hyprland reloads on save: disable autoreload before moving live config
  files around (`docs/themes.md`).

## Verifying changes

- Check `hyprctl configerrors`, Quickshell's log, and screenshots
  (`grim -o <monitor>`) in both light and dark mode.
- Anything gating access (lock screen, PAM) must be verified to actually
  prompt for a password in a separate test instance before it's bound as
  the real lock; a wrong-password test proves nothing. Use
  `qs ipc call lock preview` for visual checks.
- Don't use `pkill -f` patterns that also match your own shell command line.
