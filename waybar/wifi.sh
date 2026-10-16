#!/usr/bin/env bash
set -euo pipefail

notify() {
    notify-send "Wi-Fi" "$1"
}

select_menu_item() {
    local prompt=$1
    shift

    if ! command -v wofi >/dev/null 2>&1; then
        notify "Cannot open the Wi-Fi menu: wofi is not installed."
        return 2
    fi

    local selected
    if ! selected=$(printf '%s\n' "$@" | wofi --dmenu --prompt "$prompt" --width 420 --lines 12 --cache-file /dev/null); then
        return 1
    fi
    printf '%s' "$selected"
}

open_settings() {
    if ! command -v alacritty >/dev/null 2>&1; then
        notify "Cannot open NetworkManager settings: Alacritty is not installed."
        return 1
    fi
    alacritty -e nmtui >/dev/null 2>&1 &
}

show_menu() {
    local radio toggle choice networks ssid
    radio=$(nmcli -t -f WIFI radio)
    if [[ $radio == enabled ]]; then
        toggle="Turn Wi-Fi off"
    else
        toggle="Turn Wi-Fi on"
    fi

    if choice=$(select_menu_item "Wi-Fi" "$toggle" "Connect to a visible network" "Network settings"); then
        :
    else
        local status=$?
        ((status == 1)) && return 0
        return "$status"
    fi
    case "$choice" in
        "Turn Wi-Fi on")
            if nmcli radio wifi on; then
                notify "Wi-Fi enabled."
            else
                notify "Could not enable Wi-Fi."
                return 1
            fi
            ;;
        "Turn Wi-Fi off")
            if nmcli radio wifi off; then
                notify "Wi-Fi disabled."
            else
                notify "Could not disable Wi-Fi."
                return 1
            fi
            ;;
        "Network settings")
            open_settings
            ;;
        "Connect to a visible network")
            if [[ $radio != enabled ]]; then
                notify "Turn Wi-Fi on before choosing a network."
                return 0
            fi
            networks=$(nmcli -g SSID device wifi list --rescan yes) || {
                notify "Could not scan for Wi-Fi networks."
                return 1
            }
            local -a choices=()
            local -A seen=()
            while IFS= read -r ssid; do
                [[ -n $ssid && -z ${seen["$ssid"]+x} ]] || continue
                seen["$ssid"]=1
                choices+=("$ssid")
            done <<< "$networks"
            if ((${#choices[@]} == 0)); then
                notify "No Wi-Fi networks found."
                return 0
            fi
            if ssid=$(select_menu_item "Connect to network" "${choices[@]}"); then
                :
            else
                local status=$?
                ((status == 1)) && return 0
                return "$status"
            fi
            if nmcli --wait 20 device wifi connect "$ssid"; then
                notify "Connected to $ssid."
            else
                notify "Could not connect to $ssid. For secured networks, open Network settings to enter the password."
                return 1
            fi
            ;;
    esac
}

case "${1:-}" in
    --menu)
        show_menu
        ;;
    --settings)
        open_settings
        ;;
    *)
        printf 'Usage: %s --menu|--settings\n' "$0" >&2
        exit 2
        ;;
esac
