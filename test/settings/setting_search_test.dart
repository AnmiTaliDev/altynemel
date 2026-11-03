import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/setting_def.dart';
import 'package:altynemel/settings/setting_search.dart';

const a = IntSetting(
  key: 'crossfadeSeconds',
  group: SettingGroup.playback,
  label: 'Crossfade length',
  hint: 'How long two tracks overlap.',
  defaultValue: 4,
  min: 1,
  max: 12,
);

const b = BoolSetting(
  key: 'hiddenFolders',
  group: SettingGroup.library,
  label: 'Skip hidden folders',
  hint: 'Ignore folders that start with a dot.',
  defaultValue: true,
);

const c = BoolSetting(
  key: 'showTime',
  group: SettingGroup.layout,
  label: 'Show duration',
  hint: 'Duration column in track rows.',
  defaultValue: true,
);

const defs = <SettingDef<Object>>[a, b, c];

void main() {
  test('an empty query returns everything', () {
    expect(searchDefinitions(defs, '  '), defs);
  });

  test('every word must match the label, hint, group or key', () {
    expect(searchDefinitions(defs, 'cross'), [a]);
    expect(searchDefinitions(defs, 'FOLDERS dot'), [b]);
    expect(searchDefinitions(defs, 'library'), [b]);
    expect(searchDefinitions(defs, 'hiddenfolders'), [b]);
    expect(searchDefinitions(defs, 'cross dot'), isEmpty);
  });

  test('groups keep the declared order and skip empty ones', () {
    final groups = groupDefinitions(defs);
    expect(groups.keys.toList(), [
      SettingGroup.playback,
      SettingGroup.layout,
      SettingGroup.library,
    ]);
    expect(groups[SettingGroup.library], [b]);
  });
}
