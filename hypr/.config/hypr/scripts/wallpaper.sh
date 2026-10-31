#!/bin/sh
mode=$(darkman get 2>/dev/null || echo dark)
palette=~/.config/palette/"$mode".env
. "$palette"
out=~/.cache/wallpaper/zine-"$mode".png

if [ ! -f "$out" ] || [ "$palette" -nt "$out" ] || [ "$0" -nt "$out" ]; then
    mkdir -p "${out%/*}"
    host=$(cat /etc/hostname)
    sh="-fill #$ink -stroke none"
    ol="-stroke #$ink -strokewidth 6"
    magick -size 2560x1440 xc:"#$bg" \
        \( -size 22x22 xc:none -fill "#$teal" \
           -draw "circle 11,11 11,17" -write mpr:dot +delete \
           -size 560x340 tile:mpr:dot -background none -rotate 8 \) \
        -geometry +1660+980 -compose over -composite \
        $sh -draw "polygon 356,836 1356,776 1396,1196 396,1256" \
        -fill "#$sage" $ol -draw "polygon 340,820 1340,760 1380,1180 380,1240" \
        $sh -draw "circle 1876,646 1876,1036" \
        -fill "#$mustard" $ol -draw "circle 1860,630 1860,1020" \
        $sh -draw "polygon 236,536 1516,486 1536,716 256,766" \
        -fill "#$accent" $ol -draw "polygon 220,520 1500,470 1520,700 240,750" \
        $sh -draw "polygon 1606,286 1926,256 1934,320 1614,350" \
        -fill "#$rose" $ol -draw "polygon 1596,276 1916,246 1924,310 1604,340" \
        -stroke none -font JetBrains-Mono-ExtraBold -pointsize 150 -kerning -4 \
        -fill "#$ink" -annotate -2.2x-2.2+300+680 "$host" \
        -font JetBrains-Mono-Bold -pointsize 34 -kerning 6 \
        -fill "#$dim" -annotate +400+1340 "arch  /  hyprland  /  zine" \
        -alpha off -seed 7 -attenuate 0.2 -channel RGB +noise Gaussian +channel -depth 8 \
        -strip "$out"
fi

pkill -x swaybg
exec swaybg -m fill -i "$out"
