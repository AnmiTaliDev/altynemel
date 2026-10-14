import 'package:flutter/material.dart';

import 'demo/demo_screen.dart';
import 'settings/app_settings.dart';
import 'settings/app_settings_scope.dart';
import 'strings.dart';
import 'theme/themes.dart';

class AltynemelApp extends StatefulWidget {
  const AltynemelApp({super.key, this.settings});

  final AppSettings? settings;

  @override
  State<AltynemelApp> createState() => _AltynemelAppState();
}

class _AltynemelAppState extends State<AltynemelApp> {
  late final AppSettings _settings = widget.settings ?? AppSettings();

  @override
  void dispose() {
    if (widget.settings == null) _settings.dispose();
    super.dispose();
  }

  AltynemelThemeId? _fixedTheme() {
    return switch (_settings.theme) {
      ThemeChoice.system => null,
      ThemeChoice.night => AltynemelThemeId.night,
      ThemeChoice.day => AltynemelThemeId.day,
      ThemeChoice.contrast => AltynemelThemeId.contrast,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          final fixed = _fixedTheme();
          final light = buildTheme(fixed ?? AltynemelThemeId.day);
          final dark = buildTheme(fixed ?? AltynemelThemeId.night);
          return MaterialApp(
            title: Strings.appName,
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: dark,
            themeMode: switch (fixed) {
              null => ThemeMode.system,
              AltynemelThemeId.day => ThemeMode.light,
              _ => ThemeMode.dark,
            },
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  disableAnimations:
                      media.disableAnimations || _settings.reduceMotion,
                ),
                child: child!,
              );
            },
            home: const Scaffold(body: DemoScreen()),
          );
        },
      ),
    );
  }
}
