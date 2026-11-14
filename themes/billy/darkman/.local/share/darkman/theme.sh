#!/bin/sh
lib=$(readlink -f "$0"); . "${lib%/themes/*}/lib/theme.sh"

desktop true 'JetBrains Mono' 10 'JetBrains Mono' 11
render
reload
