import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import '../library/track.dart';
import '../settings/app_settings.dart';
import 'play_queue.dart';
import 'playback_persistence.dart';
import 'repeat_setting.dart';

const Duration crossfadeDuration = Duration(seconds: 4);
const Duration restartThreshold = Duration(seconds: 3);
const Duration saveInterval = Duration(seconds: 5);

bool _defaultFileExists(String path) => File(path).existsSync();

Player createPlayer() {
  return Player(configuration: const PlayerConfiguration(title: 'Altynemel'));
}

class PlaybackController extends ChangeNotifier {
  PlaybackController({
    required AppSettings settings,
    PlaybackPersistence? persistence,
    Player Function() playerFactory = createPlayer,
    PlayQueue? queue,
    bool Function(String path)? fileExists,
  }) : _settings = settings,
       _persistence = persistence,
       _playerFactory = playerFactory,
       _queue = queue ?? PlayQueue(),
       _fileExists = fileExists ?? _defaultFileExists {
    _primary = _playerFactory();
    _configure(_primary);
    _listen();
    _gapless = settings.gapless;
    _crossfade = settings.crossfade;
    _settings.addListener(_onSettings);
  }

  final AppSettings _settings;
  final PlaybackPersistence? _persistence;
  final Player Function() _playerFactory;
  final PlayQueue _queue;
  final bool Function(String path) _fileExists;

  late Player _primary;
  Player? _secondary;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _fadeTimer;
  Timer? _saveTimer;
  bool _fading = false;
  bool _gapless = true;
  bool _crossfade = false;
  bool _playing = false;
  bool _ended = false;
  bool _opening = false;
  bool _disposed = false;
  int _lastIndex = 0;
  int _errorStreak = 0;
  int _volume = 70;
  int _volumeBeforeMute = 70;
  Duration _duration = Duration.zero;
  String? _error;
  String sourceTitle = '';

  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  Track? get current => _queue.current;
  bool get isPlaying => _playing;
  Duration get duration => _duration;
  int get volume => _volume;
  bool get shuffle => _queue.shuffle;
  RepeatSetting get repeat => _queue.repeat;
  String? get error => _error;
  List<Track> get queueTracks => _queue.ordered;
  List<Track> get sourceTracks => _queue.items;
  int get queuePosition => _queue.position;
  bool get hasTrack => _queue.current != null;
  bool get isMuted => _volume == 0;

  void _configure(Player player) {
    final platform = player.platform;
    if (platform is NativePlayer) {
      platform.setProperty('gapless-audio', 'yes');
    }
  }

  void _listen() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions
      ..clear()
      ..add(_primary.stream.playlist.listen(_onPlaylist))
      ..add(_primary.stream.playing.listen(_onPlaying))
      ..add(_primary.stream.completed.listen(_onCompleted))
      ..add(_primary.stream.position.listen(_onPosition))
      ..add(_primary.stream.duration.listen(_onDuration))
      ..add(_primary.stream.error.listen(_onError));
  }

  void _onSettings() {
    final gaplessChanged = _gapless != _settings.gapless;
    final crossfadeChanged = _crossfade != _settings.crossfade;
    _gapless = _settings.gapless;
    _crossfade = _settings.crossfade;
    if (gaplessChanged || crossfadeChanged) {
      if (_fading && !_crossfade) _cancelFade();
      unawaited(_refreshNext());
    }
  }

  bool get _preload => _gapless && !_crossfade;

  bool _exists(Track track) {
    final path = track.path;
    return path != null && _fileExists(path);
  }

  Future<void> playTracks(
    List<Track> tracks,
    int index, {
    String title = '',
  }) async {
    if (tracks.isEmpty) return;
    sourceTitle = title;
    _queue.load(tracks, start: index);
    _errorStreak = 0;
    await _startCurrent(play: true);
  }

  Future<void> _startCurrent({required bool play, Duration? startAt}) async {
    if (_disposed) return;
    _cancelFade();
    final track = _queue.current;
    if (track == null) {
      await _primary.stop();
      _setPlaying(false);
      position.value = Duration.zero;
      _duration = Duration.zero;
      notifyListeners();
      return;
    }
    if (!_exists(track)) {
      _error = 'File not found: ${track.title}';
      notifyListeners();
      await _skipBroken();
      return;
    }
    _opening = true;
    _ended = false;
    _error = null;
    _duration = track.duration;
    position.value = startAt ?? Duration.zero;
    _lastIndex = 0;
    final medias = [Media(track.path!)];
    final next = _preload ? _queue.peekNext(auto: true) : null;
    if (next != null && next.path != null && _exists(next)) {
      medias.add(Media(next.path!));
    }
    await _primary.setPlaylistMode(
      _queue.repeat == RepeatSetting.one
          ? PlaylistMode.single
          : PlaylistMode.none,
    );
    await _primary.setVolume(_volume.toDouble());
    await _primary.open(Playlist(medias), play: play);
    _opening = false;
    if (startAt != null && startAt > Duration.zero) {
      await _primary.seek(startAt);
    }
    _setPlaying(play);
    notifyListeners();
    _save();
  }

  Future<void> _skipBroken() async {
    _errorStreak++;
    if (_errorStreak >= _queue.items.length) {
      _setPlaying(false);
      notifyListeners();
      return;
    }
    final next = _queue.advance(auto: false);
    if (next == null) {
      _setPlaying(false);
      notifyListeners();
      return;
    }
    await _startCurrent(play: true);
  }

  void _onPlaylist(Playlist playlist) {
    if (_opening || _fading) return;
    if (playlist.index > _lastIndex) {
      _lastIndex = playlist.index;
      final track = _queue.advance(auto: true);
      if (track == null) return;
      _duration = track.duration;
      position.value = Duration.zero;
      _errorStreak = 0;
      notifyListeners();
      unawaited(_appendNext());
      _save();
    }
  }

  Future<void> _appendNext() async {
    if (!_preload) return;
    final next = _queue.peekNext(auto: true);
    if (next == null || next.path == null || !_exists(next)) return;
    await _primary.add(Media(next.path!));
  }

  Future<void> _refreshNext() async {
    if (_disposed || _opening || _queue.current == null) return;
    var length = _primary.state.playlist.medias.length;
    final index = _primary.state.playlist.index;
    while (length > index + 1) {
      await _primary.remove(index + 1);
      length--;
    }
    await _appendNext();
  }

  void _onPlaying(bool playing) {
    if (_opening || _fading) return;
    _setPlaying(playing);
  }

  void _setPlaying(bool value) {
    if (_playing == value) return;
    _playing = value;
    notifyListeners();
    if (value) {
      if (_persistence != null) {
        _saveTimer ??= Timer.periodic(saveInterval, (_) => _save());
      }
    } else {
      _saveTimer?.cancel();
      _saveTimer = null;
      _save();
    }
  }

  void _onCompleted(bool completed) {
    if (!completed || _opening || _fading || _disposed) return;
    final next = _queue.advance(auto: true);
    if (next == null) {
      _ended = true;
      _setPlaying(false);
      position.value = Duration.zero;
      notifyListeners();
      return;
    }
    _errorStreak = 0;
    unawaited(_startCurrent(play: true));
  }

  void _onPosition(Duration value) {
    if (_opening || _ended) return;
    position.value = value;
    if (value > Duration.zero) _errorStreak = 0;
    if (_crossfade && !_fading && _playing) _maybeStartFade(value);
  }

  void _onDuration(Duration value) {
    if (value > Duration.zero && value != _duration) {
      _duration = value;
      notifyListeners();
    }
  }

  void _onError(String message) {
    if (_disposed || _opening) return;
    _error = message;
    notifyListeners();
    unawaited(_skipBroken());
  }

  void _maybeStartFade(Duration value) {
    final total = _duration;
    if (total <= crossfadeDuration * 2) return;
    if (total - value > crossfadeDuration) return;
    if (_queue.repeat == RepeatSetting.one) return;
    final next = _queue.peekNext(auto: true);
    if (next == null || next.path == null || !_exists(next)) return;
    unawaited(_beginFade(next));
  }

  Future<void> _beginFade(Track next) async {
    if (_fading) return;
    _fading = true;
    final incoming = _secondary ??= _createSecondary();
    await incoming.setVolume(0);
    await incoming.open(Media(next.path!), play: true);
    final watch = Stopwatch()..start();
    final target = _volume.toDouble();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final t = (watch.elapsedMilliseconds / crossfadeDuration.inMilliseconds)
          .clamp(0.0, 1.0);
      _primary.setVolume(target * math.cos(t * math.pi / 2));
      incoming.setVolume(target * math.sin(t * math.pi / 2));
      if (t >= 1) {
        timer.cancel();
        _fadeTimer = null;
        unawaited(_finishFade(incoming, next));
      }
    });
  }

  Player _createSecondary() {
    final player = _playerFactory();
    _configure(player);
    return player;
  }

  Future<void> _finishFade(Player incoming, Track next) async {
    final outgoing = _primary;
    _primary = incoming;
    _secondary = outgoing;
    _listen();
    await outgoing.stop();
    await outgoing.setVolume(_volume.toDouble());
    await _primary.setVolume(_volume.toDouble());
    _queue.advance(auto: true);
    _lastIndex = 0;
    _fading = false;
    _duration = next.duration;
    _errorStreak = 0;
    notifyListeners();
    _save();
  }

  void _cancelFade() {
    if (!_fading) return;
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _fading = false;
    unawaited(_secondary?.stop());
    unawaited(_primary.setVolume(_volume.toDouble()));
  }

  Future<void> play() async {
    if (_queue.current == null) return;
    if (_ended) {
      await _startCurrent(play: true);
      return;
    }
    await _primary.play();
    _setPlaying(true);
  }

  Future<void> pause() async {
    _cancelFade();
    await _primary.pause();
    _setPlaying(false);
  }

  Future<void> toggle() async {
    if (_playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    final track = _queue.advance(auto: false);
    if (track == null) return;
    await _startCurrent(play: true);
  }

  Future<void> previous() async {
    if (_queue.current == null) return;
    if (position.value > restartThreshold) {
      await seek(Duration.zero);
      return;
    }
    final track = _queue.back();
    if (track == null) {
      await seek(Duration.zero);
      return;
    }
    await _startCurrent(play: true);
  }

  Future<void> jumpTo(int queuePosition) async {
    if (!_queue.jumpTo(queuePosition)) return;
    await _startCurrent(play: true);
  }

  Future<void> seek(Duration target) async {
    if (_queue.current == null) return;
    _cancelFade();
    final clamped = target < Duration.zero
        ? Duration.zero
        : (_duration > Duration.zero && target > _duration
              ? _duration
              : target);
    position.value = clamped;
    await _primary.seek(clamped);
    _save();
  }

  Future<void> seekBy(Duration delta) => seek(position.value + delta);

  Future<void> setVolume(int value) async {
    _volume = value.clamp(0, 100);
    if (_volume > 0) _volumeBeforeMute = _volume;
    if (!_fading) await _primary.setVolume(_volume.toDouble());
    notifyListeners();
    _save();
  }

  Future<void> toggleMute() {
    return setVolume(_volume > 0 ? 0 : _volumeBeforeMute);
  }

  Future<void> setShuffle(bool value) async {
    _queue.setShuffle(value);
    notifyListeners();
    await _refreshNext();
    _save();
  }

  Future<void> setRepeat(RepeatSetting value) async {
    _queue.setRepeat(value);
    await _primary.setPlaylistMode(
      value == RepeatSetting.one ? PlaylistMode.single : PlaylistMode.none,
    );
    notifyListeners();
    await _refreshNext();
    _save();
  }

  Future<void> playNext(Track track) async {
    final wasEmpty = _queue.current == null;
    _queue.playNext(track);
    notifyListeners();
    if (wasEmpty) {
      await _startCurrent(play: true);
    } else {
      await _refreshNext();
    }
    _save();
  }

  Future<void> enqueue(Track track) async {
    final wasEmpty = _queue.current == null;
    _queue.enqueue(track);
    notifyListeners();
    if (wasEmpty) {
      await _startCurrent(play: true);
    } else {
      await _refreshNext();
    }
    _save();
  }

  Future<void> restore(Track? Function(String id) resolve) async {
    final saved = _persistence?.load();
    if (saved == null) return;
    _volume = saved.volume.clamp(0, 100);
    if (_volume > 0) _volumeBeforeMute = _volume;
    _queue.restore(saved.queue, resolve);
    if (_queue.current == null) {
      notifyListeners();
      return;
    }
    await _startCurrent(
      play: false,
      startAt: Duration(milliseconds: saved.positionMs),
    );
  }

  void persist() => _save();

  void _save() {
    final persistence = _persistence;
    if (persistence == null || _disposed) return;
    persistence.save(
      SavedPlayback(
        queue: _queue.toJson(),
        positionMs: position.value.inMilliseconds,
        volume: _volume,
      ),
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _save();
    _disposed = true;
    _settings.removeListener(_onSettings);
    _fadeTimer?.cancel();
    _saveTimer?.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    unawaited(_primary.dispose());
    unawaited(_secondary?.dispose());
    position.dispose();
    super.dispose();
  }
}
