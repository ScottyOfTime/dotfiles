#!/bin/sh
# GTK3 doesn't antialias gradient stops, so the tilted strips behind the
# labels are SVGs, rendered here in the palette's colours
. "$1"
dir=$(dirname "$0")/strips
rm -rf "$dir"
mkdir -p "$dir"

strip() {
    cat > "$dir/$1-$2.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $3 40" preserveAspectRatio="none">
<polygon points="$4" fill="#$ink" transform="translate(3 3)"/>
<polygon points="$4" fill="#$(eval echo \$$2)"/>
</svg>
SVG
}

for c in paper surface accent red; do
    strip ws1 $c 40 "3,9 33,4 34,32 4,35"
    strip ws2 $c 40 "4,4 34,9 33,35 3,32"
    strip ws3 $c 40 "6,6 35,3 31,34 2,32"
    strip ws4 $c 40 "2,3 31,7 35,33 5,36"
done
strip window      ink   400 "2,7 396,3 397,33 3,35"
strip clock       paper 120 "4,4 116,9 113,36 1,31"
strip mpris       paper 120 "1,7 117,2 119,30 6,36"
strip wireplumber panel 120 "3,3 114,6 118,35 2,33"
strip cpu         panel 120 "5,9 119,4 115,33 1,36"
strip memory      panel 120 "2,2 118,8 116,34 4,31"
strip network     panel 120 "6,6 113,2 119,32 1,35"
strip battery     panel 120 "2,8 117,5 114,36 4,32"
