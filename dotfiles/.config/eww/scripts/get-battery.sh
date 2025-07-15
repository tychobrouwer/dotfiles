#!/bin/sh

if [[ ! -d "/sys/class/power_supply/BAT*" ]]; then
  echo ""
else
  FILES=$(ls /sys/class/power_supply/BAT*/capacity)
  
  cat ${FILES[0]}
fi

