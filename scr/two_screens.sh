#!/bin/bash

if [[ "$1" = "reset" ]] ; then
    xrandr --output HDMI1 --off
    xrandr --output eDP1 --auto --scale 1x1
elif [[ "$1" = "duplicate" ]] ; then
    xrandr --output eDP1 --auto --scale 1x1
    xrandr --output HDMI1 --auto --same-as eDP1
elif [[ "$1" = "external" ]] ; then
    xrandr --output eDP1 --off
    xrandr --output HDMI1 --auto
else
    # Set zoom level
    xrandr --output eDP1 --auto --scale 0.8x.8
    xrandr --output HDMI1 --auto --right-of eDP1
fi

feh --bg-scale $HOME/pic/wallpaper
