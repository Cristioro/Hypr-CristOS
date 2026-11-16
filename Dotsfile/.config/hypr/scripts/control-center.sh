#!/usr/bin/env bash
# El proceso permanece vivo aunque se cierre el panel.
set -u
exec "$HOME/.config/hypr/scripts/notifications.sh" controls
