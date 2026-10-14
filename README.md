Desktop music player that plays audio files from a local library folder.

## Dependencies

- Flutter 3.41 (stable) with Linux desktop support
- clang, cmake, ninja, pkg-config, GTK 3 development files

## Build

```
flutter pub get
flutter run -d linux
```

## Tests

```
flutter analyze
flutter test
```

Token tests read the design token file from `../altynemel-design/tokens.json` and are skipped when it is missing.

## License

GPL-3.0-only. See [LICENSE](LICENSE).
