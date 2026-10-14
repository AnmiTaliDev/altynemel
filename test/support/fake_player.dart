import 'package:media_kit/media_kit.dart' hide Track;

class FakePlatformPlayer extends PlatformPlayer {
  FakePlatformPlayer() : super(configuration: const PlayerConfiguration());

  final List<String> log = [];

  void _emitPlaylist() => playlistController.add(state.playlist);

  void _setPlaying(bool value) {
    state = state.copyWith(playing: value);
    playingController.add(value);
  }

  void finishTrack() {
    final index = state.playlist.index;
    if (index + 1 < state.playlist.medias.length) {
      state = state.copyWith(
        playlist: state.playlist.copyWith(index: index + 1),
      );
      _emitPlaylist();
    } else {
      state = state.copyWith(completed: true, playing: false);
      playingController.add(false);
      completedController.add(true);
    }
  }

  void emitPosition(Duration value) {
    state = state.copyWith(position: value);
    positionController.add(value);
  }

  @override
  Future<void> open(Playable playable, {bool play = true}) async {
    log.add('open');
    final playlist = playable as Playlist;
    state = state.copyWith(playlist: playlist, completed: false);
    completedController.add(false);
    _emitPlaylist();
    _setPlaying(play);
  }

  @override
  Future<void> play() async {
    log.add('play');
    _setPlaying(true);
  }

  @override
  Future<void> pause() async {
    log.add('pause');
    _setPlaying(false);
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    _setPlaying(false);
  }

  @override
  Future<void> add(Media media) async {
    state = state.copyWith(
      playlist: state.playlist.copyWith(
        medias: [...state.playlist.medias, media],
      ),
    );
  }

  @override
  Future<void> remove(int index) async {
    final medias = [...state.playlist.medias]..removeAt(index);
    state = state.copyWith(playlist: state.playlist.copyWith(medias: medias));
  }

  @override
  Future<void> seek(Duration duration) async {
    log.add('seek');
    emitPosition(duration);
  }

  @override
  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
  }

  @override
  Future<void> setPlaylistMode(PlaylistMode playlistMode) async {
    state = state.copyWith(playlistMode: playlistMode);
  }
}
