#!/bin/bash

if compgen -G "/sys/class/power_supply/BAT*/power_now" > /dev/null; then
  powerDraw="󰠰 $(($(cat /sys/class/power_supply/BAT*/power_now)/1000000))w"
fi


cat << EOF
{ "text":"$powerDraw", "tooltip":"power Draw $powerDraw"}  
EOF
