#!/bin/sh

if [[ ! -d "/sys/class/power_supply/BAT0" ]]; then
  echo ""
else
  FILES=$(ls /sys/class/power_supply/BAT*/capacity)
  
  cat ${FILES[0]}
fi

