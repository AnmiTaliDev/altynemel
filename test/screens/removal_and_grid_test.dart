import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/components/icon_button.dart';
import 'package:altynemel/components/media_tile.dart';
import 'package:altynemel/components/menu.dart';
import 'package:altynemel/library/album.dart';
import 'package:altynemel/screens/library_screen.dart';
import 'package:altynemel/strings.dart';

import '../support/pump.dart';
import '../support/test_library.dart';
import 'home_playback_test.dart' show pumpHome;

void main() {
  testWidgets('a large album grid builds only the visible rows', (
    tester,
  ) async {
    final albums = [
      for (var i = 0; i < 5000; i++)
        Album(id: '$i', title: 'Album $i', artist: 'Artist', trackCount: 1),
    ];
    await pumpThemed(
      tester,
      LibraryScreen(
        albums: albums,
        artists: const [],
        tracks: const [],
        currentTrackId: null,
        isPlaying: false,
        selectedTrackId: null,
        onSelectTrack: (_) {},
        onPlayTrack: (_) {},
        onTrackMore: (_) {},
        onOpenAlbum: (_) {},
        onOpenArtist: (_) {},
        onOpenSettings: () {},
      ),
    );
    final built = tester.widgetList(find.byType(MediaTile)).length;
    expect(built, greaterThan(0));
    expect(built, lessThan(60));
  });

  testWidgets('the back button on an album returns to the albums tab', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Сарыарқа, Құрманғазы'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Сарыарқа, Құрманғазы'), findsOneWidget);
  });

  testWidgets('the back button on an artist returns to the artists tab', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Artists'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Құрманғазы, 2 tracks'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Құрманғазы, 2 tracks'), findsOneWidget);
  });

  testWidgets('a playlist is deleted after confirmation', (tester) async {
    final lib = await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(Strings.deletePlaylist));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Cancel'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Cancel'));
    await tester.pumpAndSettle();
    expect(lib.library.playlists, isNotEmpty);
    await tester.tap(find.bySemanticsLabel(Strings.deletePlaylist));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(MenuPanel),
        matching: find.bySemanticsLabel(Strings.deletePlaylist),
      ),
    );
    await tester.pumpAndSettle();
    expect(lib.library.playlists, isEmpty);
    expect(find.bySemanticsLabel(sharedPlaylistName), findsNothing);
  });

  testWidgets('a track can be removed from a playlist through the menu', (
    tester,
  ) async {
    final lib = await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel(sharedPlaylistName));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is AltynemelIconButton &&
            w.label == Strings.moreAbout('fading memories'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(Strings.removeFromPlaylist));
    await tester.pumpAndSettle();
    final shared = lib.library.playlists.single;
    expect(lib.library.playlistTracks(shared.id), isEmpty);
    expect(lib.library.tracks.length, 4);
  });
}
