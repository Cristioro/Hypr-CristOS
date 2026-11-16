#!/usr/bin/env bash
# Estado del centro de control rápido (una línea JSON).
set -u

# ---------------------------------------------------------------- volumen
sink="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
volume=0
muted=false
if [ -n "$sink" ]; then
    volume=$(awk '{printf "%d", $2 * 100}' <<<"$sink")
    case "$sink" in *MUTED*) muted=true ;; esac
fi

# ------------------------------------------------------------------- micro
source_state="$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true)"
mic_muted=false
case "$source_state" in *MUTED*) mic_muted=true ;; esac

# ------------------------------------------------------------------ brillo
# Monitor por DDC/CI (este equipo no tiene backlight de hardware).
bri="$(timeout 3 ddcutil getvcp 10 --brief 2>/dev/null || true)"
bri_cur=0
bri_max=100
ddc_available=false
if [ -n "$bri" ]; then
    ddc_available=true
    bri_cur=$(awk '{print $4}' <<<"$bri")
    bri_max=$(awk '{print $5}' <<<"$bri")
fi
case "$bri_cur" in ''|*[!0-9]*) bri_cur=0 ;; esac
case "$bri_max" in ''|*[!0-9]*) bri_max=100 ;; esac
[ "$bri_max" -gt 0 ] || bri_max=100

# ------------------------------------------------------------ luz nocturna
nightlight=false
[ "$(cat /tmp/hyprsunset_clicked_state 2>/dev/null || echo 0)" = "1" ] && nightlight=true

# --------------------------------------------------------------- no molestar
dnd=false
makoctl mode 2>/dev/null | grep -qx 'do-not-disturb' && dnd=true

# -------------------------------------------------------------------- red
# Prioriza ethernet/wifi; ignora loopback y túneles (ZeroTier, VPN...).
net_connected=false
net_type="none"
net_name=""
net_ip=""

net_line=""
if command -v nmcli >/dev/null 2>&1; then
    net_line=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null \
        | awk -F: '$3=="connected" && ($2=="ethernet" || $2=="wifi") {print; exit}')
    [ -n "$net_line" ] || net_line=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null \
        | awk -F: '$3=="connected" && $2!="loopback" && $2!="tun" {print; exit}')
fi

if [ -n "$net_line" ]; then
    net_connected=true
    net_dev=$(cut -d: -f1 <<<"$net_line")
    net_type=$(cut -d: -f2 <<<"$net_line")
    net_name=$(cut -d: -f4- <<<"$net_line")
    net_ip=$(nmcli -t -f IP4.ADDRESS device show "$net_dev" 2>/dev/null \
        | head -1 | cut -d: -f2 | cut -d/ -f1)
fi

# --------------------------------------------------------------- bluetooth
bt_powered=false
bt_count=0
bt_names=""

if command -v bluetoothctl >/dev/null 2>&1; then
    bt_show=$(timeout 2 bluetoothctl show 2>/dev/null || true)
    grep -q 'Powered: yes' <<<"$bt_show" && bt_powered=true

    bt_list=$(timeout 2 bluetoothctl devices Connected 2>/dev/null || true)
    if [ -n "$bt_list" ]; then
        bt_count=$(wc -l <<<"$bt_list" | tr -d ' ')
        bt_names=$(sed -E 's/^Device [^ ]+ //' <<<"$bt_list" | paste -sd ', ' -)
    fi
fi

# ------------------------------------------------------------------- JSON
jq -cn \
    --argjson volume "$volume" \
    --argjson muted "$muted" \
    --argjson brightness "$bri_cur" \
    --argjson brightnessMax "$bri_max" \
    --argjson ddcAvailable "$ddc_available" \
    --argjson micMuted "$mic_muted" \
    --argjson nightlight "$nightlight" \
    --argjson dnd "$dnd" \
    --argjson networkConnected "$net_connected" \
    --arg networkType "$net_type" \
    --arg networkName "$net_name" \
    --arg networkIp "$net_ip" \
    --argjson btPowered "$bt_powered" \
    --argjson btCount "$bt_count" \
    --arg btNames "$bt_names" \
    '{
        volume: $volume,
        muted: $muted,
        brightness: $brightness,
        brightnessMax: $brightnessMax,
        ddcAvailable: $ddcAvailable,
        micMuted: $micMuted,
        nightlight: $nightlight,
        dnd: $dnd,
        networkConnected: $networkConnected,
        networkType: $networkType,
        networkName: $networkName,
        networkIp: $networkIp,
        btPowered: $btPowered,
        btCount: $btCount,
        btNames: $btNames
    }'
