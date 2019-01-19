#!/bin/bash

setxkbmap -layout us -variant alt-intl-unicode
xset r rate 200 60

if [[ -n "$(command -v xinput)" ]] ; then
    # Set up touch pad
    tpid="$(xinput list | grep TouchPad | sed -E 's/.*id=([0-9]+).*/\1/g')"
    if [[ -n "${tpid}" ]] ; then
        function xinp-set {
            if [[ -n "$(xinput list-props $1 | grep $2)" ]] ; then
                xinput set-prop $1 $2 $3
            fi
        }

        # Enable tap clicking
        xinp-set ${tpid} 293 1
        # Enable tap click dragging lock
        xinp-set ${tpid} 297 1
        # Enable natural ("mac") scrolling direction
        xinp-set ${tpid} 287 1
        # Do not disable while typing
        xinp-set ${tpid} 301 0
        # Set the click method to be the number of fingers determine the click type
        # This means that right click is only possible via tapping two fingers on the touchpad
        xinp-set ${tpid} 307 "{0 1}"
        # Tapping button mapping
        #xinp-set ${tpid} 299 {1 1}
        # Middle mouse button emulation. This disables the middle mouse soft area
        xinp-set ${tpid} 309 1
    fi
fi
