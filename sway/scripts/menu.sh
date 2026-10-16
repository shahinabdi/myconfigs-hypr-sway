#!/usr/bin/env bash
# ~/.config/sway/scripts/menu.sh
# Toggles wofi: if it's already open, close it instead of stacking a new one.

if pgrep -x wofi >/dev/null; then
    pkill -x wofi
else
    wofi --show drun --allow-images
fi
