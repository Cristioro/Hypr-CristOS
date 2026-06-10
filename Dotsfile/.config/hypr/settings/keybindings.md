# Hyprland Keybindings

Este README documenta los atajos de teclado definidos en `keybindings.lua` dentro de la configuración de Hyprland.

## Modificador principal

- `SUPER` corresponde a la tecla `Windows` (modificador principal usado en la mayoría de los binds).

## Atajos principales

- `SUPER + Q` : Abrir terminal.
- `SUPER + C` : Cerrar la ventana activa.
- `SUPER + M` : Apagar Hyprland o ejecutar `hyprshutdown` si está disponible.
- `SUPER + E` : Abrir el gestor de archivos.
- `SUPER + F` : Alternar ventana flotante.
- `SUPER + SHIFT + F` : Poner ventana en pantalla completa.
- `SUPER + space` : Abrir el menú definido en `menu`.
- `SUPER + P` : Alternar ventana pseudo.
- `SUPER + J` : Cambiar layout a `togglesplit`.
- `SUPER + Escape` : Abrir el menú de energía de `rofi`.

## Atajos personalizados

- `SUPER + F10` : Encender DPMS.
- `SUPER + F11` : Apagar DPMS.
- `SUPER + ALT + C` : Centrar la ventana flotante.
- `SUPER + W` : Ejecutar el selector de wallpaper.
- `SUPER + SHIFT + W` : Abrir el selector de wallpaper de QuickShell.
- `SUPER + V` : Abrir el historial del portapapeles con `cliphist`.
- `Print` : Tomar captura de pantalla con `hyprshot` y copiar al portapapeles.

## Navegación y gestión de ventanas

- `SUPER + left/right/up/down` : Mover el foco a la ventana en la dirección correspondiente.
- `SUPER + SHIFT + left/right/up/down` : Intercambiar ventana activa con la ventana vecina.
- `SUPER + ALT + left/right/up/down` : Mover la ventana activa en la dirección correspondiente.

## Espacios de trabajo

- `SUPER + [1-9,0]` : Cambiar al workspace 1-10.
- `SUPER + SHIFT + [1-9,0]` : Mover la ventana activa al workspace 1-10.

### Teclado numérico

- `SUPER + KP_End` : Cambiar a workspace 1.
- `SUPER + KP_Down` : Cambiar a workspace 2.
- `SUPER + KP_Next` : Cambiar a workspace 3.
- `SUPER + KP_Left` : Cambiar a workspace 4.
- `SUPER + KP_Begin` : Cambiar a workspace 5.
- `SUPER + KP_Right` : Cambiar a workspace 6.
- `SUPER + KP_Home` : Cambiar a workspace 7.
- `SUPER + KP_Up` : Cambiar a workspace 8.
- `SUPER + KP_Prior` : Cambiar a workspace 9.
- `SUPER + KP_Insert` : Cambiar a workspace 10.

- `SUPER + SHIFT + KP_*` : Mover la ventana activa al workspace correspondiente.

## Workspaces especiales y scratchpad

- `SUPER + S` : Alternar workspace especial `magic`.
- `SUPER + SHIFT + S` : Mover la ventana activa al workspace especial `magic`.
- `SUPER + CTRL + S` : Mover la ventana activa al workspace actual (`+0`).

## Scroll y ratón

- `SUPER + mouse_down` : Cambiar al siguiente workspace.
- `SUPER + mouse_up` : Cambiar al workspace anterior.
- `SUPER + mouse:272` : Arrastrar ventana con botón primario.
- `SUPER + mouse:273` : Redimensionar ventana con botón secundario.

## Teclas multimedia y de hardware

- `XF86PowerOff` : Apagar el equipo con un mensaje de advertencia.
- `XF86AudioRaiseVolume` : Subir volumen.
- `XF86AudioLowerVolume` : Bajar volumen.
- `XF86AudioMute` : Silenciar/desilenciar salida de audio.
- `XF86AudioMicMute` : Silenciar/desilenciar micrófono.
- `XF86MonBrightnessUp` : Subir brillo.
- `XF86MonBrightnessDown` : Bajar brillo.
- `XF86AudioNext` : Siguiente pista de audio.
- `XF86AudioPause` : Reproducir/pausar audio.
- `XF86AudioPlay` : Reproducir/pausar audio.
- `XF86AudioPrev` : Pista anterior.

## Cómo editar

1. Abre `settings/keybindings.lua`.
2. Modifica o añade nuevas entradas usando `hl.bind()`.
3. Recarga la configuración de Hyprland para aplicar los cambios.

> Nota: las funciones usadas en los binds (`hl.dsp.exec_cmd`, `hl.dsp.window.move`, etc.) dependen de la configuración del entorno Hyprland y de los comandos disponibles en tu sistema.
