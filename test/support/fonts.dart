import 'dart:io';

import 'package:flutter/services.dart';

Future<void> loadOnest() async {
  final loader = FontLoader('Onest')
    ..addFont(
      Future.value(
        ByteData.sublistView(File('assets/fonts/Onest.ttf').readAsBytesSync()),
      ),
    );
  await loader.load();
}
