# Theming pipeline

One source of colour, rendered into every app on each light/dark switch.

```
themes/zine/colorscheme/zine.toml
   │  ./themes/zine/colorscheme/build.py
   ├─▶ palette/.config/palette/{dark,light}.env      (hex without '#')
   ├─▶ ghostty-theme/.config/ghostty-theme/themes/zine-{dark,light}
   ├─▶ herdr/.config/herdr/config.toml               (both modes, auto_switch)
   └─▶ vim-theme/.config/vim-theme/colors/zine.vim + airline theme
                                                     (both modes, picked via darkman get)
            │
   darkman runs ~/.local/share/darkman/theme.sh <mode>
            │  envsubst each *.tmpl with that mode's palette
            ├─▶ quickshell/Theme.qml   (quickshell hot-reloads it)
            ├─▶ hypr-theme/colors.lua    (hyprctl reload)
            ├─▶ hypr-theme/hyprlock.conf (fallback locker)
            ├─▶ ghostty-theme/tabs.css   (ghostty gets SIGUSR2)
            ├─▶ ghostty-theme/config     (theme paths need ${HOME})
            └─▶ gsettings: color-scheme, accent, cursor, fonts
```

## Changing a colour

1. Edit `themes/zine/colorscheme/zine.toml`.
2. Run `./themes/zine/colorscheme/build.py`.
3. Run `~/.local/share/darkman/theme.sh $(darkman get)` (or toggle with `SUPER+T`).

Never edit `palette/*.env`, `ghostty-theme/themes/zine-*`, herdr's
`config.toml` or the `vim-theme` colours by hand; they're
generated and say so at the top.

The accent is also the fallback in `hyprland.lua` (used before darkman has
run once); keep it in sync when the accent changes.

## Templates

A template is `<file>.tmpl` beside the generated `<file>`. `theme.sh` lists
them in its `for f in ...` loop; generated files are in `.gitignore`.

Gotchas:

- `envsubst` only replaces the palette's own variable names (and `$HOME`), so app
  variables like hyprlock's `$ATTEMPTS` survive. Don't name your own
  template variables after palette roles (`$bg`, `$fg`, ...): they'll be
  replaced. This broke hyprlock once.
- hyprlang treats `#` as a comment, so colours in hyprlock markup are
  written `##${accent}`.
- Generated headers say `edit the .tmpl`.

## Theming a new app

1. Write `<config>.tmpl` using `${role}` (hex without `#`).
2. Add its path to the loop in `themes/zine/darkman/.local/share/darkman/theme.sh` and
   the generated file to `.gitignore`.
3. Add whatever reload the app needs at the end of `theme.sh`.
4. Document it here and in the relevant doc.
