import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';

import '../library/track.dart';
import '../player/playback_controller.dart';
import '../player/repeat_setting.dart';
import '../strings.dart';

const String mprisRootInterface = 'org.mpris.MediaPlayer2';
const String mprisPlayerInterface = 'org.mpris.MediaPlayer2.Player';
const String mprisBusName = 'org.mpris.MediaPlayer2.altynemel';
const String mprisDesktopEntry = 'dev.anmitali.altynemel';

final DBusObjectPath mprisPath = DBusObjectPath('/org/mpris/MediaPlayer2');
final DBusObjectPath mprisNoTrack = DBusObjectPath(
  '/org/mpris/MediaPlayer2/TrackList/NoTrack',
);

const Duration _seekJump = Duration(seconds: 2);

DBusObjectPath mprisTrackPath(String id) {
  final encoded = id.codeUnits
      .map((unit) => unit.toRadixString(16).padLeft(4, '0'))
      .join();
  return DBusObjectPath('/dev/anmitali/altynemel/track/$encoded');
}

String mprisLoopStatus(RepeatSetting repeat) {
  return switch (repeat) {
    RepeatSetting.off => 'None',
    RepeatSetting.one => 'Track',
    RepeatSetting.all => 'Playlist',
  };
}

RepeatSetting? mprisRepeat(String status) {
  return switch (status) {
    'None' => RepeatSetting.off,
    'Track' => RepeatSetting.one,
    'Playlist' => RepeatSetting.all,
    _ => null,
  };
}

Map<String, DBusValue> mprisMetadata(Track? track, Duration duration) {
  if (track == null) {
    return {'mpris:trackid': mprisNoTrack};
  }
  final length = duration > Duration.zero ? duration : track.duration;
  final cover = track.coverPath;
  final album = track.album;
  return {
    'mpris:trackid': mprisTrackPath(track.id),
    'mpris:length': DBusInt64(length.inMicroseconds),
    if (cover != null) 'mpris:artUrl': DBusString(Uri.file(cover).toString()),
    'xesam:title': DBusString(track.title),
    if (track.artist.trim().isNotEmpty)
      'xesam:artist': DBusArray.string([track.artist]),
    if (album != null) 'xesam:album': DBusString(album),
  };
}

class MprisService extends DBusObject {
  MprisService({
    required this.playback,
    required this.onRaise,
    required this.onQuit,
    DBusClient? client,
  }) : _client = client,
       super(mprisPath);

  final PlaybackController playback;
  final Future<void> Function() onRaise;
  final Future<void> Function() onQuit;
  final DBusClient? _client;
  DBusClient? _owned;
  Map<String, DBusValue> _published = {};
  Duration _lastPosition = Duration.zero;

  Future<bool> start() async {
    try {
      final client = _client ?? DBusClient.session();
      _owned = client;
      await client.registerObject(this);
      final reply = await client.requestName(
        mprisBusName,
        flags: {DBusRequestNameFlag.doNotQueue},
      );
      if (reply == DBusRequestNameReply.exists) {
        await client.unregisterObject(this);
        return false;
      }
      _published = _playerProperties();
      _lastPosition = playback.position.value;
      playback.addListener(_onPlayback);
      playback.position.addListener(_onPosition);
      return true;
    } on DBusMethodResponseException {
      return false;
    } on SocketException {
      return false;
    }
  }

  Future<void> dispose() async {
    playback.removeListener(_onPlayback);
    playback.position.removeListener(_onPosition);
    await _owned?.close();
  }

  Map<String, DBusValue> _rootProperties() {
    return {
      'CanQuit': const DBusBoolean(true),
      'CanRaise': const DBusBoolean(true),
      'CanSetFullscreen': const DBusBoolean(false),
      'Fullscreen': const DBusBoolean(false),
      'HasTrackList': const DBusBoolean(false),
      'Identity': const DBusString(Strings.appName),
      'DesktopEntry': const DBusString(mprisDesktopEntry),
      'SupportedUriSchemes': DBusArray.string(const []),
      'SupportedMimeTypes': DBusArray.string(const []),
    };
  }

  Map<String, DBusValue> _playerProperties() {
    final hasTrack = playback.hasTrack;
    final status = !hasTrack
        ? 'Stopped'
        : playback.isPlaying
        ? 'Playing'
        : 'Paused';
    return {
      'PlaybackStatus': DBusString(status),
      'LoopStatus': DBusString(mprisLoopStatus(playback.repeat)),
      'Rate': const DBusDouble(1),
      'MinimumRate': const DBusDouble(1),
      'MaximumRate': const DBusDouble(1),
      'Shuffle': DBusBoolean(playback.shuffle),
      'Metadata': DBusDict.stringVariant(
        mprisMetadata(playback.current, playback.duration),
      ),
      'Volume': DBusDouble(playback.volume / 100),
      'CanGoNext': DBusBoolean(hasTrack),
      'CanGoPrevious': DBusBoolean(hasTrack),
      'CanPlay': DBusBoolean(hasTrack),
      'CanPause': DBusBoolean(hasTrack),
      'CanSeek': DBusBoolean(hasTrack),
      'CanControl': const DBusBoolean(true),
    };
  }

  DBusInt64 _position() {
    return DBusInt64(playback.position.value.inMicroseconds);
  }

  void _onPlayback() {
    final current = _playerProperties();
    final changed = <String, DBusValue>{
      for (final entry in current.entries)
        if (_published[entry.key] != entry.value) entry.key: entry.value,
    };
    _published = current;
    if (changed.isEmpty) return;
    emitPropertiesChanged(mprisPlayerInterface, changedProperties: changed);
  }

  void _onPosition() {
    final value = playback.position.value;
    final jump = (value - _lastPosition).abs();
    _lastPosition = value;
    if (jump > _seekJump) {
      emitSignal(mprisPlayerInterface, 'Seeked', [_position()]);
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    final value = switch (interface) {
      mprisRootInterface => _rootProperties()[name],
      mprisPlayerInterface =>
        name == 'Position' ? _position() : _playerProperties()[name],
      _ => null,
    };
    if (value == null) return DBusMethodErrorResponse.unknownProperty();
    return DBusGetPropertyResponse(value);
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    final properties = switch (interface) {
      mprisRootInterface => _rootProperties(),
      mprisPlayerInterface => {..._playerProperties(), 'Position': _position()},
      _ => null,
    };
    if (properties == null) return DBusMethodErrorResponse.unknownInterface();
    return DBusGetAllPropertiesResponse(properties);
  }

  @override
  Future<DBusMethodResponse> setProperty(
    String interface,
    String name,
    DBusValue value,
  ) async {
    if (interface != mprisPlayerInterface) {
      return DBusMethodErrorResponse.propertyReadOnly();
    }
    switch (name) {
      case 'Volume':
        await playback.setVolume((value.asDouble() * 100).round());
      case 'Shuffle':
        await playback.setShuffle(value.asBoolean());
      case 'LoopStatus':
        final repeat = mprisRepeat(value.asString());
        if (repeat == null) return DBusMethodErrorResponse.invalidArgs();
        await playback.setRepeat(repeat);
      default:
        return DBusMethodErrorResponse.propertyReadOnly();
    }
    return DBusMethodSuccessResponse();
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == mprisRootInterface) {
      switch (methodCall.name) {
        case 'Raise':
          await onRaise();
        case 'Quit':
          await onQuit();
        default:
          return DBusMethodErrorResponse.unknownMethod();
      }
      return DBusMethodSuccessResponse();
    }
    if (methodCall.interface != mprisPlayerInterface) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    switch (methodCall.name) {
      case 'Play':
        await playback.play();
      case 'Pause':
      case 'Stop':
        await playback.pause();
      case 'PlayPause':
        await playback.toggle();
      case 'Next':
        await playback.next();
      case 'Previous':
        await playback.previous();
      case 'Seek':
        if (methodCall.values.length != 1) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        await playback.seekBy(
          Duration(microseconds: methodCall.values[0].asInt64()),
        );
        await emitSignal(mprisPlayerInterface, 'Seeked', [_position()]);
      case 'SetPosition':
        if (methodCall.values.length != 2) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        final track = playback.current;
        if (track == null ||
            methodCall.values[0].asObjectPath() != mprisTrackPath(track.id)) {
          break;
        }
        await playback.seek(
          Duration(microseconds: methodCall.values[1].asInt64()),
        );
        await emitSignal(mprisPlayerInterface, 'Seeked', [_position()]);
      case 'OpenUri':
        break;
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
    return DBusMethodSuccessResponse();
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    DBusIntrospectProperty property(
      String name,
      String type, {
      DBusPropertyAccess access = DBusPropertyAccess.read,
    }) => DBusIntrospectProperty(name, DBusSignature(type), access: access);

    DBusIntrospectArgument input(String type, String name) =>
        DBusIntrospectArgument(
          DBusSignature(type),
          DBusArgumentDirection.in_,
          name: name,
        );

    return [
      DBusIntrospectInterface(
        mprisRootInterface,
        methods: [DBusIntrospectMethod('Raise'), DBusIntrospectMethod('Quit')],
        properties: [
          property('CanQuit', 'b'),
          property('CanRaise', 'b'),
          property('CanSetFullscreen', 'b'),
          property('Fullscreen', 'b'),
          property('HasTrackList', 'b'),
          property('Identity', 's'),
          property('DesktopEntry', 's'),
          property('SupportedUriSchemes', 'as'),
          property('SupportedMimeTypes', 'as'),
        ],
      ),
      DBusIntrospectInterface(
        mprisPlayerInterface,
        methods: [
          DBusIntrospectMethod('Play'),
          DBusIntrospectMethod('Pause'),
          DBusIntrospectMethod('PlayPause'),
          DBusIntrospectMethod('Stop'),
          DBusIntrospectMethod('Next'),
          DBusIntrospectMethod('Previous'),
          DBusIntrospectMethod('Seek', args: [input('x', 'Offset')]),
          DBusIntrospectMethod(
            'SetPosition',
            args: [input('o', 'TrackId'), input('x', 'Position')],
          ),
          DBusIntrospectMethod('OpenUri', args: [input('s', 'Uri')]),
        ],
        signals: [
          DBusIntrospectSignal(
            'Seeked',
            args: [
              DBusIntrospectArgument(
                DBusSignature('x'),
                DBusArgumentDirection.out,
                name: 'Position',
              ),
            ],
          ),
        ],
        properties: [
          property('PlaybackStatus', 's'),
          property('LoopStatus', 's', access: DBusPropertyAccess.readwrite),
          property('Rate', 'd'),
          property('MinimumRate', 'd'),
          property('MaximumRate', 'd'),
          property('Shuffle', 'b', access: DBusPropertyAccess.readwrite),
          property('Metadata', 'a{sv}'),
          property('Volume', 'd', access: DBusPropertyAccess.readwrite),
          property('Position', 'x'),
          property('CanGoNext', 'b'),
          property('CanGoPrevious', 'b'),
          property('CanPlay', 'b'),
          property('CanPause', 'b'),
          property('CanSeek', 'b'),
          property('CanControl', 'b'),
        ],
      ),
    ];
  }
}
