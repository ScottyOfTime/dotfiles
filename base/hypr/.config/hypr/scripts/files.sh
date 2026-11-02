#!/bin/sh
# mod+E: one yazi kept on special:files, so showing it needn't start
# Ghostty (~200ms); launched the first time. DOTFILES_FILES_PAD makes Esc
# hide it instead of quitting (yazi/plugins/close.yazi)
if hyprctl clients | grep -q 'class: com.scotty.filespad$'; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("files")' >/dev/null
else
    hyprctl dispatch 'hl.dsp.exec_cmd("ghostty --class=com.scotty.filespad --confirm-close-surface=false -e env DOTFILES_FILES_PAD=1 yazi")' >/dev/null
fi
