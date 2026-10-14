# Altynemel

[![License: GPL-3.0-only](https://img.shields.io/badge/license-GPL--3.0--only-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-3.41-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](#dependencies)

## About

Altynemel is a desktop music player.

## Dependencies

- Linux with Wayland or X11. macOS is not supported yet.
- Flutter 3.41 (stable) with Linux desktop support
- clang, cmake, ninja, pkg-config, GTK 3 development files
- libmpv at runtime

## Build

```sh
flutter pub get
flutter run -d linux
```

## Keyboard

| Key | Action |
| --- | --- |
| Space | Play or pause |
| Left, Right | Seek by 5 seconds |
| Ctrl+Left, Ctrl+Right | Previous or next track |
| Up, Down | Move between track rows |
| Menu key, Shift+F10 | Open the track menu |
| Escape | Close the menu or the Now playing view |

## Global shortcuts

Global shortcuts use the xdg-desktop-portal GlobalShortcuts interface, so they work on Wayland as well as X11. The desktop asks for confirmation the first time.

| Shortcut | Action |
| --- | --- |
| Ctrl+Alt+Space | Play or pause |
| Ctrl+Alt+Right | Next track |
| Ctrl+Alt+Left | Previous track |

If the portal is missing or the request is denied, the shortcuts are disabled and the rest of the app works as usual. The desktop may let you change the bindings in its own settings.

## Limits

- The window is undecorated and draws its own title bar. Moving and resizing depend on the compositor.
- Centering the window on start has no effect on Wayland.
- Media controls report no cover art and offer no Raise or Quit action.
- Show in folder uses `xdg-open` and needs a desktop file manager.

## Tests

```sh
flutter analyze
flutter test
```

Token tests read the design token file from `../altynemel-design/tokens.json` and are skipped when it is missing.

## License

GPL-3.0-only. See [LICENSE](LICENSE). Copyright (C) 2026 Altynemel authors.

Third-party components and their licenses are listed in [NOTICE](NOTICE) and under Settings, About, About free software.
