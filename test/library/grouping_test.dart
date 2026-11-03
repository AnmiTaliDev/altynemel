import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/grouping.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';
import 'package:altynemel/library/search_options.dart';
import 'package:altynemel/library/track.dart';
import 'package:altynemel/settings/app_settings.dart';

Track t(
  String id, {
  String artist = 'A',
  String? album,
  String? albumArtist,
  int? n,
  int? disc,
  String? path,
}) {
  return Track(
    id: id,
    title: id,
    artist: artist,
    album: album,
    albumArtist: albumArtist,
    trackNumber: n,
    discNumber: disc,
    duration: const Duration(minutes: 3),
    path: path ?? '/m/$id.mp3',
  );
}

void main() {
  artistSeparatorTests();
  artistSortTests();
  albumSortTests();
  group('splitArtists', () {
    test('splits on comma, semicolon and feat. variants', () {
      expect(splitArtists('june lu, sløwmind', enabled: true), [
        'june lu',
        'sløwmind',
      ]);
      expect(splitArtists('A; B', enabled: true), ['A', 'B']);
      expect(splitArtists('A feat. B', enabled: true), ['A', 'B']);
      expect(splitArtists('A ft B', enabled: true), ['A', 'B']);
      expect(splitArtists('A Featuring B', enabled: true), ['A', 'B']);
    });

    test('keeps names with the letters of a separator word', () {
      expect(splitArtists('Defeat', enabled: true), ['Defeat']);
      expect(splitArtists('Soft Cell', enabled: true), ['Soft Cell']);
    });

    test('keeps the whole string when disabled', () {
      expect(splitArtists('A, B', enabled: false), ['A, B']);
    });
  });

  group('albums and artists', () {
    test('groups by album and album artist, unknown album as one group', () {
      final albums = buildAlbums([
        t('1', album: 'X', albumArtist: 'Va'),
        t('2', album: 'X', albumArtist: 'Va', artist: 'B'),
        t('3', album: 'X', artist: 'C', path: '/other/3.mp3'),
        t('4'),
        t('5', artist: 'A'),
      ]);
      expect(albums.length, 3);
      final unknown = albums.firstWhere((a) => a.title == unknownAlbum);
      expect(unknown.trackCount, 2);
      expect(albums.firstWhere((a) => a.artist == 'Va').trackCount, 2);
    });

    test('tracks with different artists in one folder stay one album', () {
      final albums = buildAlbums([
        t('1', album: 'X', artist: 'A'),
        t('2', album: 'X', artist: 'A feat. B'),
      ]);
      expect(albums.single.trackCount, 2);
      expect(albums.single.artist, variousArtists);
    });

    test('artists are counted per split name and deduplicated per track', () {
      final artists = buildArtists([
        t('1', artist: 'june lu, sløwmind'),
        t('2', artist: 'june lu'),
        t('3', artist: 'june lu; june lu'),
      ], split: true);
      expect(
        {for (final a in artists) a.name: a.trackCount},
        {'june lu': 3, 'sløwmind': 1},
      );
      final unsplit = buildArtists([
        t('1', artist: 'june lu, sløwmind'),
      ], split: false);
      expect(unsplit.single.name, 'june lu, sløwmind');
    });
  });

  group('ordering', () {
    final tracks = [
      t('c', album: 'X', n: 1, disc: 2, path: '/m/a.mp3'),
      t('a', album: 'X', n: 2, disc: 1, path: '/m/c.mp3'),
      t('b', album: 'X', n: 1, disc: 1, path: '/m/b.mp3'),
      t('d', album: 'X', path: '/m/0.mp3'),
    ];

    test('disc and track number, untagged after tagged within a disc', () {
      final ids = orderAlbumTracks(
        tracks,
        AlbumOrder.discAndTrack,
      ).map((e) => e.id);
      expect(ids, ['b', 'a', 'd', 'c']);
    });

    test('file name', () {
      final ids = orderAlbumTracks(
        tracks,
        AlbumOrder.fileName,
      ).map((e) => e.id);
      expect(ids, ['d', 'c', 'b', 'a']);
    });
  });

  group('filter', () {
    final tracks = [
      t('Балбырауын', artist: 'Құрманғазы', album: 'Сарыарқа'),
      t('Natt', artist: 'Bjørk Ødegård'),
    ];

    final withPaths = [
      t('one', path: '/music/one-rip.flac'),
      t('two', path: '/music/two-rip.flac'),
    ];

    test('is case insensitive and matches title, artist and album', () {
      expect(filterTracks(tracks, 'ØDEG').length, 1);
      expect(filterTracks(tracks, 'сарыарқа').length, 1);
      expect(filterTracks(tracks, 'natt').length, 1);
      expect(filterTracks(tracks, '  ').length, 2);
      expect(filterTracks(tracks, 'zzz'), isEmpty);
    });

    test('can ignore accents in tracks, albums and artists', () {
      const on = SearchOptions(ignoreAccents: true);
      expect(filterTracks(tracks, 'odegard').length, 0);
      expect(filterTracks(tracks, 'odegard', on).length, 1);
      expect(filterTracks(tracks, 'ØDEGÅRD', on).length, 1);
      final artists = buildArtists(tracks, split: false);
      expect(filterArtists(artists, 'bjork').length, 0);
      expect(filterArtists(artists, 'bjork', on).length, 1);
    });

    test('can include file names in the search', () {
      const on = SearchOptions(fileName: true);
      expect(filterTracks(withPaths, 'rip.flac').length, 0);
      expect(filterTracks(withPaths, 'rip.flac', on).length, 2);
      expect(filterTracks(withPaths, '-rip', on).length, 2);
    });

    test('can leave titles out of the search', () {
      const off = SearchOptions(title: false);
      expect(filterTracks(tracks, 'балбырауын', off), isEmpty);
      expect(filterTracks(tracks, 'ødeg', off).length, 1);
      expect(filterTracks(tracks, 'балбырауын').length, 1);
    });

    test('can leave artist names out of the search', () {
      const off = SearchOptions(artist: false);
      expect(filterTracks(tracks, 'ødeg', off), isEmpty);
      expect(filterTracks(tracks, 'natt', off).length, 1);
      expect(filterTracks(tracks, 'ødeg').length, 1);
    });

    test('can leave album names out of the search', () {
      const off = SearchOptions(album: false);
      expect(filterTracks(tracks, 'сарыарқа', off), isEmpty);
      expect(filterTracks(tracks, 'балбырауын', off).length, 1);
      expect(filterTracks(tracks, 'сарыарқа').length, 1);
    });
  });
}

void artistSeparatorTests() {
  group('configurable artist separators', () {
    test('the catalog default equals the grouping default', () {
      expect(artistSeparators.defaultValue, defaultArtistSeparators);
    });

    test('a custom separator splits and the old ones stop', () {
      expect(splitArtists('A / B', enabled: true, separators: '/'), ['A', 'B']);
      expect(splitArtists('A, B', enabled: true, separators: '/'), ['A, B']);
    });

    test('word separators need spaces and may drop their dot', () {
      expect(splitArtists('A with B', enabled: true, separators: 'with'), [
        'A',
        'B',
      ]);
      expect(splitArtists('Without Words', enabled: true, separators: 'with'), [
        'Without Words',
      ]);
      expect(splitArtists('A vs B', enabled: true, separators: 'vs.'), [
        'A',
        'B',
      ]);
    });

    test('an empty spec never splits', () {
      expect(splitArtists('A, B', enabled: true, separators: ' | '), ['A, B']);
    });

    test('artists are built with the given separators', () {
      final tracks = [
        const Track(
          id: '1',
          title: 't',
          artist: 'X & Y',
          duration: Duration(seconds: 5),
        ),
      ];
      final names = buildArtists(
        tracks,
        split: true,
        separators: '&',
      ).map((a) => a.name);
      expect(names, ['X', 'Y']);
    });
  });
}

void artistSortTests() {
  group('artist order', () {
    final tracks = [
      for (final (id, artist) in [
        ('1', 'Zed'),
        ('2', 'Zed'),
        ('3', 'Amy'),
        ('4', 'Bob'),
        ('5', 'Bob'),
        ('6', 'Bob'),
      ])
        Track(
          id: id,
          title: 't$id',
          artist: artist,
          duration: const Duration(seconds: 5),
        ),
    ];

    test('by name is alphabetical', () {
      expect(buildArtists(tracks, split: false).map((a) => a.name), [
        'Amy',
        'Bob',
        'Zed',
      ]);
    });

    test('by track count puts the largest first and ties by name', () {
      final names = buildArtists(
        tracks,
        split: false,
        sort: ArtistSort.trackCount,
      ).map((a) => a.name);
      expect(names, ['Bob', 'Zed', 'Amy']);
    });
  });
}

void albumSortTests() {
  group('album order', () {
    Track track(String id, String album, String artist) => Track(
      id: id,
      title: 't$id',
      artist: artist,
      album: album,
      albumArtist: artist,
      duration: const Duration(seconds: 5),
      path: '/m/$artist/$album/$id.mp3',
    );

    final tracks = [
      track('1', 'Alpha', 'Zed'),
      track('2', 'Beta', 'Amy'),
      track('3', 'Beta', 'Amy'),
      track('4', 'Gamma', 'Bob'),
    ];

    test('by title is alphabetical', () {
      expect(buildAlbums(tracks).map((a) => a.title), [
        'Alpha',
        'Beta',
        'Gamma',
      ]);
    });

    test('by artist sorts on the album artist first', () {
      expect(buildAlbums(tracks, sort: AlbumSort.artist).map((a) => a.title), [
        'Beta',
        'Gamma',
        'Alpha',
      ]);
    });

    test('by track count puts the longest album first', () {
      expect(
        buildAlbums(tracks, sort: AlbumSort.trackCount).map((a) => a.title),
        ['Beta', 'Alpha', 'Gamma'],
      );
    });
  });
}
