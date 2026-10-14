import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../strings.dart';

class NoticeSection {
  const NoticeSection(this.title, this.texts);

  final String title;
  final List<String> texts;
}

class Notices {
  const Notices({required this.notice, required this.sections});

  final String notice;
  final List<NoticeSection> sections;
}

String _entryText(LicenseEntry entry) {
  final lines = <String>[];
  for (final paragraph in entry.paragraphs) {
    final indent = paragraph.indent > 0 ? '    ' * paragraph.indent : '';
    lines.add('$indent${paragraph.text}');
  }
  return lines.join('\n\n');
}

Future<Notices> loadNotices({
  AssetBundle? bundle,
  Stream<LicenseEntry>? licenses,
}) async {
  final assets = bundle ?? rootBundle;
  final notice = await assets.loadString('NOTICE');
  final project = await assets.loadString('LICENSE');
  final font = await assets.loadString('assets/fonts/OFL.txt');
  final byPackage = <String, List<String>>{};
  await for (final entry in licenses ?? LicenseRegistry.licenses) {
    final text = _entryText(entry);
    for (final name in entry.packages) {
      final texts = byPackage.putIfAbsent(name, () => []);
      if (!texts.contains(text)) texts.add(text);
    }
  }
  final names = byPackage.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return Notices(
    notice: notice,
    sections: [
      NoticeSection(Strings.appName, [project]),
      NoticeSection(Strings.fontName, [font]),
      for (final name in names) NoticeSection(name, byPackage[name]!),
    ],
  );
}
