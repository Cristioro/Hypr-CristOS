#!/usr/bin/env python3
"""ws-scroll-daemon — cambia de escritorio con la rueda sobre los círculos.

Waybar 0.16 con GTK3 en Wayland descarta la mitad de los eventos de rueda
(los discretos marcados como emulados), así que el scroll del módulo de
workspaces solo funciona 4 de cada 8 notches. Este daemon lee directamente
los eventos REL_WHEEL de los ratones, comprueba que el cursor esté sobre la
zona central de la barra y ejecuta ws-scroll.sh, que hace el dispatch a
Hyprland. De este modo cada notch produce exactamente un cambio.

Uso:
    ws-scroll-daemon            # en segundo plano (autostart)
    WS_SCROLL_DEBUG=1 ws-scroll-daemon   # con trazas en stderr

Variables:
    WS_SCROLL_MARGIN  margen horizontal en px (def. 110; lo usa también el script)
    WS_SCROLL_DEBUG   trazas de depuración
"""

import fcntl
import json
import os
import select
import signal
import subprocess
import sys
import time

try:
    import evdev
    from evdev import ecodes
except ImportError:  # pragma: no cover
    sys.exit("ws-scroll-daemon: falta python-evdev")

SCRIPT = os.path.expanduser("~/.config/waybar/scripts/ws-scroll.sh")
MARGIN = int(os.environ.get("WS_SCROLL_MARGIN", "110"))
DEBUG = bool(os.environ.get("WS_SCROLL_DEBUG"))
RESCAN_INTERVAL = 1.0          # segundos entre escaneos de dispositivos
BAR_CACHE_TTL = 10.0           # geometría de la barra
CURSOR_CACHE_TTL = 0.5         # posición del cursor sin movimiento

_running = True
_bar_cache = (0.0, [])
_cursor = (0, 0)
_cursor_ts = 0.0
_cursor_dirty = True


def debug(*args):
    if DEBUG:
        print("ws-scroll-daemon:", *args, file=sys.stderr, flush=True)


def _hyprctl(*args):
    out = subprocess.run(
        ["hyprctl", *args, "-j"],
        capture_output=True,
        text=True,
        timeout=2,
        check=True,
    )
    return json.loads(out.stdout)


def refresh_signature():
    """Busca la instancia actual de Hyprland (por si el daemon sobrevive a un reinicio)."""
    runtime = os.environ.get("XDG_RUNTIME_DIR") or "/tmp"
    root = os.path.join(runtime, "hypr")
    try:
        candidates = [
            name
            for name in os.listdir(root)
            if os.path.exists(os.path.join(root, name, ".socket.sock"))
        ]
        if not candidates:
            return False
        newest = max(candidates, key=lambda name: os.path.getmtime(os.path.join(root, name)))
        if newest == os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"):
            return False
        os.environ["HYPRLAND_INSTANCE_SIGNATURE"] = newest
        debug("instancia Hyprland actualizada:", newest)
        return True
    except OSError:
        return False


def hyprctl(*args):
    """Ejecuta hyprctl con salida JSON y la devuelve parseada."""
    try:
        return _hyprctl(*args)
    except Exception:
        if refresh_signature():
            return _hyprctl(*args)
        raise


def bar_rects():
    """[(monitor, capa_waybar), ...] con caché para no consultar en cada notch."""
    global _bar_cache
    now = time.monotonic()
    ttl = BAR_CACHE_TTL if _bar_cache[1] else 1.0
    if now - _bar_cache[0] < ttl:
        return _bar_cache[1]

    try:
        monitors = hyprctl("monitors")
        layers = hyprctl("layers")
        rects = []
        for mon in monitors:
            levels = (layers.get(mon.get("name"), {}) or {}).get("levels") or {}
            bar = None
            for level in levels.values():
                for layer in level:
                    if layer.get("namespace") == "waybar":
                        bar = layer
                        break
                if bar is not None:
                    break
            if bar is not None:
                rects.append((mon, bar))
        _bar_cache = (now, rects)
        return rects
    except Exception as exc:  # hyprctl puede fallar durante un reload
        debug("bar_rects:", exc)
        return _bar_cache[1]


def cursor_pos():
    """Posición global del cursor, cacheada mientras no haya movimiento."""
    global _cursor, _cursor_ts, _cursor_dirty
    now = time.monotonic()
    if _cursor_dirty or now - _cursor_ts >= CURSOR_CACHE_TTL:
        j = hyprctl("cursorpos")
        _cursor = (int(j["x"]), int(j["y"]))
        _cursor_ts = now
        _cursor_dirty = False
    return _cursor


def in_zone():
    """True si el cursor está sobre los círculos (zona central de la barra)."""
    try:
        cx, cy = cursor_pos()
        for mon, bar in bar_rects():
            if not (mon["x"] <= cx < mon["x"] + mon["width"]):
                continue
            if not (mon["y"] <= cy < mon["y"] + mon["height"]):
                continue
            lx = cx - mon["x"]
            ly = cy - mon["y"]
            center = bar["x"] + bar["w"] / 2
            return abs(center - lx) <= MARGIN and bar["y"] <= ly < bar["y"] + bar["h"]
    except Exception as exc:
        debug("in_zone:", exc)
    return False


def fullscreen_active():
    """Evita cambiar de escritorio con la barra tapada por un fullscreen."""
    try:
        window = hyprctl("activewindow")
        return int(window.get("fullscreen", 0)) >= 2
    except Exception:
        return False


def handle_wheel(value):
    if value == 0:
        return
    if not in_zone():
        debug("rueda %+d ignorada (fuera de la zona)" % value)
        return
    if fullscreen_active():
        debug("rueda %+d ignorada (fullscreen)" % value)
        return
    direction = "down" if value < 0 else "up"
    debug("rueda %+d -> %s" % (value, direction))
    try:
        subprocess.run(
            [SCRIPT, direction],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=2,
            check=False,
        )
    except Exception as exc:
        debug("script:", exc)


def cap_codes(caps, ev_type):
    """Códigos de un tipo de evento, ignorando la info de ABS si la hay."""
    return [item[0] if isinstance(item, tuple) else item for item in caps.get(ev_type, [])]


def wheel_paths():
    """Rutas de dispositivos con rueda que no sean touchpads."""
    paths = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
            caps = dev.capabilities()
            dev.close()
        except OSError:
            continue

        if ecodes.REL_WHEEL not in cap_codes(caps, ecodes.EV_REL):
            continue

        # Los touchpads exponen ejes absolutos; los ratones no.
        abs_codes = cap_codes(caps, ecodes.EV_ABS)
        if any(
            code in abs_codes
            for code in (
                ecodes.ABS_X,
                ecodes.ABS_Y,
                ecodes.ABS_MT_POSITION_X,
                ecodes.ABS_MT_POSITION_Y,
            )
        ):
            continue

        paths.append(path)
    return paths


def _stop(_signum, _frame):
    global _running
    _running = False


def acquire_lock():
    runtime = os.environ.get("XDG_RUNTIME_DIR") or "/tmp"
    path = os.path.join(runtime, "ws-scroll-daemon-%d.lock" % os.getuid())
    fd = os.open(path, os.O_CREAT | os.O_RDWR, 0o600)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        os.close(fd)
        return None
    os.ftruncate(fd, 0)
    os.write(fd, str(os.getpid()).encode())
    return fd


def main():
    global _cursor_dirty

    lock = acquire_lock()
    if lock is None:
        debug("ya hay otra instancia en ejecución")
        return 0

    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGINT, _stop)

    devices = {}

    def refresh():
        wanted = set(wheel_paths())
        for path in list(devices):
            if path not in wanted:
                try:
                    devices.pop(path).close()
                except OSError:
                    pass
        for path in wanted:
            if path in devices:
                continue
            try:
                dev = evdev.InputDevice(path)
                os.set_blocking(dev.fd, False)
            except OSError as exc:
                debug("no se pudo abrir", path, exc)
                continue
            devices[path] = dev
            debug("dispositivo:", path, dev.name)

    refresh()
    next_scan = time.monotonic() + RESCAN_INTERVAL

    while _running:
        timeout = max(0.0, next_scan - time.monotonic())
        try:
            readable, _, _ = select.select(list(devices.values()), [], [], timeout)
        except (OSError, ValueError):
            readable = []

        if time.monotonic() >= next_scan:
            refresh()
            next_scan = time.monotonic() + RESCAN_INTERVAL

        for dev in readable:
            try:
                for event in dev.read():
                    if event.type != ecodes.EV_REL:
                        continue
                    if event.code in (ecodes.REL_X, ecodes.REL_Y):
                        _cursor_dirty = True
                    elif event.code == ecodes.REL_WHEEL and event.value:
                        handle_wheel(event.value)
            except BlockingIOError:
                pass
            except OSError:
                removed = devices.pop(dev.path, None)
                if removed is not None:
                    try:
                        removed.close()
                    except OSError:
                        pass

    for dev in devices.values():
        try:
            dev.close()
        except OSError:
            pass
    os.close(lock)
    return 0


if __name__ == "__main__":
    sys.exit(main())
