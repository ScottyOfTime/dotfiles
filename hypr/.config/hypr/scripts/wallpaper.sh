#!/bin/sh
# (re)start swaybg with the zine wallpaper for the current darkman mode,
# rendering it from the palette first if the palette or this script changed
mode=$(darkman get 2>/dev/null || echo dark)
palette=~/.config/palette/"$mode".env
. "$palette"
out=~/.cache/wallpaper/zine-"$mode".png

if [ ! -f "$out" ] || [ "$palette" -nt "$out" ] || [ "$0" -nt "$out" ]; then
    mkdir -p "${out%/*}"
    host=$(tr '[:lower:]' '[:upper:]' < /etc/hostname)
    # the breadcrumb slab is ink on paper, tape on ink so it still reads
    if [ "$mode" = dark ]; then slab=$tape; else slab=$ink; fi
    # draw flat, then lay grain over everything like a print
    magick -size 2560x1440 xc:"#$bg" \
        -fill "#$brown" -draw "polygon 334,402 1734,374 1736,462 336,490" \
        -fill "#$slab" -draw "polygon 326,394 1726,366 1728,454 328,482" \
        -font JetBrains-Mono-Bold -pointsize 30 -kerning 8 -fill "#$accent" \
        -annotate -1.1x-1.1+380+446 "ARCH  ›  HYPRLAND  ›  $host" \
        -fill "#$accent" -draw "polygon 250,560 2330,500 2350,900 270,960" \
        -font JetBrains-Mono-ExtraBold -pointsize 230 -kerning -8 \
        -fill "#$brown" -annotate -1.6x-1.6+334+862 "$host" \
        -fill "#$cream" -annotate -1.6x-1.6+320+848 "$host" \
        -alpha off -seed 7 -attenuate 0.2 -channel RGB +noise Gaussian +channel -depth 8 \
        -strip "$out"
fi

pkill -x swaybg
exec swaybg -m fill -i "$out"
