#!/bin/sh
# mod+E's yazi. A mode switch sends it SIGUSR1 (lib/theme.sh), which yazi
# doesn't handle, so it dies with 138: start it again to read the new
# theme, in the same window. Any other exit closes the pad
export DOTFILES_FILES_PAD=1
while yazi; [ $? -eq 138 ]; do :; done
