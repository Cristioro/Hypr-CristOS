#!/bin/bash

max=25
speed=0.01
offset_file="/tmp/waybar_player_offset"

artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
status=$(playerctl status 2>/dev/null)

# si no hay música REAL
if [ -z "$artist" ] && [ -z "$title" ]; then
  echo ""
  exit 0
fi

# icono
if [ "$status" = "Playing" ]; then
  icon=""
else
  icon=""
fi

# construir texto correctamente
if [ -n "$artist" ] && [ -n "$title" ]; then
  text="$artist - $title"
elif [ -n "$title" ]; then
  text="$title"
else
  text="$artist"
fi

# padding scroll
scroll_text="$text   •   "
len=${#scroll_text}

# offset
if [ -f "$offset_file" ]; then
  offset=$(cat "$offset_file")
else
  offset=0
fi

offset=$(( (offset + 1) % len ))
echo "$offset" > "$offset_file"

# ventana visible
visible="${scroll_text:$offset:$max}"

if [ ${#visible} -lt $max ]; then
  rest=$((max - ${#visible}))
  visible="$visible${scroll_text:0:$rest}"
fi

echo "$icon $visible"

sleep $speed