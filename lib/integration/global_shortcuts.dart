import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';

import '../player/playback_controller.dart';
import '../strings.dart';

const String _service = 'org.freedesktop.portal.Desktop';
const String _path = '/org/freedesktop/portal/desktop';
const String _shortcutsInterface = 'org.freedesktop.portal.GlobalShortcuts';
const String _requestInterface = 'org.freedesktop.portal.Request';

class ShortcutSpec {
  const ShortcutSpec(this.id, this.description, this.trigger);

  final String id;
  final String description;
  final String trigger;
}

const List<ShortcutSpec> globalShortcutSpecs = [
  ShortcutSpec('play-pause', Strings.playPauseShortcut, 'CTRL+ALT+space'),
  ShortcutSpec('next', Strings.nextTrack, 'CTRL+ALT+Right'),
  ShortcutSpec('previous', Strings.previousTrack, 'CTRL+ALT+Left'),
];

String requestPath(String uniqueName, String token) {
  final sender = uniqueName.replaceFirst(':', '').replaceAll('.', '_');
  return '$_path/request/$sender/$token';
}

Map<String, Future<void> Function()> shortcutActions(
  PlaybackController playback,
) {
  return {
    'play-pause': playback.toggle,
    'next': playback.next,
    'previous': playback.previous,
  };
}

class GlobalShortcuts {
  GlobalShortcuts({
    required this.actions,
    DBusClient? client,
    this.specs = globalShortcutSpecs,
  }) : _client = client ?? DBusClient.session();

  final Map<String, Future<void> Function()> actions;
  final List<ShortcutSpec> specs;
  final DBusClient _client;
  StreamSubscription<DBusSignal>? _activated;
  int _counter = 0;

  Future<bool> start() async {
    try {
      final portal = DBusRemoteObject(
        _client,
        name: _service,
        path: DBusObjectPath(_path),
      );
      final version = await portal.getProperty(_shortcutsInterface, 'version');
      if (version.asUint32() < 1) return false;
      final results = await _request(
        'CreateSession',
        (token) => [
          DBusDict.stringVariant({
            'handle_token': DBusString(token),
            'session_handle_token': DBusString('altynemel_$token'),
          }),
        ],
      );
      final handle = results['session_handle']?.asVariant();
      if (handle == null) return false;
      final session = DBusObjectPath(handle.asString());
      _activated = DBusSignalStream(
        _client,
        sender: _service,
        interface: _shortcutsInterface,
        name: 'Activated',
        path: DBusObjectPath(_path),
      ).listen((signal) => _onActivated(session, signal));
      await _request(
        'BindShortcuts',
        (token) => [
          session,
          DBusArray(DBusSignature('(sa{sv})'), [
            for (final spec in specs)
              DBusStruct([
                DBusString(spec.id),
                DBusDict.stringVariant({
                  'description': DBusString(spec.description),
                  'preferred_trigger': DBusString(spec.trigger),
                }),
              ]),
          ]),
          const DBusString(''),
          DBusDict.stringVariant({'handle_token': DBusString(token)}),
        ],
      );
      return true;
    } on DBusMethodResponseException {
      return false;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  void _onActivated(DBusObjectPath session, DBusSignal signal) {
    final values = signal.values;
    if (values.length < 2) return;
    if (values[0].asObjectPath() != session) return;
    dispatch(values[1].asString());
  }

  Future<void> dispatch(String id) async {
    final action = actions[id];
    if (action != null) await action();
  }

  Future<Map<String, DBusValue>> _request(
    String method,
    List<DBusValue> Function(String token) arguments,
  ) async {
    final token = 'altynemel${_counter++}';
    final request = DBusObjectPath(requestPath(_client.uniqueName, token));
    final response = DBusSignalStream(
      _client,
      sender: _service,
      interface: _requestInterface,
      name: 'Response',
      path: request,
    ).first.timeout(const Duration(seconds: 120));
    final portal = DBusRemoteObject(
      _client,
      name: _service,
      path: DBusObjectPath(_path),
    );
    await portal.callMethod(
      _shortcutsInterface,
      method,
      arguments(token),
      replySignature: DBusSignature('o'),
    );
    final signal = await response;
    if (signal.values[0].asUint32() != 0) {
      throw DBusMethodResponseException(
        DBusMethodErrorResponse('$_requestInterface.Denied'),
      );
    }
    return signal.values[1].asStringVariantDict();
  }

  Future<void> dispose() async {
    await _activated?.cancel();
    await _client.close();
  }
}
