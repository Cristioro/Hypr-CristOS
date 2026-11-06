#!/usr/bin/env bash
# Ajusta el modo de GTK (solo apps GTK) tras generar la paleta con matugen.
# No toca KDE/Qt: kdeglobals y Kvantum quedan intactos.

MODE="dark"
[ -f "$HOME/.config/matugen/settings.conf" ] && source "$HOME/.config/matugen/settings.conf"

if [ "$MODE" = "light" ]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3 2>/dev/null
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark 2>/dev/null
fi
