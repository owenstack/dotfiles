# Five-minute GTK scale comparison

The current monitor entry uses scale 1 and `hyprland.lua` sets `GDK_SCALE=2`. Hyprland documents `GDK_SCALE` as a toolkit-level way to scale GTK programs; its XWayland notes say it does not conflict with Wayland-native GTK clients. GTK describes `GDK_SCALE` as an integer override that scales all windows. Qt does not use `GDK_SCALE`: native Qt Wayland apps read the compositor's output scale, while Qt X11 apps use X11 DPI settings. `QT_SCALE_FACTOR` can multiply Qt's detected scale, so do not set it for this comparison. Quickshell is Qt Quick and follows Qt's platform scale; its fixed QML pixel/font sizes can still look different from native GTK controls. [Hyprland XWayland guidance](https://wiki.hypr.land/configuring/extra/xwayland/), [GTK X11 scaling variables](https://docs.gtk.org/gtk3/x11.html), [Qt high-DPI guidance](https://doc.qt.io/qt-6/highdpi.html).

## Reversible override

The tracked Hyprland config keeps its default at `GDK_SCALE=2`. Before testing, create this untracked file:

```sh
mkdir -p ~/.config/hypr
printf 'GDK_SCALE=1\n' > ~/.config/hypr/env.local
```

The config accepts only `GDK_SCALE=1` or `GDK_SCALE=2`; if the file is absent or invalid it uses the existing default `2`. The file is ignored by the generated allow-list. Reload Hyprland after editing it (`hyprctl reload`); close and reopen test applications because toolkits read environment settings at launch. To restore current behavior, delete `~/.config/hypr/env.local` and reload.

## Five-minute A/B procedure

1. Take a screenshot or note current sizes with the override absent (`GDK_SCALE=2`). Use the same windows and positions for both passes.
2. Compare a GTK app such as Thunar, the Qt5ct/Qt6ct control panel, and the running task-bar Quickshell hub/dock.
3. For XWayland, open a known X11 app if one is installed (for example `xterm`); confirm it is actually XWayland with `hyprctl clients` and compare text sharpness and physical window size.
4. Create `env.local` with `GDK_SCALE=1`, reload Hyprland, and restart the GTK, Qt, XWayland, and Quickshell apps. Compare again.
5. Choose a result below, record it for yourself, then delete the override and reload so the tracked default remains intact until the owner deliberately decides otherwise.

## Decision table

| Observation | Suggested decision |
|---|---|
| GTK alone is too large at `2`; Qt and QuickShell are comfortable at monitor scale 1 | Prefer `GDK_SCALE=1`; keep monitor scale 1. |
| GTK is comfortable at `2`; Qt and QuickShell remain comfortable | Keep the current default `2`. |
| GTK looks right at `2`, but XWayland is blurry or too large | Keep/choose GTK by its own result; investigate XWayland app-native scale or Hyprland `xwayland.force_zero_scaling` separately. Do not change the monitor scale as part of this test. |
| Qt and Quickshell are too small or too large in both GTK trials | GDK scale is not the Qt control; test a Qt-specific setting in a separate reversible experiment. |
| Different GTK apps disagree | Keep the default temporarily and tune the outlier app separately; one global integer scale cannot correct every app. |

No visual result is claimed here: the A/B test needs an interactive desktop and the owner's judgment.
