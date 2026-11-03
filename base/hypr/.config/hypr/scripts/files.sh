#!/bin/sh
# mod+E: one yazi kept on special:files, so showing it needn't start
# Ghostty (~200ms); launched the first time. filespad.sh sets
# DOTFILES_FILES_PAD, which makes Esc hide it instead of quitting
# (yazi/plugins/close.yazi)
if hyprctl clients | grep -q 'class: com.scotty.filespad$'; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("files")' >/dev/null
else
    hyprctl dispatch 'hl.dsp.exec_cmd("ghostty --class=com.scotty.filespad --confirm-close-surface=false -e ~/.config/hypr/scripts/filespad.sh")' >/dev/null
fi
