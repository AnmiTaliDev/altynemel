import 'choices.dart';
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

const positionSaveSeconds = IntSetting(
  key: 'positionSaveSeconds',
  group: SettingGroup.playback,
  label: 'Position save interval',
  hint: 'How often the playback position is written while playing.',
  defaultValue: 5,
  min: 1,
  max: 60,
  unit: 's',
);

const crossfadeCurve = EnumSetting<CrossfadeCurve>(
  key: 'crossfadeCurve',
  group: SettingGroup.playback,
  label: 'Crossfade curve',
  hint: 'Equal power keeps the loudness steady, linear is a straight ramp.',
  defaultValue: CrossfadeCurve.equalPower,
  values: CrossfadeCurve.values,
  labels: crossfadeCurveLabels,
);

const crossfadeStepMs = IntSetting(
  key: 'crossfadeStepMs',
  group: SettingGroup.playback,
  label: 'Crossfade update step',
  hint: 'Time between volume updates during a crossfade. Smaller is smoother.',
  defaultValue: 50,
  min: 10,
  max: 200,
  step: 10,
  unit: 'ms',
);

const List<SettingDef<Object>> allSettings = [
  crossfadeSeconds,
  previousRestartSeconds,
  positionSaveSeconds,
  crossfadeCurve,
  crossfadeStepMs,
];
