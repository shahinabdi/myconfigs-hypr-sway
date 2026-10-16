#!/usr/bin/env bash
set -euo pipefail

notify() {
    notify-send "Bluetooth" "$1"
}

controller_info() {
    bluetoothctl show
}

is_powered() {
    grep -Eq '^[[:space:]]*Powered: yes$' <<< "$1"
}

open_settings() {
    if ! command -v alacritty >/dev/null 2>&1; then
        notify "Cannot open Bluetooth settings: Alacritty is not installed."
        return 1
    fi
    alacritty -e bluetoothctl >/dev/null 2>&1 &
}

show_status() {
    local info
    info=$(controller_info) || {
        printf '{"text":"󰂲","tooltip":"Bluetooth controller unavailable","class":"unavailable"}\n'
        return 0
    }
    if is_powered "$info"; then
        printf '{"text":"󰂯","tooltip":"Bluetooth on — click to manage devices","class":"powered"}\n'
    else
        printf '{"text":"󰂲","tooltip":"Bluetooth off — click to manage devices","class":"disabled"}\n'
    fi
}

show_menu() {
    local info toggle devices line address name connected choice action
    info=$(controller_info) || {
        notify "No Bluetooth controller is available."
        return 1
    }
    if is_powered "$info"; then
        toggle="Turn Bluetooth off"
    else
        toggle="Turn Bluetooth on"
    fi

    devices=$(bluetoothctl devices Paired) || {
        notify "Could not list paired Bluetooth devices."
        return 1
    }

    local -a choices=("$toggle" "Pair or manage devices")
    while IFS= read -r line; do
        [[ $line == Device\ * ]] || continue
        read -r _ address name <<< "$line"
        [[ -n ${name:-} ]] || name="Unnamed device"
        if bluetoothctl info "$address" | grep -Eq '^[[:space:]]*Connected: yes$'; then
            choices+=("Disconnect: $name ($address)")
        else
            choices+=("Connect: $name ($address)")
        fi
    done <<< "$devices"

    if ! command -v wofi >/dev/null 2>&1; then
        notify "Cannot open the Bluetooth menu: wofi is not installed."
        return 1
    fi
    if ! choice=$(printf '%s\n' "${choices[@]}" | wofi --dmenu --prompt "Bluetooth" --width 420 --lines 12 --cache-file /dev/null); then
        return 0
    fi

    case "$choice" in
        "Turn Bluetooth on")
            if bluetoothctl power on; then
                notify "Bluetooth enabled."
            else
                notify "Could not enable Bluetooth."
                return 1
            fi
            ;;
        "Turn Bluetooth off")
            if bluetoothctl power off; then
                notify "Bluetooth disabled."
            else
                notify "Could not disable Bluetooth."
                return 1
            fi
            ;;
        "Pair or manage devices")
            open_settings
            ;;
        Connect:*|Disconnect:*)
            if [[ $choice =~ ([[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}) ]]; then
                address=${BASH_REMATCH[1]}
            else
                notify "Could not identify the selected Bluetooth device."
                return 1
            fi
            action=${choice%%:*}
            action=${action,,}
            if bluetoothctl "$action" "$address"; then
                notify "$action request sent to ${choice#*: }."
            else
                notify "Could not $action the selected Bluetooth device."
                return 1
            fi
            ;;
    esac
}

case "${1:-}" in
    --status)
        show_status
        ;;
    --menu)
        show_menu
        ;;
    --settings)
        open_settings
        ;;
    *)
        printf 'Usage: %s --status|--menu|--settings\n' "$0" >&2
        exit 2
        ;;
esac
