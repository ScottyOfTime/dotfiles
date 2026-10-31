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

## Neovim

`nvim/`: lazy.nvim, airline, fzf, blink.cmp, zls. Colours come from the
active theme's `~/.config/vim-theme/theme.vim` (zine: the generated `zine`
colorscheme and airline theme; ayu: ayu-vim), with the background kept
transparent so the terminal's shows. `.vimrc` loads the same file.

Don't call `system()` from vim at `VimEnter`: it hands the terminal back to
cooked mode just as Ghostty answers vim's startup queries, and the replies
(`;2R^[[3;1R^[[>1;10;0c^[]10;rgb:…`) get echoed over line 1. The block
cursor on start is set with `writefile(…, "/dev/tty")` instead.

## Herdr

Its `config.toml` belongs to the theme (zine's is generated, with dark and
light colours and `auto_switch` following the terminal). Apply changes to a
running server with `herdr server reload-config`.

## Fastfetch

`fastfetch/`: default output, recoloured yellow via ANSI names. The modules
list must stay; without it fastfetch prints only the logo.

## Fonts and cursor

JetBrains Mono everywhere: `fontconfig/` maps `sans-serif`, `system-ui` and
`monospace` to it (Noto behind for missing glyphs), and darkman sets the
GTK fonts. Serif is untouched. Cursor: Bibata-Modern-Classic (AUR
`bibata-cursor-theme-bin`), set by the theme's palette `cursor`.
