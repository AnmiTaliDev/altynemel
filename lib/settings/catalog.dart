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

const List<SettingDef<Object>> allSettings = [crossfadeSeconds];
