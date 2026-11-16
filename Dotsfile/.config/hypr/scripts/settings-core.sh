#!/usr/bin/env bash
# settings-core.sh — lógica del centro de control de Hypr-CristOS.
#
# No dibuja nada: solo expone estado (`state`, `get`) y acciones. Cualquier
# frontend (rofi, quickshell, un keybind, waybar) puede usarlo sin duplicar
# la lógica. Ver `settings-core.sh help`.
set -u

CONF="$HOME/.config/matugen/settings.conf"
ROFI_COLORS="$HOME/.config/rofi/colors.rasi"
DEFAULT_WALL="$HOME/Pictures/Wallpapers/astralgrave_purple.png"
WAYBAR_DIR="$HOME/.config/waybar"
TRANSPARENCY_CONF="$HOME/.config/transparency.conf"
NIGHTLIGHT_STATE="/tmp/hyprsunset_clicked_state"
HYPR_DIR="$HOME/.config/hypr"

MODE="dark"
SCHEME="scheme-tonal-spot"
[ -f "$CONF" ] && source "$CONF"

# ------------------------------------------------------------------ helpers
notify() {
    local app="$1" title="$2" body="${3:-}"
    if [ -n "$body" ]; then
        notify-send -a "$app" "$title" "$body" 2>/dev/null || true
    else
        notify-send -a "$app" "$title" 2>/dev/null || true
    fi
}

current_wall() {
    local w
    w="$(cat "$HOME/.cache/quickshell/hyprquickpaper/.current" 2>/dev/null)"
    [ -n "$w" ] && [ -f "$w" ] || w="$DEFAULT_WALL"
    printf '%s' "$w"
}

dnd_state() {
    if [ "$("$HYPR_DIR/scripts/notifications.sh" status)" = on ]; then
        echo "Sí"
    else
        echo "No"
    fi
}

audio_state() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | sed 's/Volume: //'
}

caffeine_state() {
    "$HYPR_DIR/scripts/caffeine.sh" status 2>/dev/null || echo "Desactivada"
}

bar_theme_current() {
    "$WAYBAR_DIR/bar-switch.sh" current 2>/dev/null || echo "actual"
}

bar_theme_list_json() {
    "$WAYBAR_DIR/bar-switch.sh" list 2>/dev/null \
        | sed 's/^● //; s/^  //' \
        | jq -R -s 'split("\n") | map(select(length > 0))'
}

bar_mode_current() {
    "$WAYBAR_DIR/bar-mode.sh" status 2>/dev/null || echo "complete"
}

clock_format() {
    "$WAYBAR_DIR/clock-format.sh" current 2>/dev/null
}

clock_label() {
    case "$(clock_format)" in
        '{:%H:%M}')            echo "24 h" ;;
        '{:%H:%M:%S}')         echo "24 h con segundos" ;;
        '{:%I:%M %p}')         echo "12 h" ;;
        '{:%I:%M:%S %p}')      echo "12 h con segundos" ;;
        '{:%a %d %b · %H:%M}') echo "fecha y hora" ;;
        '{:%a %d %b}')         echo "solo fecha" ;;
        *)                     echo "personalizado" ;;
    esac
}

nightlight_state() {
    [ "$(cat "$NIGHTLIGHT_STATE" 2>/dev/null || echo 0)" = "1" ] && echo "on" || echo "off"
}

transparency_level() {
    local key="$1" def="$2"
    awk -F= -v k="$key" '$1==k{print $2}' "$TRANSPARENCY_CONF" 2>/dev/null | head -1 | grep . || printf '%s' "$def"
}

network_state() {
    nmcli -t -f GENERAL.STATE dev show 2>/dev/null | head -1 | cut -d: -f2
}

# ------------------------------------------------------------------- estado
print_state() {
    local key value
    while IFS='=' read -r key value; do
        printf '%s=%q\n' "$key" "$value"
    done <<EOF
MODE=$MODE
SCHEME_NAME=${SCHEME#scheme-}
DND=$(dnd_state)
VOLUME=$(audio_state)
CAFFEINE=$(caffeine_state)
WALL=$(current_wall)
WALL_NAME=$(basename "$(current_wall)")
BAR_THEME=$(bar_theme_current)
BAR_MODE=$(bar_mode_current)
CLOCK_LABEL=$(clock_label)
NIGHTLIGHT=$(nightlight_state)
TRANSPARENCY_WAYBAR=$(transparency_level WAYBAR 70)
TRANSPARENCY_ROFI=$(transparency_level ROFI 15)
NETWORK_STATE=$(network_state)
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
EOF
}

get_value() {
    local key="$1" line
    while IFS= read -r line; do
        case "$line" in
            "${key}="*) eval "printf '%s' ${line#*=}" ; return 0 ;;
        esac
    done < <(print_state)
    echo "clave desconocida: $key" >&2
    return 1
}

# Estado en JSON para frontends gráficos (quickshell, waybar, etc.).
print_state_json() {
    jq -n \
        --arg mode "$MODE" \
        --arg scheme "${SCHEME#scheme-}" \
        --arg dnd "$(dnd_state)" \
        --arg volume "$(audio_state)" \
        --arg caffeine "$(caffeine_state)" \
        --arg wall "$(current_wall)" \
        --arg wallName "$(basename "$(current_wall)")" \
        --arg barTheme "$(bar_theme_current)" \
        --arg barMode "$(bar_mode_current)" \
        --arg clockLabel "$(clock_label)" \
        --arg nightlight "$(nightlight_state)" \
        --arg networkState "$(network_state)" \
        --arg hostname "$(hostname)" \
        --arg kernel "$(uname -r)" \
        --argjson transparencyWaybar "$(transparency_level WAYBAR 70)" \
        --argjson transparencyRofi "$(transparency_level ROFI 15)" \
        --argjson barThemes "$(bar_theme_list_json)" \
        '{
            mode: $mode,
            scheme: $scheme,
            dnd: $dnd,
            volume: $volume,
            caffeine: $caffeine,
            wall: $wall,
            wallName: $wallName,
            barTheme: $barTheme,
            barMode: $barMode,
            clockLabel: $clockLabel,
            nightlight: $nightlight,
            transparencyWaybar: $transparencyWaybar,
            transparencyRofi: $transparencyRofi,
            networkState: $networkState,
            hostname: $hostname,
            kernel: $kernel,
            barThemes: $barThemes
        }'
}

# ------------------------------------------------------------------- temas
theme_apply() {
    printf 'MODE=%s\nSCHEME=%s\n' "$MODE" "$SCHEME" > "$CONF"
    if matugen image "$(current_wall)" -m "$MODE" -t "$SCHEME" --prefer saturation >>"$HOME/.cache/matugen.log" 2>&1; then
        local color
        color=$(grep -m1 '^    primary:' "$ROFI_COLORS" 2>/dev/null | awk '{print $2}')
        notify "Matugen" "Tema actualizado" "Modo: $MODE · Esquema: ${SCHEME#scheme-} · ${color:-ok}"
    else
        notify "Matugen" "Matugen falló" "Revisa ~/.cache/matugen.log"
        return 1
    fi
    pkill -SIGUSR2 -x waybar 2>/dev/null
}

theme_mode() {
    case "${1:-}" in
        dark|light) MODE="$1" ;;
        *) echo "uso: theme mode <dark|light>" >&2; return 1 ;;
    esac
    theme_apply
}

theme_scheme() {
    [ -n "${1:-}" ] || { echo "uso: theme scheme <nombre>" >&2; return 1; }
    SCHEME="scheme-${1#scheme-}"
    theme_apply
}

# ------------------------------------------------------------------- barra
bar_reload() {
    pkill -x waybar 2>/dev/null
    sleep 0.4
    setsid -f waybar >/dev/null 2>&1
}

bar_action() {
    case "${1:-}" in
        reload) bar_reload ;;
        mode) "$WAYBAR_DIR/bar-mode.sh" toggle ;;
        theme) "$WAYBAR_DIR/bar-switch.sh" theme "${2:-}" ;;
        theme-restore) "$WAYBAR_DIR/bar-switch.sh" restore ;;
        theme-list) "$WAYBAR_DIR/bar-switch.sh" list ;;
        *) echo "uso: bar <reload|mode|theme N|theme-restore|theme-list>" >&2; return 1 ;;
    esac
}

# ------------------------------------------------------------------- reloj
clock_action() {
    case "${1:-}" in
        preset) "$WAYBAR_DIR/clock-format.sh" preset "${2:-}" ;;
        set) "$WAYBAR_DIR/clock-format.sh" set "${2:-}" ;;
        *) echo "uso: clock <preset N|set FMT>" >&2; return 1 ;;
    esac
    notify "Waybar" "Formato de hora" "$(clock_label)"
}

# ------------------------------------------------------------ transparencia
transparency_action() {
    local target="${1:-}" level="${2:-}"
    case "$target" in
        waybar|rofi|both) ;;
        *) echo "uso: transparency <waybar|rofi|both> <0-95>" >&2; return 1 ;;
    esac
    [ -n "$level" ] || { echo "falta el nivel (0-95)" >&2; return 1; }
    "$HYPR_DIR/scripts/transparency.sh" "$target" "$level"
    case "$target" in
        waybar) notify "Transparencia" "Barra" "Nivel: ${level}%" ;;
        rofi)   notify "Transparencia" "Rofi" "Nivel: ${level}%" ;;
        both)   notify "Transparencia" "Barra y Rofi" "Nivel: ${level}%" ;;
    esac
}

# ----------------------------------------------------------------- pantalla
display_action() {
    case "${1:-}" in
        brightness-up) swayosd-client --brightness raise ;;
        brightness-down) swayosd-client --brightness lower ;;
        nightlight)
            if [ "$(nightlight_state)" = "on" ]; then
                hyprctl hyprsunset identity >/dev/null 2>&1
                echo 0 > "$NIGHTLIGHT_STATE"
                notify "Luz nocturna" "Desactivada"
            else
                hyprctl hyprsunset temperature 4000 >/dev/null 2>&1
                echo 1 > "$NIGHTLIGHT_STATE"
                notify "Luz nocturna" "Activada (4000K)"
            fi
            pkill -RTMIN+8 -x waybar 2>/dev/null
            ;;
        caffeine) "$HYPR_DIR/scripts/caffeine.sh" toggle ;;
        reload) hyprctl reload >/dev/null ;;
        displays) setsid -f nwg-displays ;;
        *) echo "uso: display <brightness-up|brightness-down|nightlight|caffeine|reload|displays>" >&2; return 1 ;;
    esac
}

# ------------------------------------------------------------------- audio
audio_action() {
    case "${1:-}" in
        mixer) setsid -f pavucontrol ;;
        up) swayosd-client --output-volume raise ;;
        down) swayosd-client --output-volume lower ;;
        set)
            [[ "${2:-}" =~ ^[0-9]+$ ]] || { echo "uso: audio set <0-100>" >&2; return 1; }
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "$(( $2 > 100 ? 100 : $2 ))%"
            ;;
        mute) swayosd-client --output-volume mute-toggle ;;
        mic-mute) swayosd-client --input-volume mute-toggle ;;
        *) echo "uso: audio <mixer|up|down|set N|mute|mic-mute>" >&2; return 1 ;;
    esac
}

# ----------------------------------------------------------- notificaciones
notifications_action() {
    case "${1:-}" in
        dnd)
            "$HYPR_DIR/scripts/notifications.sh" toggle >/dev/null
            notify "Notificaciones" "No molestar: $(dnd_state)"
            ;;
        dismiss-all) "$HYPR_DIR/scripts/notifications.sh" clear >/dev/null 2>&1 ;;
        restore) "$HYPR_DIR/scripts/notifications.sh" show >/dev/null 2>&1 ;;
        restart)
            systemctl --user restart cristos-notifications.service
            ;;
        *) echo "uso: notifications <dnd|dismiss-all|restore|restart>" >&2; return 1 ;;
    esac
}

# ------------------------------------------------------------ red y bluetooth
network_action() {
    case "${1:-}" in
        wifi) "$HOME/.config/rofi/wifi/wifi.sh" ;;
        bluetooth) "$HOME/.config/rofi/settings/bluetooth.sh" ;;
        editor) setsid -f nm-connection-editor ;;
        *) echo "uso: network <wifi|bluetooth|editor>" >&2; return 1 ;;
    esac
}

# ------------------------------------------------------------------ teclado
keyboard_action() {
    local idx label device
    case "${1:-}" in
        es|español|latam) idx=0; label="Español (Latam)" ;;
        us|english|en)    idx=1; label="English (US)" ;;
        *) echo "uso: keyboard <es|us>" >&2; return 1 ;;
    esac
    device=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[] | select(.main == true) | .name')
    [ -n "$device" ] || { notify "Teclado" "No se encontró el teclado principal"; return 1; }
    hyprctl switchxkblayout "$device" "$idx"
    notify "Teclado" "Layout cambiado" "$label"
}

# ----------------------------------------------------------------- sistema
system_action() {
    case "${1:-}" in
        keybinds) setsid -f foot -e sh -c 'less -R "$HOME/.config/hypr/KEYBINDINGS-CristOS.md"' ;;
        fastfetch) setsid -f foot -e sh -c 'fastfetch; echo; read -rp "Enter para cerrar..."' ;;
        btop) setsid -f foot -e btop ;;
        update) setsid -f foot -e paru -Syu ;;
        thumbs) bash "$HOME/.config/quickshell/hyprquickpaper/cache.sh" "$HOME/.config/quickshell/hyprquickpaper" >/dev/null 2>&1 ;;
        *) echo "uso: system <keybinds|fastfetch|btop|update|thumbs>" >&2; return 1 ;;
    esac
}

# ------------------------------------------------------------------ sesión
session_action() {
    case "${1:-}" in
        lock) setsid -f hyprlock ;;
        suspend) systemctl suspend ;;
        logout) hyprctl dispatch 'hl.dsp.exit()' ;;
        reboot) systemctl reboot ;;
        poweroff) systemctl poweroff ;;
        *) echo "uso: session <lock|suspend|logout|reboot|poweroff>" >&2; return 1 ;;
    esac
}

wallpaper_action() {
    case "${1:-picker}" in
        picker) setsid -f quickshell -c hyprquickpaper ;;
        *) echo "uso: wallpaper [picker]" >&2; return 1 ;;
    esac
}

reload_hyprland() {
    hyprctl reload >/dev/null
}

# ------------------------------------------------------------------- ayuda
usage() {
    cat <<'EOF'
settings-core.sh — lógica del centro de control (sin interfaz)

ESTADO
  state                     imprime todas las claves como CLAVE=valor (shell)
  get <clave>               imprime una clave (MODE, SCHEME_NAME, DND, VOLUME,
                            CAFFEINE, WALL, WALL_NAME, BAR_THEME, BAR_MODE,
                            CLOCK_LABEL, NIGHTLIGHT, TRANSPARENCY_WAYBAR,
                            TRANSPARENCY_ROFI, NETWORK_STATE, HOSTNAME, KERNEL)

ACCIONES
  theme mode <dark|light>   guarda el modo y regenera el tema
  theme scheme <nombre>     guarda el esquema y regenera el tema
  theme regenerate          regenera el tema con el wallpaper actual
  bar reload                reinicia waybar
  bar mode                  alterna completa/módulos
  bar theme <nombre>        aplica un tema de barra
  bar theme-restore         restaura la barra original
  bar theme-list            lista los temas de barra (● = activo)
  clock preset <preset>     aplica un preset de hora y notifica
  clock set <formato>       aplica un formato strftime y notifica
  transparency <t> <nivel>  t = waybar|rofi|both, nivel = 0-95
  display brightness-up|brightness-down|nightlight|caffeine|reload|displays
  audio mixer|up|down|mute|mic-mute
  notifications dnd|dismiss-all|restore|restart
  network wifi|bluetooth|editor
  keyboard es|us
  system keybinds|fastfetch|btop|update|thumbs
  session lock|suspend|logout|reboot|poweroff
  wallpaper [picker]
EOF
}

# ------------------------------------------------------------------ dispatch
cmd="${1:-}"
shift 2>/dev/null || true
case "$cmd" in
    state) print_state ;;
    json) print_state_json ;;
    get) get_value "${1:-}" ;;
    theme)
        case "${1:-}" in
            mode) theme_mode "${2:-}" ;;
            scheme) theme_scheme "${2:-}" ;;
            regenerate) theme_apply ;;
            *) usage >&2; exit 1 ;;
        esac
        ;;
    bar) bar_action "$@" ;;
    clock) clock_action "$@" ;;
    transparency) transparency_action "$@" ;;
    display) display_action "$@" ;;
    audio) audio_action "$@" ;;
    notifications) notifications_action "$@" ;;
    network) network_action "$@" ;;
    keyboard) keyboard_action "$@" ;;
    system) system_action "$@" ;;
    session) session_action "$@" ;;
    wallpaper) wallpaper_action "$@" ;;
    reload) reload_hyprland ;;
    help|--help|-h|"") usage ;;
    *) echo "comando desconocido: $cmd" >&2; usage >&2; exit 1 ;;
esac
