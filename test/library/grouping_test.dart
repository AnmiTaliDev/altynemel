import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/grouping.dart';
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

    test('is case insensitive and matches title, artist and album', () {
      expect(filterTracks(tracks, 'ØDEG').length, 1);
      expect(filterTracks(tracks, 'сарыарқа').length, 1);
      expect(filterTracks(tracks, 'natt').length, 1);
      expect(filterTracks(tracks, '  ').length, 2);
      expect(filterTracks(tracks, 'zzz'), isEmpty);
    });
  });
}
