# Apps

## Ghostty

`base/ghostty/`: shared settings (cursor, font size, tabs at the bottom, no
decorations). It includes `~/.config/ghostty-theme/config` from the active
theme for colours, padding and tab CSS. Zine's tabs are square panel scraps,
each tilted a little (alternating, via GTK4 `transform: rotate`), with an
inner ink edge as the hard shadow; the active one is an accent scrap that
straightens. `box-shadow` can't be used: the tab's container clips it.
Unfocused windows grey their tab bar (GTK backdrop), so judge colours on a
focused window. Live-tweak with `GTK_DEBUG=interactive ghostty`.

## Bash prompt

`bash/.bashrc`:

```
[user@host:~/dir] (branch *+)
$
```

User blue, host magenta, dir yellow, git branch green (`*` unstaged,
`+` staged); `$` turns red after a failed command. ANSI colour names, so it
follows the terminal theme. `__git_ps1` is single-quoted inside `PS1` so a
branch name can't be executed.

`EDITOR` and `VISUAL` are nvim, or vim, or vi, whichever is installed
(yazi, git and others open files with it).

## Neovim

`nvim/`: lazy.nvim, airline, fzf, blink.cmp, zls. Colours come from the
active theme's `~/.config/vim-theme/theme.vim` (zine: the generated `zine`
colorscheme and airline theme; ayu: ayu-vim), with the background kept
transparent so the terminal's shows. `.vimrc` loads the same file.

Each theme's `theme.sh` writes the light/dark mode to
`~/.local/state/theme-mode`, which the colorschemes read at startup
(rather than calling `darkman get`). Open editors don't follow a switch on
their own; `:Theme` (defined in `.vimrc` and nvim's
`plugins/colorscheme.lua`) re-sources `theme.vim` and refreshes airline.

Don't call `system()` from vim at `VimEnter`: it hands the terminal back to
cooked mode just as Ghostty answers vim's startup queries, and the replies
(`;2R^[[3;1R^[[>1;10;0c^[]10;rgb:…`) get echoed over line 1. The block
cursor on start is set with `writefile(…, "/dev/tty")` instead. On exit
vim sends `\e[0 q`, which restores Ghostty's own `cursor-style` and blink
(themes may differ); a fixed shape there overrides the theme. nvim does
the same itself via terminfo's `Se`.

## Herdr

Its `config.toml` belongs to the theme (zine's is generated, with dark and
light colours and `auto_switch` following the terminal). Apply changes to a
running server with `herdr server reload-config`.

## Yazi

Only its colours are configured: each theme has `yazi/theme.toml.tmpl`,
rendered by the theme's darkman script from the palette (the accent for
hover, tabs and mode; `dim` borders; red for cut and errors). File types
use terminal colour names, so they follow the theme's terminal palette.
Yazi reads its theme at startup: after a mode change or `./theme`, restart
it. Everything else is yazi's defaults.

It's also the file manager: base's `yazi` package adds a `Files` desktop
entry (`com.scotty.files.desktop`, Ghostty running yazi), `install` makes it
the default for folders (`xdg-mime`), and `mod+E` opens it.

`Esc` closes it like a modal once there's nothing left to cancel
(selection, visual mode, find, filter, search): base's
`yazi/plugins/close.yazi` makes the same checks as yazi's `escape`, which
doesn't report whether it did anything. `install` creates
`~/.config/yazi` first, since base and the theme both put files there.

It's the file picker too: apps' open/save dialogs go through
`xdg-desktop-portal-termfilechooser` (AUR), which base's
`xdg-desktop-portal/hyprland-portals.conf` makes the FileChooser portal
(everything else stays hyprland, then gtk). Its config runs the packaged
`yazi-wrapper.sh` in the same `com.scotty.files` Ghostty, so the picker
floats in the centre like `mod+E`: Enter picks, Esc cancels. After changing
either file: `systemctl --user restart xdg-desktop-portal-termfilechooser
xdg-desktop-portal`. Apps that draw their own dialog keep it.

## Fastfetch

`fastfetch/`: default output, recoloured yellow via ANSI names. The modules
list must stay; without it fastfetch prints only the logo.

## Fonts and cursor

JetBrains Mono everywhere: `fontconfig/` maps `sans-serif`, `system-ui` and
`monospace` to it (Noto behind for missing glyphs), and darkman sets the
GTK fonts. Serif is untouched. Cursor: Bibata-Modern-Classic (AUR
`bibata-cursor-theme-bin`), set by the theme's palette `cursor`.
