#!/usr/bin/env bash

export MOZ_USE_XINPUT2=1
#export GTK_IM_MODULE=fcitx
#export QT_IM_MODULE=fcitx

xsetroot -cursor_name right_ptr &
compton -i0.8 -b -f -D2 -I0.1 -O0.1 --no-fading-openclose --focus-exclude "class_g = 'XScreenSaver'" &
feh --bg-scale ~/background.jpeg &
xscreensaver -no-splash &
xmonad
