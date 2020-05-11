#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "
          hdmi - setup external display if connected, else ensure the display is off
               - run 'xrandr' to see display interface names for input
               - use for X11 window managers such as i3wm
    
              Usage: hdmi.sh 
                     hdmi.sh DP1 
    "
    exit 0
fi

set -e

intern=eDP1
extern=${1:-HDMI1}

if xrandr | grep "$extern connected"; then
    xrandr --output "$intern" --auto --output "$extern" --auto --right-of "$intern"
else
    xrandr --output "$intern" --auto --output "$extern" --off
fi
