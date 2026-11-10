#!/usr/bin/env bash
# Centro de control de Hypr-CristOS (rofi)

DIR="$HOME/.config/rofi/settings"
THEME="$DIR/style.rasi"
CONF="$HOME/.config/matugen/settings.conf"
DEFAULT_WALL="$HOME/Pictures/Wallpapers/astralgrave/astralgrave_purple.png"

MODE="dark"
SCHEME="scheme-tonal-spot"
[ -f "$CONF" ] && source "$CONF"

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
    local ans
    ans=$(printf 'Sí\nNo' | menu "Confirmar" "$msg")
    [ "$ans" = "Sí" ]
}

current_wall() {
    local w
    w="$(cat "$HOME/.cache/quickshell/hyprquickpaper/.current" 2>/dev/null)"
    [ -f "$w" ] || w="$DEFAULT_WALL"
    printf '%s' "$w"
}

save_state() {
    printf 'MODE=%s\nSCHEME=%s\n' "$MODE" "$SCHEME" > "$CONF"
}

apply_theme() {
    save_state
    if matugen image "$(current_wall)" -m "$MODE" -t "$SCHEME" --prefer saturation >>"$HOME/.cache/matugen.log" 2>&1; then
        local color
        color=$(grep -m1 '^    primary:' "$HOME/.config/rofi/colors.rasi" | awk '{print $2}')
        notify-send -a "Matugen" "Tema actualizado" "Modo: $MODE · Esquema: ${SCHEME#scheme-} · ${color:-ok}"
    else
        notify-send -a "Matugen" -u critical "Matugen falló" "Revisa ~/.cache/matugen.log"
    fi
    pkill -SIGUSR2 waybar 2>/dev/null
}

dnd_state() {
    if makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; then echo "Sí"; else echo "No"; fi
}

audio_state() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | sed 's/Volume: //'
}

caffeine_state() {
    "$HOME/.config/hypr/scripts/caffeine.sh" status 2>/dev/null || echo "Desactivada"
}

# ------------------------------------------------------------ Transparencia
pick_transparency_level() {
    local prompt="$1" sel
    sel=$(printf '%s\n' \
        "Sólida (0%)" \
        "Ligera (25%)" \
        "Media (50%)" \
        "Notable (70%)" \
        "Vaporosa (85%)" | menu "$prompt")
    case "$sel" in
        "Sólida (0%)")   echo 0 ;;
        "Ligera (25%)")  echo 25 ;;
        "Media (50%)")   echo 50 ;;
        "Notable (70%)") echo 70 ;;
        "Vaporosa (85%)") echo 85 ;;
    esac
}

transparency() {
    local waybar_level rofi_level choice level
    waybar_level=$(awk -F= '/^WAYBAR=/{print $2}' "$HOME/.config/transparency.conf" 2>/dev/null)
    rofi_level=$(awk -F= '/^ROFI=/{print $2}' "$HOME/.config/transparency.conf" 2>/dev/null)

    choice=$(printf '%s\n' \
        "󰂔  Barra      · ${waybar_level:-70}%" \
        "󰈆  Rofi       · ${rofi_level:-15}%" \
        "󰤊  Ambos (mismo nivel)" \
        "󰅖  Volver" | menu "Transparencia" "0% = opaco · 100% = invisible")

    case "$choice" in
        *Barra*)
            level=$(pick_transparency_level "Transparencia · Barra")
            [ -n "$level" ] || return
            "$HOME/.config/hypr/scripts/transparency.sh" waybar "$level"
            notify-send -a "Transparencia" "Barra" "Nivel: ${level}%"
            ;;
        *Rofi*)
            level=$(pick_transparency_level "Transparencia · Rofi")
            [ -n "$level" ] || return
            "$HOME/.config/hypr/scripts/transparency.sh" rofi "$level"
            notify-send -a "Transparencia" "Rofi" "Nivel: ${level}%"
            ;;
        *Ambos*)
            level=$(pick_transparency_level "Transparencia · Ambos")
            [ -n "$level" ] || return
            "$HOME/.config/hypr/scripts/transparency.sh" both "$level"
            notify-send -a "Transparencia" "Barra y Rofi" "Nivel: ${level}%"
            ;;
    esac
}


# ---------------------------------------------------------------- Apariencia
appearance() {
    while true; do
        local choice mode_label="Oscuro" bar_label="completa"
        [ "$MODE" = "light" ] && mode_label="Claro"
        [ "$("$HOME/.config/waybar/bar-mode.sh" status 2>/dev/null)" = "modular" ] && bar_label="modular"
        choice=$(printf '%s\n' \
            "󰸉  Cambiar wallpaper" \
            "󰔎  Modo: $mode_label" \
            "󰏘  Esquema de color: ${SCHEME#scheme-}" \
            "󰍜  Barra: $bar_label (completa/módulos)" \
            "󰂔  Transparencia (barra / rofi)" \
            "󰑓  Regenerar tema desde el wallpaper" \
            "󰒓  Reiniciar Waybar" \
            "󰑓  Recargar Hyprland" \
            "󰅖  Volver" | menu "Apariencia" "Wallpaper: $(basename "$(current_wall)")")
        case "$choice" in
            *wallpaper*) setsid -f quickshell -c hyprquickpaper ;;
            *"Modo:"*)
                local m
                m=$(printf 'Oscuro\nClaro' | menu "Modo de color")
                case "$m" in
                    Oscuro) MODE="dark" ;;
                    Claro)  MODE="light" ;;
                    *) continue ;;
                esac
                apply_theme
                ;;
            *"Esquema de color"*)
                local s
                s=$(printf '%s\n' tonal-spot vibrant expressive fidelity content neutral monochrome rainbow fruit-salad smart | menu "Esquema de color" "Actual: ${SCHEME#scheme-}")
                [ -n "$s" ] || continue
                SCHEME="scheme-$s"
                apply_theme
                ;;
            *Regenerar*) apply_theme ;;
            *"Barra:"*) "$HOME/.config/waybar/bar-mode.sh" toggle ;;
            *Transparencia*) transparency ;;
            *Waybar*)
                pkill -x waybar 2>/dev/null
                sleep 0.4
                setsid -f waybar >/dev/null 2>&1
                ;;
            *Hyprland*) hyprctl reload >/dev/null ;;
            *Volver*) return ;;
            *) return ;;
        esac
    done
}

# ------------------------------------------------------------------ Pantalla
display() {
    local choice
    choice=$(printf '%s\n' \
        "󰃞  Brillo +5%" \
        "󰃟  Brillo -5%" \
        "󰍹  Resolución y escala (nwg-displays)" \
        "󰔎  Luz nocturna (on/off)" \
        "󰈈  Caféína (keep awake) · $(caffeine_state)" \
        "󰑓  Recargar monitores" \
        "󰅖  Volver" | menu "Pantalla")
    case "$choice" in
        *"Brillo +"*) swayosd-client --brightness raise ;;
        *"Brillo -"*) swayosd-client --brightness lower ;;
        *nwg-displays*|*Resolución*) setsid -f nwg-displays ;;
        *"Luz nocturna"*)
            state_file="/tmp/hyprsunset_clicked_state"
            state=$(cat "$state_file" 2>/dev/null || echo 0)
            if [ "$state" = "1" ]; then
                hyprctl hyprsunset identity >/dev/null 2>&1
                echo 0 > "$state_file"
                notify-send "Luz nocturna" "Desactivada"
            else
                hyprctl hyprsunset temperature 4000 >/dev/null 2>&1
                echo 1 > "$state_file"
                notify-send "Luz nocturna" "Activada (4000K)"
            fi
            pkill -RTMIN+8 waybar 2>/dev/null
            ;;
        *Caféína*) ~/.config/hypr/scripts/caffeine.sh toggle ;;
        *Recargar*) hyprctl reload >/dev/null ;;
        *Volver*) return ;;
    esac
}

# ---------------------------------------------------------- Red y Bluetooth
network() {
    local choice
    choice=$(printf '%s\n' \
        "󰖩  WiFi (rofi)" \
        "󰂯  Bluetooth" \
        "󰈀  Conexiones de red (editor)" \
        "󰅖  Volver" | menu "Red y Bluetooth" "$(nmcli -t -f GENERAL.STATE dev show 2>/dev/null | head -1 | cut -d: -f2)")
    case "$choice" in
        *WiFi*) "$HOME/.config/rofi/wifi/wifi.sh" ;;
        *Bluetooth*) "$DIR/bluetooth.sh" ;;
        *Conexiones*|*editor*) setsid -f nm-connection-editor ;;
        *Volver*) return ;;
    esac
}

# --------------------------------------------------------------------- Audio
audio() {
    local choice
    choice=$(printf '%s\n' \
        "󰕾  Abrir mezclador (pavucontrol)" \
        "󰝝  Volumen +5%" \
        "󰝞  Volumen -5%" \
        "󰖁  Silenciar salida" \
        "󰍬  Silenciar micrófono" \
        "󰅖  Volver" | menu "Audio" "Volumen: $(audio_state)")
    case "$choice" in
        *pavucontrol*|*mezclador*) setsid -f pavucontrol ;;
        *"Volumen +"*) swayosd-client --output-volume raise ;;
        *"Volumen -"*) swayosd-client --output-volume lower ;;
        *"Silenciar salida"*) swayosd-client --output-volume mute-toggle ;;
        *micrófono*) swayosd-client --input-volume mute-toggle ;;
        *Volver*) return ;;
    esac
}

# ------------------------------------------------------------ Notificaciones
notifications() {
    local choice
    choice=$(printf '%s\n' \
        "󰂚  No molestar (actual: $(dnd_state))" \
        "󰎟  Descartar todas" \
        "󰃷  Restaurar última" \
        "󰑓  Reiniciar mako" \
        "󰅖  Volver" | menu "Notificaciones")
    case "$choice" in
        *"No molestar"*)
            makoctl mode -t do-not-disturb >/dev/null 2>&1
            notify-send "Notificaciones" "No molestar: $(dnd_state)"
            ;;
        *Descartar*) makoctl dismiss -a >/dev/null 2>&1 ;;
        *Restaurar*) makoctl restore >/dev/null 2>&1 ;;
        *Reiniciar*) pkill -x mako 2>/dev/null; sleep 0.4; setsid -f mako >/dev/null 2>&1 ;;
        *Volver*) return ;;
    esac
}

# ---------------------------------------------------------- Teclado
keyboard() {
    local choice device
    choice=$(printf '%s\n' \
        "Español (Latam)" \
        "English (US)" \
        "󰅖  Volver" | menu "Teclado" "Cambiar layout del teclado")
    case "$choice" in
        *"Español"*)
            device=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[] | select(.main == true) | .name')
            if [ -n "$device" ]; then
                hyprctl switchxkblayout "$device" 0
                notify-send -a "Teclado" "Layout cambiado" "Español (Latam)"
            fi
            ;;
        *"English"*)
            device=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[] | select(.main == true) | .name')
            if [ -n "$device" ]; then
                hyprctl switchxkblayout "$device" 1
                notify-send -a "Teclado" "Layout cambiado" "English (US)"
            fi
            ;;
        *Volver*) return ;;
    esac
}

# --------------------------------------------------------- Atajos y sistema
system() {
    local choice
    choice=$(printf '%s\n' \
        "󰌌  Ver atajos de teclado" \
        "󰈀  Cambiar layout del teclado" \
        "󰋼  Información del sistema (fastfetch)" \
        "󰢮  Monitor de recursos (btop)" \
        "󰚰  Actualizar sistema (paru -Syu)" \
        "󰑓  Reconstruir miniaturas de wallpapers" \
        "󰅖  Volver" | menu "Atajos y sistema" "$(hostname) · $(uname -r)")
    case "$choice" in
        *atajos*) setsid -f foot -e sh -c 'less -R "$HOME/.config/hypr/KEYBINDINGS-CristOS.md"' ;;
        *"Cambiar layout"*) keyboard ;;
        *fastfetch*) setsid -f foot -e sh -c 'fastfetch; echo; read -rp "Enter para cerrar..."' ;;
        *btop*) setsid -f foot -e btop ;;
        *Actualizar*) setsid -f foot -e paru -Syu ;;
        *miniaturas*) bash "$HOME/.config/quickshell/hyprquickpaper/cache.sh" "$HOME/.config/quickshell/hyprquickpaper" >/dev/null 2>&1 ;;
    esac
}

# ------------------------------------------------------- Sesión y energía
session() {
    local choice
    choice=$(printf '%s\n' \
        "󰌾  Bloquear pantalla" \
        "󰒲  Suspender" \
        "󰍃  Cerrar sesión" \
        "󰜉  Reiniciar" \
        "󰐥  Apagar" \
        "󰅖  Volver" | menu "Sesión y energía")
    case "$choice" in
        *Bloquear*) setsid -f hyprlock ;;
        *Suspender*) confirm "¿Suspender el equipo?" && systemctl suspend ;;
        *"Cerrar sesión"*) confirm "¿Cerrar la sesión de Hyprland?" && hyprctl dispatch exit ;;
        *Reiniciar*) confirm "¿Reiniciar el equipo?" && systemctl reboot ;;
        *Apagar*) confirm "¿Apagar el equipo?" && systemctl poweroff ;;
        *Volver*) return ;;
    esac
}

# --------------------------------------------------------------- Principal
if [ -n "${SETTINGS_SECTION:-}" ]; then
    case "$SETTINGS_SECTION" in
        appearance) appearance ;;
        transparency) transparency ;;
        display) display ;;
        network) network ;;
        audio) audio ;;
        notifications) notifications ;;
        system) system ;;
        session) session ;;
        keyboard) keyboard ;;
    esac
    exit 0
fi

while true; do
    choice=$(printf '%s\n' \
        "󰏘  Apariencia" \
        "󰍹  Pantalla" \
        "󰖩  Red y Bluetooth" \
        "󰕾  Audio" \
        "󰂚  Notificaciones  ·  No molestar: $(dnd_state)" \
        "󰘕  Atajos y sistema" \
        "󰐥  Sesión y energía" \
        "󰅖  Cerrar" | menu "Centro de control" "$(date '+%A, %d %B · %H:%M')")

    case "$choice" in
        *Apariencia*) appearance ;;
        *Pantalla*) display ;;
        *"Red y Bluetooth"*) network ;;
        *Audio*) audio ;;
        *Notificaciones*) notifications ;;
        *"Atajos y sistema"*) system ;;
        *"Sesión y energía"*) session ;;
        *|*Cerrar*) exit 0 ;;
    esac
done