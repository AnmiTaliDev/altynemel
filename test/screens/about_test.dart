import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/about/notices.dart';
import 'package:altynemel/components/button.dart';
import 'package:altynemel/components/sidebar.dart';
import 'package:altynemel/screens/about_screen.dart';

import '../support/pump.dart';
import 'home_playback_test.dart' show pumpHome;

final aboutButton = find.byWidgetPredicate(
  (w) => w is AltynemelButton && w.label == 'About Altynemel',
);

void main() {
  testWidgets('settings leads to about and to free software', (tester) async {
    await pumpHome(tester, destination: SidebarDestination.settings);
    await tester.scrollUntilVisible(
      aboutButton,
      200,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(aboutButton);
    await tester.pumpAndSettle();
    expect(find.text('0.1.0'), findsOneWidget);
    expect(find.text('GPL-3.0-only'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('About free software'));
    await tester.pumpAndSettle();
    expect(find.textContaining('GNU General Public License'), findsWidgets);
    expect(find.textContaining('mpv and libmpv'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('0.1.0'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('the licenses screen shows sections and a failure message', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      FreeSoftwareScreen(
        onBack: () {},
        load: () async => const Notices(
          notice: 'the notice',
          sections: [
            NoticeSection('Altynemel', ['project text']),
            NoticeSection('somepkg', ['pkg text']),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('the notice', findRichText: true), findsOneWidget);
    expect(find.text('somepkg'), findsOneWidget);
    expect(find.text('2 components'), findsOneWidget);
  });
}
