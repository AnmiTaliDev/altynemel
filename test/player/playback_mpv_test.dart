import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:altynemel/player/playback_controller.dart';
import 'package:altynemel/settings/app_settings.dart';
import 'package:altynemel/settings/catalog.dart';
import 'package:altynemel/settings/choices.dart';

class MpvRig {
  MpvRig({void Function(AppSettings settings)? preset}) {
    settings = AppSettings();
    preset?.call(settings);
    controller = PlaybackController(
      settings: settings,
      playerFactory: () => player = createPlayer(),
    );
  }

  late final AppSettings settings;
  late final PlaybackController controller;
  late final Player player;

  NativePlayer get native => player.platform! as NativePlayer;

  Future<String> property(String name) => native.getProperty(name);

  Future<void> dispose() async {
    controller.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    settings.dispose();
  }
}

void main() {
  setUpAll(() {
    MediaKit.ensureInitialized();
    NativePlayer.test = true;
  });

  late MpvRig rig;

  tearDown(() => rig.dispose());

  test('pitch correction is on by default', () async {
    rig = MpvRig();
    expect(await rig.property('audio-pitch-correction'), 'yes');
  });

  test('pitch correction follows the setting', () async {
    rig = MpvRig(preset: (s) => s.setValue(pitchCorrection, false));
    expect(await rig.property('audio-pitch-correction'), 'no');
    rig.settings.setValue(pitchCorrection, true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await rig.property('audio-pitch-correction'), 'yes');
  });

  test('normalization is off by default', () async {
    rig = MpvRig();
    expect(await rig.property('replaygain'), 'no');
  });

  test('normalization follows the setting', () async {
    rig = MpvRig(preset: (s) => s.setValue(replayGain, ReplayGainMode.album));
    expect(await rig.property('replaygain'), 'album');
    rig.settings.setValue(replayGain, ReplayGainMode.track);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await rig.property('replaygain'), 'track');
  });
}
