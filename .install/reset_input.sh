#!/bin/bash

setxkbmap -layout us -variant alt-intl-unicode
xset r rate 200 60

if [[ -n "$(command -v xinput)" ]] ; then
	function xinp-set
	{
		if [[ -n "$(xinput list-props "$1" | grep "$2 (")" ]] ; then
			xinput set-prop "$1" "$2" $3
		else
			echo -e "Warning: prop not found : $2" >&2
		fi
	}
	function xinp-get
	{
		if [[ -n "$(xinput list-props "$1" | grep "$2 (")" ]] ; then
			xinput list-props "$1" | grep "$2 (" | sed -E 's/.*'"$2"' \(.*\):\t(.*)/\1/g'
		else
			echo -e "Warning: prop not found : $2" >&2
		fi
	}

    # Set up touch pad
    tpname="SynPS/2 Synaptics TouchPad"
    if [[ -n "$(xinput list | grep "${tpname}")" ]] ; then
		# Enable device by default. Commented out since this should be controlled elsewhere
		#xinp-set "${tpname}" "Device Enabled" "1"

		# Speed up the pointer to factor 1.5 in x and y direction
		#xinp-set "${tpname}" "Coordinate Transformation Matrix" "\
		#1.00, 0.00, 0.00, \
		#0.00, 1.00, 0.00, \
		#0.00, 0.00, 1.00" # The last row/column is inversely proportional
		xinp-set "${tpname}" "Coordinate Transformation Matrix" "\
		1.50, 0.00, 0.00, \
		0.00, 1.50, 0.00, \
		0.00, 0.00, 1.00" # The last row/column is inversely proportional

        # Enable tap clicking
		#xinp-set "${tpname}" "libinput Tapping Enabled" "$(xinp-get "${tpname}" "libinput Tapping Enabled Default")"
        xinp-set "${tpname}" "libinput Tapping Enabled" "1"

		# Set Tapping Drag Enabled to default. Should be "1"
		xinp-set "${tpname}" "libinput Tapping Drag Enabled" "$(xinp-get "${tpname}" "libinput Tapping Drag Enabled Default")"

        # Enable tap click dragging lock
		#xinp-set "${tpname}" "libinput Tapping Drag Lock Enabled" "$(xinp-get "${tpname}" "libinput Tapping Drag Lock Enabled Default")"
        xinp-set "${tpname}" "libinput Tapping Drag Lock Enabled" "1"

		# Set Tapping Button Mapping to default. Should be "1, 0"
		xinp-set "${tpname}" "libinput Tapping Button Mapping Enabled" "$(xinp-get "${tpname}" "libinput Tapping Button Mapping Default")"
        #xinp-set "${tpname}" "libinput Tapping Button Mapping Enabled" "1, 1"

        # Enable natural ("mac") scrolling direction
		#xinp-set "${tpname}" "libinput Natural Scrolling Enabled" "$(xinp-get "${tpname}" "libinput Natural Scrolling Enabled Default")"
        xinp-set "${tpname}" "libinput Natural Scrolling Enabled" "1"

        # Do not disable while typing
		#xinp-set "${tpname}" "libinput Disable While Typing Enabled" "$(xinp-get "${tpname}" "libinput Disable While Typing Enabled Default")"
        xinp-set "${tpname}" "libinput Disable While Typing Enabled" "0"

		# Set Scroll Method Enabled to default. Should be "1, 0, 0"
		xinp-set "${tpname}" "libinput Scroll Method Enabled" "$(xinp-get "${tpname}" "libinput Scroll Method Enabled Default")"

        # Set the click method to be the number of fingers determine the click type
        # This means that right click is only possible via tapping two fingers on the touchpad
		#xinp-set "${tpname}" "libinput Click Method Enabled" "$(xinp-get "${tpname}" "libinput Click Method Enabled Default")"
        xinp-set "${tpname}" "libinput Click Method Enabled" "0, 1"

        # Middle mouse button emulation. This disables the middle mouse soft area
		#xinp-set "${tpname}" "libinput Middle Emulation Enabled" "$(xinp-get "${tpname}" "libinput Middle Emulation Enabled Default")"
        xinp-set "${tpname}" "libinput Middle Emulation Enabled" "1"

		# Set Accel Speed to default. Should be "0.00"
		xinp-set "${tpname}" "libinput Accel Speed" "$(xinp-get "${tpname}" "libinput Accel Speed Default")"

		# Set Left Handed Enabled to default. Should be "0"
		xinp-set "${tpname}" "libinput Left Handed Enabled" "$(xinp-get "${tpname}" "libinput Left Handed Enabled Default")"

		# Set Send Events Mode Enabled to default. Should be "0, 0"
		xinp-set "${tpname}" "libinput Send Events Mode Enabled" "$(xinp-get "${tpname}" "libinput Send Events Mode Enabled Default")"

		# Drag Lock Buttons is unknown
		#xinp-set "${tpname}" "libinput Drag Lock Buttons"

		# Horizontal Scroll Enabled does not have a default, but should be enabled
		xinp-set "${tpname}" "libinput Horizontal Scroll Enabled" "1"

		#xinp-set "${tpname}" "libinput Scroll Methods Available" # TODO : What to do with the Available values?
		#xinp-set "${tpname}" "libinput Click Methods Available" # TODO : What to do with the Available values?
		#xinp-set "${tpname}" "libinput Send Events Modes Available" # TODO : What to do with the Available values?
		#xinp-set "${tpname}" "Device Node" # Probably not mutable
		#xinp-set "${tpname}" "Device Product ID" # Probably not mutable
    fi
fi
