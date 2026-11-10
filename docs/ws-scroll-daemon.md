# ws-scroll-daemon

Cambia de **workspace con la rueda del ratón** cuando el cursor está sobre los
círculos de `hyprland/workspaces` de Waybar, sin que la rueda sobre otros
módulos (reproductor, volumen, etc.) cambie de escritorio.

Es un daemon pequeño en Python que lee los eventos `REL_WHEEL` directamente de
los ratones (`evdev`), comprueba si el cursor está en la zona central de la
barra y delega el cambio en `ws-scroll.sh`.

## ¿Por qué existe?

Waybar 0.16 (GTK3 + Wayland) descarta aproximadamente la mitad de los eventos
de rueda "emulados": el scroll del módulo de workspaces solo se mueve 4 de cada
8 notch. En lugar de pelear con el toolkit, este daemon lee el dispositivo de
entrada a bajo nivel y produce **exactamente un cambio por notch**.

La rueda del módulo de workspaces queda desactivada en `config.jsonc`
(`"enable-bar-scroll": false` y sin `on-scroll-*` en `hyprland/workspaces`),
de modo que no hay doble dispatch.

## Cómo funciona

```
rueda física
   │
   ▼
ws-scroll-daemon.py  ── lee REL_WHEEL de cada ratón (evdev)
   │  ¿cursor en la zona central de la barra?  (+ margen configurable)
   │  ¿hay una ventana en fullscreen?           → ignora
   ▼
ws-scroll.sh up|down ── verifica de nuevo la zona con hyprctl
   │
   ▼
hyprctl dispatch 'hl.dsp.focus({workspace = "m-1|m+1"})'
```

Detalles:

- **Zona**: franja horizontal centrada en la barra (`WS_SCROLL_MARGIN`, 110 px
  por defecto; `m+1` avanza, `m-1` retrocede).
- **Multi-monitor**: usa la geometría real de la capa `waybar` del monitor bajo
  el cursor (`hyprctl monitors -j` + `hyprctl layers -j`).
- **Fullscreen**: si la ventana activa está en fullscreen, ignora la rueda.
- **Hot-plug**: reescanea dispositivos cada segundo; detecta ratones nuevos.
- **Instancia única**: lock en `$XDG_RUNTIME_DIR/ws-scroll-daemon-<uid>.lock`.
- **Touchpads**: excluidos (se detectan por tener ejes `ABS_*`).

## Requisitos

- `python-evdev` (`pacman -S python-evdev`)
- `jq` y `hyprctl` (vienen con Hyprland)
- Acceso de lectura a `/dev/input/event*` (grupo `input`)

```bash
sudo usermod -aG input "$USER"   # cerrar sesión y volver a entrar
```

## Instalación

1. Copia los dos scripts:

```bash
install -Dm755 ws-scroll-daemon.py ~/.config/waybar/scripts/ws-scroll-daemon.py
install -Dm755 ws-scroll.sh        ~/.config/waybar/scripts/ws-scroll.sh
install -Dm755 ws-scroll-daemon    ~/.local/bin/ws-scroll-daemon
```

2. Arráncalo al iniciar la sesión. En `~/.config/hypr/config/autostart.lua`:

```lua
hl.spawn(os.getenv("HOME") .. "/.local/bin/ws-scroll-daemon")
```

3. Desactiva el scroll nativo de Waybar en `~/.config/waybar/config.jsonc`:

```jsonc
"hyprland/workspaces": {
  "enable-bar-scroll": false
}
```

## Uso

```bash
ws-scroll-daemon             # en segundo plano (autostart)
WS_SCROLL_DEBUG=1 ws-scroll-daemon   # trazas en stderr
ws-scroll.sh up              # probar el dispatch a mano
```

Variables:

| Variable | Defecto | Descripción |
|---|---|---|
| `WS_SCROLL_MARGIN` | `110` | Margen horizontal (px) alrededor del centro de la barra |
| `WS_SCROLL_DEBUG` | vacío | Activa trazas |
| `WS_SCROLL_LOG` | `/tmp/opencode/ws-scroll.log` | Log de `ws-scroll.sh` en modo debug |

## Desinstalar

```bash
pkill -f ws-scroll-daemon.py
rm ~/.config/waybar/scripts/ws-scroll-{daemon.py,sh} ~/.local/bin/ws-scroll-daemon
```

Y quita la línea de `autostart.lua`.

## Notas

- Solo cambia de workspace si el cursor está **sobre los círculos**; encima del
  resto de la barra no hace nada.
- Si usas varios monitores con barra, funciona en todos.
- El lock evita duplicados si lo lanzas a mano con el daemon ya activo.
