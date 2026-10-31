#!/bin/sh
# GTK3 doesn't antialias gradient stops, so the tilted strips behind the
# labels are SVGs, rendered here in the palette's colours
. "$1"
dir=$(dirname "$0")/strips
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
    strip chip-a $c 40 "3,9 33,4 34,32 4,35"
    strip chip-b $c 40 "4,4 34,9 33,35 3,32"
done
for c in paper panel; do
    strip strip-a $c 120 "2,8 115,3 116,32 3,35"
    strip strip-b $c 120 "3,3 116,8 115,35 2,32"
done
strip slab ink 400 "2,7 396,3 397,33 3,35"
