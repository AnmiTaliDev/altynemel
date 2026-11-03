import 'setting_def.dart';

const crossfadeSeconds = IntSetting(
  key: 'crossfadeSeconds',
  group: SettingGroup.playback,
  label: 'Crossfade length',
  hint: 'Seconds during which two tracks overlap when crossfade is on.',
  defaultValue: 4,
  min: 1,
  max: 12,
  unit: 's',
);

const previousRestartSeconds = IntSetting(
  key: 'previousRestartSeconds',
  group: SettingGroup.playback,
  label: 'Previous button restart point',
  hint:
      'Past this many seconds the previous button restarts the track instead of going back. Zero always goes back.',
  defaultValue: 3,
  min: 0,
  max: 10,
  unit: 's',
);

const List<SettingDef<Object>> allSettings = [
  crossfadeSeconds,
  previousRestartSeconds,
];
