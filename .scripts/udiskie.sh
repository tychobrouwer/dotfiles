#!/bin/sh

if [[ ! $(pidof udiskie) ]]; then
  udiskie --automount --no-notify --smart-tray &
fi
