#!/usr/bin/env bash
# ~/.config/sway/scripts/screenshot.sh
# Usage: screenshot.sh [output|region|window|snip]
# Saves to ~/Pictures/Screenshots and copies to clipboard via wl-copy.
# "snip" opens the capture in swappy for annotation instead (swappy handles
# its own copy/save).

set -euo pipefail

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

mode="${1:-region}"

case "$mode" in
    output)
        grim "$file"
        ;;
    region)
        geometry=$(slurp) || exit 0
        grim -g "$geometry" "$file"
        ;;
    snip)
        geometry=$(slurp) || exit 0
        grim -g "$geometry" - | swappy -f - -o "$file"
        exit 0
        ;;
    window)
        geometry=$(swaymsg -t get_tree | \
            jq -r '.. | select(.type?=="con" and .focused?==true) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"')
        grim -g "$geometry" "$file"
        ;;
    *)
        echo "usage: screenshot.sh [output|region|window|snip]" >&2
        exit 1
        ;;
esac

wl-copy < "$file"
notify-send -a Screenshot "Screenshot saved" "$file"
