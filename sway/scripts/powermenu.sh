#!/usr/bin/env bash
# ~/.config/sway/scripts/powermenu.sh
# Simple wofi-based power menu, styled by wofi's own theme (see wofi config below).

entries="Lock\nLogout\nSuspend\nReboot\nShutdown"

selected=$(echo -e "$entries" | wofi --dmenu --prompt "Power" --width 220 --height 220 --cache-file /dev/null)

case "$selected" in
    Lock)     ~/.config/sway/scripts/lock.sh ;;
    Logout)   swaymsg exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
