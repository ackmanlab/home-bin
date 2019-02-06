#!/bin/bash
#setup external hdmi display if connected, else ensure the display is off
intern=eDP1
extern=HDMI1

if xrandr | grep "$extern connected"; then
    xrandr --output "$intern" --auto --output "$extern" --auto --right-of "$intern"
else
    xrandr --output "$intern" --auto --output "$extern" --off
fi
