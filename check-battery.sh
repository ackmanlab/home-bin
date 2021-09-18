#!/bin/bash
#
# low battery warning
#

BATTERY=/sys/class/power_supply/BAT0

# REM=`grep "POWER_SUPPLY_CHARGE_NOW" $BATTERY/uevent | awk -F= '{ print $2 }'`
# FULL=`grep "POWER_SUPPLY_CHARGE_FULL_DESIGN" $BATTERY/uevent | awk -F= '{ print $2 }'`
REM=`grep -i "charge_now" $BATTERY/uevent | awk -F= '{ print $2 }'`
FULL=`grep -i "charge_full_design" $BATTERY/uevent | awk -F= '{ print $2 }'`
PERCENT=`echo $(( $REM * 100 / $FULL ))`

if [ $PERCENT -le "11" ]; then
  #/usr/bin/i3-nagbar -m "Low battery"
  #echo 'low battery '$PERCENT
  notify-send --urgency=critical "Low battery $PERCENT%"
fi

