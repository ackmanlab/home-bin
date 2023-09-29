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

echo 'battery % is '$PERCENT

if [ $PERCENT -le "23" ]; then
  #/usr/bin/i3-nagbar -m "Low battery"
  notify-send --urgency=critical "Low battery $PERCENT%"
fi

if [ $PERCENT -le "3" ]; then
  echo "powering down..."
  systemctl suspend
fi

