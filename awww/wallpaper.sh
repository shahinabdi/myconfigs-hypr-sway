#!/usr/bin/env bash
# ~/.config/awww/wallpaper.sh
# Sets the wallpaper via awww (the swww project, renamed upstream) with a
# short, light transition (no heavy animation). Called from sway config on
# startup (exec_always).

set -euo pipefail

WALLPAPER="$HOME/Pictures/Wallpapers/current.jpg"

# Wait for the awww daemon socket to be ready (first launch race on login).
for _ in $(seq 1 20); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
done

awww img "$WALLPAPER" \
    --transition-type fade \
    --transition-duration 1 \
    --transition-fps 60 \
    --resize crop \
    --filter Lanczos3
