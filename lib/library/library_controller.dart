import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../settings/app_settings.dart';
import '../storage/library_database.dart';
import '../strings.dart';
import 'album.dart';
import 'artist.dart';
import 'grouping.dart';
import 'scanner.dart';
import 'track.dart';

const Map<RescanInterval, Duration> rescanDurations = {
  RescanInterval.minutes5: Duration(minutes: 5),
  RescanInterval.minutes15: Duration(minutes: 15),
  RescanInterval.hour1: Duration(hours: 1),
};

class LibraryController extends ChangeNotifier {
  LibraryController({
    required LibraryDatabase database,
    required AppSettings settings,
    required this.coversDirectory,
  }) : _database = database,
       _settings = settings {
    _folder = settings.libraryFolder;
    _interval = settings.rescanInterval;
    _split = settings.splitArtists;
    _order = settings.albumOrder;
    _settings.addListener(_onSettings);
    _reload();
  }

  final LibraryDatabase _database;
  final AppSettings _settings;
  final String coversDirectory;

  Timer? _timer;
  String? _folder;
  RescanInterval _interval = RescanInterval.minutes15;
  bool _split = true;
  AlbumOrder _order = AlbumOrder.discAndTrack;
  bool _scanning = false;
  bool _disposed = false;
  String? _error;

  List<Track> _tracks = const [];
  List<Album> _albums = const [];
  List<Artist> _artists = const [];
  Set<String> _liked = const {};
  List<StoredPlaylist> _playlists = const [];

  List<Track> get tracks => _tracks;
  List<Album> get albums => _albums;
  List<Artist> get artists => _artists;
  List<StoredPlaylist> get playlists => _playlists;
  bool get scanning => _scanning;
  String? get error => _error;
  bool isLiked(String trackId) => _liked.contains(trackId);
  List<Track> get likedTracks => [
    for (final t in _tracks)
      if (_liked.contains(t.id)) t,
  ];

  Track? trackById(String id) {
    for (final t in _tracks) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Track> playlistTracks(String playlistId) {
    return [
      for (final id in _database.playlistTrackIds(playlistId)) ?trackById(id),
    ];
  }

  void start() {
    _restartTimer();
    if (_folder != null) scan();
  }

  void _reload() {
    _tracks = sortLibraryTracks(_database.tracks(), _order);
    _albums = buildAlbums(_tracks);
    _artists = buildArtists(_tracks, split: _split);
    _liked = _database.likedIds();
    _playlists = _database.playlists();
  }

  void _onSettings() {
    final folderChanged = _settings.libraryFolder != _folder;
    final regroup =
        _settings.splitArtists != _split || _settings.albumOrder != _order;
    final intervalChanged = _settings.rescanInterval != _interval;
    _folder = _settings.libraryFolder;
    _split = _settings.splitArtists;
    _order = _settings.albumOrder;
    _interval = _settings.rescanInterval;
    if (regroup) {
      _reload();
      notifyListeners();
    }
    if (intervalChanged || folderChanged) _restartTimer();
    if (folderChanged && _folder != null) scan();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (_folder == null) return;
    _timer = Timer.periodic(rescanDurations[_interval]!, (_) => scan());
  }

  Future<void> scan() async {
    final folder = _folder;
    if (folder == null || _scanning) return;
    if (!Directory(folder).existsSync()) {
      _error = Strings.folderUnavailable;
      notifyListeners();
      return;
    }
    _scanning = true;
    _error = null;
    notifyListeners();
    try {
      final request = ScanRequest(
        root: folder,
        coversDirectory: coversDirectory,
        known: _database.knownFiles(),
      );
      final result = await Isolate.run(() => scanLibrary(request));
      if (_disposed) return;
      _database.applyScan(result);
      _reload();
    } on Object catch (error) {
      _error = error.toString();
    } finally {
      _scanning = false;
      if (!_disposed) notifyListeners();
    }
  }

  void setLiked(String trackId, bool liked) {
    _database.setLiked(trackId, liked);
    _liked = _database.likedIds();
    notifyListeners();
  }

  String createPlaylist(String name) {
    final id = _database.createPlaylist(name);
    _playlists = _database.playlists();
    notifyListeners();
    return id;
  }

  void addToPlaylist(String playlistId, String trackId) {
    _database.addToPlaylist(playlistId, trackId);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _settings.removeListener(_onSettings);
    super.dispose();
  }
}
