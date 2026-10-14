import 'package:flutter/material.dart';

import 'theme/themes.dart';

class AltynemelApp extends StatelessWidget {
  const AltynemelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Altynemel',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(AltynemelThemeId.day),
      darkTheme: buildTheme(AltynemelThemeId.night),
      themeMode: ThemeMode.system,
      home: const Scaffold(body: SizedBox.shrink()),
    );
  }
}
