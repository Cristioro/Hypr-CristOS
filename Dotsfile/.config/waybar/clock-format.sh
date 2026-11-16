#!/usr/bin/env bash
# Cambia el formato del reloj de Waybar.
# Uso:
#   clock-format.sh current          # muestra el formato actual
#   clock-format.sh preset 24h       # aplica un preset
#   clock-format.sh set '{:%H:%M}'   # aplica un formato literal

set -u

CONFIG="$HOME/.config/waybar/config.jsonc"

get_format() {
    python3 - "$CONFIG" <<'PY'
import json, re, sys
text = open(sys.argv[1], encoding='utf-8').read()
m = re.search(r'"clock"\s*:\s*\{(.*?)\n\s*\}', text, re.S)
if not m:
    raise SystemExit(1)
f = re.search(r'"format"\s*:\s*("(?:[^"\\]|\\.)*")', m.group(1))
print(json.loads(f.group(1)) if f else "{:%H:%M}")
PY
}

set_format() {
    local fmt="$1"
    python3 - "$CONFIG" "$fmt" <<'PY'
import json, re, sys
path, fmt = sys.argv[1], sys.argv[2]

def set_format(path, fmt):
    text = open(path, encoding='utf-8').read()
    m = re.search(r'("clock"\s*:\s*\{)(.*?)(\n\s*\})', text, re.S)
    if not m:
        raise SystemExit("no se encontró el módulo clock")
    block = m.group(2)
    new_block, n = re.subn(
        r'("format"\s*:\s*)"(?:[^"\\]|\\.)*"',
        lambda mm: mm.group(1) + json.dumps(fmt, ensure_ascii=False),
        block,
        count=1,
    )
    if n == 0:
        raise SystemExit("no se encontró el campo format del reloj")
    new_text = text[:m.start(2)] + new_block + text[m.end(2):]
    open(path, 'w', encoding='utf-8').write(new_text)

set_format(sys.argv[1], sys.argv[2])
PY
}

reload_bar() {
    if pgrep -x waybar >/dev/null; then
        pkill -SIGUSR2 -x waybar 2>/dev/null || true
    else
        setsid -f waybar >/dev/null 2>&1
    fi
}

case "${1:-current}" in
    current)
        get_format
        ;;
    preset)
        case "${2:-}" in
            24h)        fmt='{:%H:%M}' ;;
            24h-seg)    fmt='{:%H:%M:%S}' ;;
            12h)        fmt='{:%I:%M %p}' ;;
            12h-seg)    fmt='{:%I:%M:%S %p}' ;;
            fecha-hora) fmt='{:%a %d %b · %H:%M}' ;;
            fecha)      fmt='{:%a %d %b}' ;;
            *)
                echo "presets: 24h | 24h-seg | 12h | 12h-seg | fecha-hora | fecha" >&2
                exit 1
                ;;
        esac
        set_format "$fmt" && reload_bar
        ;;
    set)
        [ $# -ge 2 ] || { echo "falta el formato" >&2; exit 1; }
        set_format "$2" && reload_bar
        ;;
    *)
        echo "uso: $0 current | preset <nombre> | set <formato>" >&2
        exit 1
        ;;
esac
