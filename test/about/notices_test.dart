import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/about/app_info.dart';
import 'package:altynemel/about/notices.dart';

class _Bundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final data = switch (key) {
      'NOTICE' => 'notice text',
      'LICENSE' => 'project license',
      'assets/fonts/OFL.txt' => 'font license',
      _ => throw FlutterError('missing $key'),
    };
    return ByteData.sublistView(Uint8List.fromList(data.codeUnits));
  }
}

void main() {
  test('sections list the project, the font, then packages by name', () async {
    final notices = await loadNotices(
      bundle: _Bundle(),
      licenses: Stream.fromIterable([
        const LicenseEntryWithLineBreaks(['zeta'], 'Z license'),
        const LicenseEntryWithLineBreaks(['Alpha', 'zeta'], 'Shared license'),
        const LicenseEntryWithLineBreaks(['Alpha'], 'Shared license'),
      ]),
    );
    expect(notices.notice, 'notice text');
    expect(notices.sections.map((s) => s.title), [
      'Altynemel',
      'Onest',
      'Alpha',
      'zeta',
    ]);
    expect(notices.sections[0].texts, ['project license']);
    expect(notices.sections[2].texts, ['Shared license']);
    expect(notices.sections[3].texts, ['Z license', 'Shared license']);
  });

  test('the version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: $appVersion+'));
  });

  test('the bundled notice names the main license and native components', () {
    final notice = File('NOTICE').readAsStringSync();
    expect(notice, contains('GNU General Public License'));
    expect(notice, contains('mpv'));
    expect(notice, contains('SQLite'));
    expect(notice, contains('Onest'));
  });
}
