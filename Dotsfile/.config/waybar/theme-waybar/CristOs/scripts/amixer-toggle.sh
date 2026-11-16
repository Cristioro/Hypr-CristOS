#!/bin/bash
# amixer-toggle.sh — alterna mute/unmute del Master (PulseAudio/PipeWire).

state=$(amixer -D pulse sget Master | awk '/\[on\]/{print "on"; exit} /\[off\]/{print "off"; exit}')

if [ "$state" = "on" ]; then
    amixer -D pulse sset Master mute > /dev/null
else
    amixer -D pulse sset Master unmute > /dev/null
fi
