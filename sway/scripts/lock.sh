#!/usr/bin/env bash
# ~/.config/sway/scripts/lock.sh
# Dark, minimal lockscreen matching the rest of the theme.
# Colors follow the neon-blue-on-dark-navy palette used in waybar/mako.

# Prevent running multiple instances of swaylock stacked on top of each other
pgrep -x swaylock >/dev/null && exit 0

swaylock \
    --daemonize \
    --image ~/Pictures/Wallpapers/current.jpg \
    --scaling fill \
    --color 1a1b26 \
    --inside-color 16171f \
    --inside-clear-color 16171f \
    --inside-ver-color 16171f \
    --inside-wrong-color 1a1b26 \
    --ring-color 3b4261 \
    --ring-clear-color 7dcfff \
    --ring-ver-color 7dcfff \
    --ring-wrong-color f7768e \
    --key-hl-color 7dcfff \
    --line-uses-ring \
    --indicator-idle-visible \
    --show-keyboard-layout \
    --text-color c0caf5 \
    --text-clear-color c0caf5 \
    --text-ver-color c0caf5 \
    --text-wrong-color f7768e \
    --indicator-radius 90 \
    --indicator-thickness 8 \
    --font "JetBrainsMono Nerd Font"
