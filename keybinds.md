# Hyprland Keybindings

Atajos definidos en `Dotsfile/.config/hypr/config/keybinds.lua` (`hl.bind(...)`).
La configuración vive en `~/.config/hypr/config/`.

## Modificador principal

- `SUPER` = tecla `Windows` (modificador de la mayoría de binds).

## Aplicaciones

- `SUPER + RETURN` : Abrir terminal (`foot`).
- `SUPER + F` : Abrir navegador (`zen-browser`).
- `SUPER + E` : Abrir gestor de archivos (`nautilus`).

## Ventanas

- `SUPER + Q` : Cerrar la ventana activa.
- `SUPER + SHIFT + F` : Alternar ventana flotante.
- `SUPER + ALT + F` : Pantalla completa.
- `SUPER + flechas` : Mover el foco (izquierda/derecha/arriba/abajo).
- `SUPER + SHIFT + flechas` : Redimensionar la ventana (repetible).
- `SUPER + CTRL + flechas` : Mover la ventana en esa dirección.
- `SUPER + arrastrar (mouse:272)` : Mover ventana.
- `SUPER + clic derecho (mouse:273)` : Redimensionar ventana.

## Capturas de pantalla

Pensado para teclados 68 teclas **sin tecla Print** (donde está Print hay una rueda de volumen):

- `SUPER + P` : Capturar una **región** y copiar al portapapeles.
- `SUPER + SHIFT + P` : Capturar **pantalla completa** y copiar al portapapeles.
- `SUPER + CTRL + P` : Captura completa y abrir el editor (`satty`).
- `SUPER + SHIFT + S` : Capturar región (atajo extra, mismo resultado que `SUPER + P`).

Si tu teclado sí tiene `Print`, también funcionan:

- `Print` : región al portapapeles.
- `SHIFT + Print` : región + editor.
- `SUPER + Print` : pantalla completa al portapapeles.
- `SUPER + SHIFT + Print` : pantalla completa + editor.

## Grabación de pantalla

- `SUPER + SHIFT + R` : Iniciar/detener grabación.

## Bloqueo y energía

- `SUPER + L` : Bloquear pantalla (`hyprlock`).
- `XF86PowerOff` : Bloquear pantalla.
- `XF86MonBrightnessUp` / `XF86MonBrightnessDown` : Subir/bajar brillo (OSD de `swayosd`).

## Multimedia y audio

- `SUPER + SPACE` : Reproducir/pausar (`playerctl`).
- `XF86AudioPlay` / `XF86AudioPause` : Reproducir/pausar.
- `XF86AudioNext` / `XF86AudioPrev` : Siguiente/anterior pista.
- `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` : Subir/bajar volumen (OSD).
- `XF86AudioMute` : Silenciar salida.
- `XF86AudioMicMute` : Silenciar micrófono.

## Cafeína (mantener despierto)

- `SUPER + SHIFT + CAPS_LOCK` : Activar/desactivar el inhibidor de idle/suspensión.

## Idioma del teclado

- `SUPER + ALT + CAPS_LOCK` : Cambiar al siguiente layout (`latam` ↔ `us`).
- `ALT + SHIFT` : Alternar layout (opción `grp:alt_shift_toggle`).

## Launchers y paneles (Rofi)

- `SUPER + I` : Centro de control (`settings.sh`).
- `SUPER + D` : Lanzador de aplicaciones (`rofi -show drun`).
- `SUPER + C` / `SUPER + V` : Historial del portapapeles (`cliphist`).
- `SUPER + N` : Menú de WiFi.
- `SUPER + S` : Menú de atajos.
- `SUPER + Escape` : Menú de apagado.
- `SUPER + M` : `hyprshutdown`.
- `SUPER + W` : Selector de wallpapers (`hyprquickpaper`).

## Sistema

- `SUPER + R` : Recargar Hyprland (`hyprctl reload`).

## Espacios de trabajo

- `SUPER + [1-9,0]` : Ir al workspace 1-10 (`0` = 10).
- `SUPER + SHIFT + [1-9,0]` : Mover la ventana activa al workspace.
- Gesto de 3 dedos horizontal : Cambiar de workspace.
- Rueda del ratón sobre los círculos de Waybar : Cambiar de workspace (daemon `ws-scroll-daemon`).

## Cómo editar

1. Edita `~/.config/hypr/config/keybinds.lua`.
2. Añade/modifica binds con `hl.bind(...)` usando `vars.mainMod` y `vars.terminal`.
3. Aplica con `SUPER + R` o `hyprctl reload`.
