#!/usr/bin/env bash
# bar-switch.sh — cambia entre los temas de ~/.config/waybar/theme-waybar/
#
# Copia TODO el contenido del tema a la raíz de ~/.config/waybar/ (config,
# style, scripts y carpetas auxiliares como Modules/), porque los configs
# referencian rutas absolutas tipo ~/.config/waybar/window.sh.
#
# Antes del primer cambio guarda la config actual en .theme-backup/ para poder
# volver con: bar-switch.sh restore
set -u

DIR="${WAYBAR_DIR:-$HOME/.config/waybar}"
THEMES="$DIR/theme-waybar"
STATE="$DIR/.theme"
BACKUP="$DIR/.theme-backup"
SELF="bar-switch.sh"

# Los temas basados en Omarchy usan $OMARCHY_PATH en sus exec.
export OMARCHY_PATH="${OMARCHY_PATH:-$DIR/omarchy}"

usage() {
    cat <<EOF
uso: $(basename "$0") <comando>

  list                 lista los temas (● = activo)
  theme <nombre>       aplica un tema y reinicia waybar
  current              muestra el tema activo ("actual" si es la raíz)
  backup               guarda la config actual en .theme-backup/
  restore              restaura la config guardada con backup
EOF
}

current() {
    local t
    t="$(cat "$STATE" 2>/dev/null)"
    if [ -n "$t" ] && [ -d "$THEMES/$t" ]; then
        printf '%s' "$t"
    else
        printf 'actual'
    fi
}

valid_theme() {
    [ -n "${1:-}" ] && [ -d "$THEMES/$1" ] \
        && [ -f "$THEMES/$1/config.jsonc" ] && [ -f "$THEMES/$1/style.css" ]
}

list_themes() {
    local cur t
    cur="$(current)"
    while IFS= read -r t; do
        valid_theme "$t" || continue
        if [ "$t" = "$cur" ]; then
            printf '● %s\n' "$t"
        else
            printf '  %s\n' "$t"
        fi
    done < <(printf '%s\n' $(ls -1 "$THEMES" 2>/dev/null) | sort -V)
}

do_backup() {
    [ -d "$BACKUP" ] && return 0
    mkdir -p "$BACKUP"
    cp -a "$DIR"/config.jsonc "$DIR"/style.css "$DIR"/style.*.css "$BACKUP"/ 2>/dev/null
    local f
    for f in "$DIR"/*.sh; do
        [ -f "$f" ] || continue
        [ "$(basename "$f")" = "$SELF" ] && continue
        cp -a "$f" "$BACKUP"/
    done
    [ -d "$DIR/scripts" ] && cp -a "$DIR/scripts" "$BACKUP"/ 2>/dev/null
    return 0
}

# Los indicadores de Omarchy se refrescan por señales (que aquí no existen).
# Se les añade "interval" en la copia de la raíz; los temas originales no se tocan.
patch_intervals() {
    local cfg="$DIR/config.jsonc"
    [ -f "$cfg" ] || return 0
    awk '
      /indicators\/(screen-recording|idle|notification-silencing)\.sh/ { inmod = 1 }
      inmod && /"interval"/ { inmod = 0; print; next }
      inmod && /^[[:space:]]*\},?[[:space:]]*$/ { inmod = 0; print; next }
      inmod && /"signal": *[0-9]+,/ {
          print
          match($0, /^[[:space:]]*/)
          ind = substr($0, 1, RLENGTH)
          print ind "\"interval\": 2,"
          inmod = 0
          next
      }
      { print }
    ' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
}

restart_waybar() {
    if pgrep -x waybar >/dev/null 2>&1; then
        pkill -x waybar 2>/dev/null
        # Espera a que termine la instancia anterior (máx. ~2 s).
        local i
        for i in $(seq 1 20); do
            pgrep -x waybar >/dev/null 2>&1 || break
            sleep 0.1
        done
    fi
    if command -v setsid >/dev/null 2>&1; then
        setsid -f waybar >"$DIR/.waybar.log" 2>&1
    else
        waybar >"$DIR/.waybar.log" 2>&1 &
    fi
    # Sondeo: algunos temas tardan en arrancar.
    local i found=0
    for i in $(seq 1 24); do
        if pgrep -x waybar >/dev/null 2>&1; then
            found=1
            break
        fi
        sleep 0.25
    done
    [ "$found" = "1" ] || return 1
    # Comprueba que no muera justo después de arrancar (p. ej. CSS roto).
    sleep 1
    pgrep -x waybar >/dev/null 2>&1
}

apply_theme() {
    local name="$1" src="$THEMES/$1"
    valid_theme "$name" || { echo "tema no válido: $name" >&2; exit 1; }

    do_backup

    cp -a "$src/." "$DIR/" || exit 1
    patch_intervals

    # Reaplica el nivel de transparencia guardado al estilo del tema.
    if [ -x "$HOME/.config/hypr/scripts/transparency.sh" ]; then
        "$HOME/.config/hypr/scripts/transparency.sh" waybar >/dev/null 2>&1 || true
    fi

    printf '%s\n' "$name" > "$STATE"

    if restart_waybar; then
        notify-send -a "Barra" "Tema aplicado" "$name" 2>/dev/null || true
    else
        # Waybar no arrancó: intento volver al respaldo si existe.
        if [ -d "$BACKUP" ] && [ -f "$BACKUP/config.jsonc" ]; then
            cp -f "$BACKUP/config.jsonc" "$DIR/config.jsonc"
            cp -f "$BACKUP/style.css" "$DIR/style.css" 2>/dev/null
            rm -f "$STATE"
            restart_waybar || true
            notify-send -a "Barra" -u critical "Tema falló" "$name — se restauró el anterior" 2>/dev/null || true
        else
            notify-send -a "Barra" -u critical "Tema falló" "$name — Waybar no arrancó" 2>/dev/null || true
        fi
        exit 1
    fi
}

restore_backup() {
    [ -d "$BACKUP" ] || { echo "no hay respaldo en $BACKUP" >&2; exit 1; }
    cp -f "$BACKUP"/config.jsonc "$DIR/config.jsonc" 2>/dev/null
    cp -f "$BACKUP"/style.css "$DIR/style.css" 2>/dev/null
    cp -f "$BACKUP"/style.*.css "$DIR"/ 2>/dev/null
    local f
    for f in "$BACKUP"/*.sh; do
        [ -f "$f" ] || continue
        [ "$(basename "$f")" = "$SELF" ] && continue
        cp -f "$f" "$DIR"/
    done
    [ -d "$BACKUP/scripts" ] && cp -a "$BACKUP/scripts/." "$DIR/scripts/" 2>/dev/null
    # Limpia helpers y carpetas que hayan añadido los temas.
    local f d b
    for f in "$DIR"/*.sh; do
        [ -f "$f" ] || continue
        b="$(basename "$f")"
        [ "$b" = "$SELF" ] && continue
        [ -f "$BACKUP/$b" ] || rm -f "$f"
    done
    for d in Modules ModulesCustom configs styles bottom; do
        [ -e "$BACKUP/$d" ] || rm -rf "$DIR/$d"
    done
    [ -f "$BACKUP/ModulesCustom.txt" ] || rm -f "$DIR/ModulesCustom.txt"
    rm -f "$STATE"
    # Reaplica la transparencia guardada a la config original.
    if [ -x "$HOME/.config/hypr/scripts/transparency.sh" ]; then
        "$HOME/.config/hypr/scripts/transparency.sh" waybar >/dev/null 2>&1 || true
    fi
    restart_waybar || true
    notify-send -a "Barra" "Config restaurada" "Volviste a la barra original" 2>/dev/null || true
}

case "${1:-}" in
    list)    list_themes ;;
    themes)  list_themes ;;
    current|status) current; echo ;;
    theme)
        [ -n "${2:-}" ] || { usage >&2; exit 1; }
        apply_theme "$2"
        ;;
    backup)  do_backup && echo "$BACKUP" ;;
    restore) restore_backup ;;
    -h|--help|help|"") usage ;;
    *) usage >&2; exit 1 ;;
esac
