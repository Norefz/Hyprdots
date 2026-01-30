#!/bin/bash

brightness_step=$1
notification_timeout=2000

brightnessctl s "$brightness_step"

val=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

if [ "$val" -le 30 ]; then
  icon=".local/bin/icons/brightness_low.svg"
elif [ "$val" -le 50 ]; then
  icon=".local/bin/icons/brightness_med.svg"
elif [ "$val" -le 70 ]; then
  icon=".local/bin/icons/brightness_medium.svg"
elif [ "$val" -le 100 ]; then
  icon=".local/bin/icons/brightness_high.svg"

fi

notify-send -e -t $notification_timeout \
  -a "SwayNC_Brightness" \
  -h string:x-canonical-private-synchronous:brightness_notif \
  -h int:value:"$val" \
  -i "$icon" \
  "Brightness" "$val%"
