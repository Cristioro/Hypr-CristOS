#!/usr/bin/env bash
# Centro de control de Hypr-CristOS — frontend rofi.
#
# OBSOLETO: reemplazado por la GUI de quickshell (SUPER + I).
# Se conserva solo como referencia/legado; ya no está enlazado a ningún atajo.
# La lógica sigue viviendo en ~/.config/hypr/scripts/settings-core.sh.
#
# Aquí solo hay interfaz: se describen los menús y se despacha al core
# (~/.config/hypr/scripts/settings-core.sh), que es quien tiene la lógica.
# Para añadir una opción basta con un `menu_add "etiqueta" "acción"`.
#
# Códigos de menu_run: 0 = acción ejecutada · 1 = cancelado · 2 = volver · 3 = cerrar
set -u

CORE="${SETTINGS_CORE:-$HOME/.config/hypr/scripts/settings-core.sh}"
THEME="$HOME/.config/rofi/settings/style.rasi"

core() { "$CORE" "$@"; }

menu() {
    local prompt="$1" mesg="${2:-}"
    if [ -n "$mesg" ]; then
        rofi -dmenu -i -p "$prompt" -mesg "$mesg" -theme "$THEME"
    else
        rofi -dmenu -i -p "$prompt" -theme "$THEME"
    fi
}

confirm() {
    local msg="$1"
    [ "$(printf 'Sí\nNo' | menu "Confirmar" "$msg")" = "Sí" ]
}

# ---------------------------------------------------------- motor de menús
declare -a MENU_LABELS=() MENU_ACTIONS=()

menu_reset() { MENU_LABELS=(); MENU_ACTIONS=(); }
menu_add()   { MENU_LABELS+=("$1"); MENU_ACTIONS+=("$2"); }

menu_run() {
    local prompt="$1" mesg="${2:-}" sel i
    sel=$(printf '%s\n' "${MENU_LABELS[@]}" | menu "$prompt" "$mesg") || return 1
    [ -n "$sel" ] || return 1
    for i in "${!MENU_LABELS[@]}"; do
        [ "${MENU_LABELS[$i]}" = "$sel" ] || continue
        case "${MENU_ACTIONS[$i]}" in
            @back)  return 2 ;;
            @close) return 3 ;;
        esac
        eval "${MENU_ACTIONS[$i]}"
        return 0
    done
    return 1
}

# ----------------------------------------------------------------- estado
MODE="dark"
SCHEME_NAME="tonal-spot"
DND="No"
VOLUME=""
CAFFEINE="Desactivada"
WALL=""
WALL_NAME=""
BAR_THEME="actual"
BAR_MODE="complete"
CLOCK_LABEL="24 h"
NIGHTLIGHT="off"
TRANSPARENCY_WAYBAR="70"
TRANSPARENCY_ROFI="15"
NETWORK_STATE=""
HOSTNAME="$(hostname)"
KERNEL="$(uname -r)"

load_state() { eval "$(core state 2>/dev/null)"; }

# ------------------------------------------------------------- Apariencia
bar_mode_supported() {
    [ "$BAR_THEME" = "actual" ] && return 0
    local d="$HOME/.config/waybar/theme-waybar/$BAR_THEME"
    [ -f "$d/style.complete.css" ] && [ -f "$d/style.modular.css" ]
}

appearance_menu() {
    local mode_label bar_label
    while true; do
        load_state
        mode_label="Oscuro"
        bar_label="completa"
        [ "$MODE" = "light" ] && mode_label="Claro"
        [ "$BAR_MODE" = "modular" ] && bar_label="modular"

        menu_reset
        menu_add "󰸉  Cambiar wallpaper"                     "core wallpaper picker"
        menu_add "󰔎  Modo: $mode_label"                     "mode_menu"
        menu_add "󰏘  Esquema de color: $SCHEME_NAME"        "scheme_menu"
        menu_add "󰓡  Tema de barra: $BAR_THEME"             "bar_theme_menu"
        bar_mode_supported && menu_add "󰍜  Barra: $bar_label (completa/módulos)" "core bar mode"
        menu_add "󰅐  Hora: $CLOCK_LABEL"                    "clock_menu"
        menu_add "󰂔  Transparencia (barra / rofi)"           "transparency_menu"
        menu_add "󰑓  Regenerar tema desde el wallpaper"      "core theme regenerate"
        menu_add "󰒓  Reiniciar Waybar"                      "core bar reload"
        menu_add "󰑓  Recargar Hyprland"                     "core reload"
        menu_add "󰅖  Volver"                                "@back"

        menu_run "Apariencia" "Wallpaper: $WALL_NAME"
        case $? in
            0) continue ;;
            *) return 0 ;;
        esac
    done
}

mode_menu() {
    menu_reset
    menu_add "Oscuro" "core theme mode dark"
    menu_add "Claro"  "core theme mode light"
    menu_add "󰅖  Volver" "@back"
    menu_run "Modo de color"
}

scheme_menu() {
    local s
    menu_reset
    for s in tonal-spot vibrant expressive fidelity content neutral monochrome rainbow fruit-salad smart; do
        menu_add "$s" "core theme scheme $s"
    done
    menu_add "󰅖  Volver" "@back"
    menu_run "Esquema de color" "Actual: $SCHEME_NAME"
}

bar_theme_menu() {
    local line name
    menu_reset
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        name="${line#● }"
        name="${name#  }"
        menu_add "$line" "core bar theme $(printf '%q' "$name")"
    done < <(core bar theme-list 2>/dev/null)
    if [ -d "$HOME/.config/waybar/.theme-backup" ]; then
        menu_add "󰦨  Restaurar original" "core bar theme-restore"
    fi
    menu_add "󰅖  Volver" "@back"
    menu_run "Tema de barra" "Actual: $BAR_THEME"
}

clock_menu() {
    menu_reset
    menu_add "24 h"              "core clock preset 24h"
    menu_add "24 h con segundos" "core clock preset 24h-seg"
    menu_add "12 h"              "core clock preset 12h"
    menu_add "12 h con segundos" "core clock preset 12h-seg"
    menu_add "Fecha y hora"      "core clock preset fecha-hora"
    menu_add "Solo fecha"        "core clock preset fecha"
    menu_add "Personalizado…"    "clock_custom"
    menu_add "󰅖  Volver"          "@back"
    menu_run "Formato de hora" "Actual: $CLOCK_LABEL"
}

clock_custom() {
    local custom fmt
    custom=$(menu "Formato de hora" "Sintaxis strftime. Ej: %H:%M · %d/%m %H:%M")
    [ -n "$custom" ] || return 0
    case "$custom" in
        *"{:"*) fmt="$custom" ;;
        *)      fmt="{:$custom}" ;;
    esac
    core clock set "$fmt"
}

transparency_menu() {
    menu_reset
    menu_add "󰂔  Barra      · ${TRANSPARENCY_WAYBAR}%" "level_menu waybar 'Transparencia · Barra'"
    menu_add "󰈆  Rofi       · ${TRANSPARENCY_ROFI}%"   "level_menu rofi 'Transparencia · Rofi'"
    menu_add "󰤊  Ambos (mismo nivel)"                  "level_menu both 'Transparencia · Ambos'"
    menu_add "󰅖  Volver"                               "@back"
    menu_run "Transparencia" "0% = opaco · 100% = invisible"
}

level_menu() {
    local target="$1" prompt="$2"
    menu_reset
    menu_add "Sólida (0%)"    "core transparency $target 0"
    menu_add "Ligera (25%)"   "core transparency $target 25"
    menu_add "Media (50%)"    "core transparency $target 50"
    menu_add "Notable (70%)"  "core transparency $target 70"
    menu_add "Vaporosa (85%)" "core transparency $target 85"
    menu_add "󰅖  Volver"       "@back"
    menu_run "$prompt"
}

# ----------------------------------------------------------------- Pantalla
display_menu() {
    load_state
    menu_reset
    menu_add "󰃞  Brillo +5%"                            "core display brightness-up"
    menu_add "󰃟  Brillo -5%"                            "core display brightness-down"
    menu_add "󰍹  Resolución y escala (nwg-displays)"    "core display displays"
    menu_add "󰔎  Luz nocturna (on/off)"                 "core display nightlight"
    menu_add "󰈈  Caféína (keep awake) · $CAFFEINE"      "core display caffeine"
    menu_add "󰑓  Recargar monitores"                    "core display reload"
    menu_add "󰅖  Volver"                                "@back"
    menu_run "Pantalla"
}

# ---------------------------------------------------------- Red y Bluetooth
network_menu() {
    load_state
    menu_reset
    menu_add "󰖩  WiFi (rofi)"                   "core network wifi"
    menu_add "󰂯  Bluetooth"                     "core network bluetooth"
    menu_add "󰈀  Conexiones de red (editor)"    "core network editor"
    menu_add "󰅖  Volver"                        "@back"
    menu_run "Red y Bluetooth" "$NETWORK_STATE"
}

# -------------------------------------------------------------------- Audio
audio_menu() {
    load_state
    menu_reset
    menu_add "󰕾  Abrir mezclador (pavucontrol)" "core audio mixer"
    menu_add "󰝝  Volumen +5%"                   "core audio up"
    menu_add "󰝞  Volumen -5%"                   "core audio down"
    menu_add "󰖁  Silenciar salida"              "core audio mute"
    menu_add "󰍬  Silenciar micrófono"           "core audio mic-mute"
    menu_add "󰅖  Volver"                        "@back"
    menu_run "Audio" "Volumen: $VOLUME"
}

# ------------------------------------------------------------ Notificaciones
notifications_menu() {
    load_state
    menu_reset
    menu_add "󰂚  No molestar (actual: $DND)" "core notifications dnd"
    menu_add "󰎟  Descartar todas"            "core notifications dismiss-all"
    menu_add "󰃷  Ver historial"               "core notifications restore"
    menu_add "󰑓  Reiniciar notificaciones"    "core notifications restart"
    menu_add "󰅖  Volver"                     "@back"
    menu_run "Notificaciones"
}

# ------------------------------------------------------------------ Teclado
keyboard_menu() {
    menu_reset
    menu_add "Español (Latam)" "core keyboard es"
    menu_add "English (US)"    "core keyboard us"
    menu_add "󰅖  Volver"        "@back"
    menu_run "Teclado" "Cambiar layout del teclado"
}

# --------------------------------------------------------- Atajos y sistema
system_menu() {
    load_state
    menu_reset
    menu_add "󰌌  Ver atajos de teclado"                  "core system keybinds"
    menu_add "󰈀  Cambiar layout del teclado"             "keyboard_menu"
    menu_add "󰋼  Información del sistema (fastfetch)"    "core system fastfetch"
    menu_add "󰢮  Monitor de recursos (btop)"             "core system btop"
    menu_add "󰚰  Actualizar sistema (paru -Syu)"         "core system update"
    menu_add "󰑓  Reconstruir miniaturas de wallpapers"   "core system thumbs"
    menu_add "󰅖  Volver"                                 "@back"
    menu_run "Atajos y sistema" "$HOSTNAME · $KERNEL"
}

# --------------------------------------------------------- Sesión y energía
session_menu() {
    menu_reset
    menu_add "󰌾  Bloquear pantalla" "core session lock"
    menu_add "󰒲  Suspender"         "confirm '¿Suspender el equipo?' && core session suspend"
    menu_add "󰍃  Cerrar sesión"     "confirm '¿Cerrar la sesión de Hyprland?' && core session logout"
    menu_add "󰜉  Reiniciar"         "confirm '¿Reiniciar el equipo?' && core session reboot"
    menu_add "󰐥  Apagar"            "confirm '¿Apagar el equipo?' && core session poweroff"
    menu_add "󰅖  Volver"            "@back"
    menu_run "Sesión y energía"
}

# --------------------------------------------------------------- Principal
main_menu() {
    while true; do
        load_state
        menu_reset
        menu_add "󰏘  Apariencia"                                 "appearance_menu"
        menu_add "󰍹  Pantalla"                                   "display_menu"
        menu_add "󰖩  Red y Bluetooth"                            "network_menu"
        menu_add "󰕾  Audio"                                      "audio_menu"
        menu_add "󰂚  Notificaciones  ·  No molestar: $DND"       "notifications_menu"
        menu_add "󰘕  Atajos y sistema"                           "system_menu"
        menu_add "󰐥  Sesión y energía"                           "session_menu"
        menu_add "󰒓  Abrir ajustes gráficos (GUI)"               "quickshell -n -c cristos-settings"
        menu_add "󰅖  Cerrar"                                     "@close"

        menu_run "Centro de control" "$(date '+%A, %d %B · %H:%M')"
        case $? in
            0) continue ;;
            *) exit 0 ;;
        esac
    done
}

# Acceso directo a una sección (compatibilidad con SETTINGS_SECTION).
if [ -n "${SETTINGS_SECTION:-}" ]; then
    case "$SETTINGS_SECTION" in
        appearance) appearance_menu ;;
        transparency) transparency_menu ;;
        display) display_menu ;;
        network) network_menu ;;
        audio) audio_menu ;;
        notifications) notifications_menu ;;
        system) system_menu ;;
        session) session_menu ;;
        keyboard) keyboard_menu ;;
        *) main_menu ;;
    esac
    exit 0
fi

main_menu
