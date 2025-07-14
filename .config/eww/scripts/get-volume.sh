#!/bin/sh

if command -v wpctl &>/dev/null; then
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
        echo 0
    else
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'
    fi
elif command -v pamixer &>/dev/null; then
    if [ true == $(pamixer --get-mute) ]; then
        echo 0
    else
        pamixer --get-volume
    fi
else
    echo 0
fi
