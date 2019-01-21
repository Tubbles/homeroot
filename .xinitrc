#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

#twm &

setxkbmap -layout us -variant alt-intl-unicode

# Unset the screen saving settings
xset -dpms
xset s off

if [[ -x "${HOME}/.install/reset_input.sh" ]] ; then
    "${HOME}/.install/reset_input.sh"
fi

if [[ -n "$(command -v libinput-gestures-setup)" ]] ; then
    # Start the touchpad gesture daemon
    libinput-gestures-setup start
fi

exec i3
