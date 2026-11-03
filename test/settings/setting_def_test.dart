import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/settings/setting_def.dart';

enum Mode { first, second }

const intDef = IntSetting(
  key: 'i',
  group: SettingGroup.playback,
  label: 'Int',
  hint: '',
  defaultValue: 5,
  min: 1,
  max: 10,
  unit: 's',
);

const doubleDef = DoubleSetting(
  key: 'd',
  group: SettingGroup.sound,
  label: 'Double',
  hint: '',
  defaultValue: 1,
  min: 0.5,
  max: 2,
  unit: 'x',
);

const boolDef = BoolSetting(
  key: 'b',
  group: SettingGroup.layout,
  label: 'Bool',
  hint: '',
  defaultValue: true,
);

const enumDef = EnumSetting<Mode>(
  key: 'e',
  group: SettingGroup.library,
  label: 'Enum',
  hint: '',
  defaultValue: Mode.first,
  values: Mode.values,
  labels: {Mode.first: 'First', Mode.second: 'Second'},
);

const textDef = TextSetting(
  key: 't',
  group: SettingGroup.search,
  label: 'Text',
  hint: '',
  defaultValue: 'a,b',
);

void main() {
  test('int settings clamp, encode and describe', () {
    expect(intDef.normalize(99), 10);
    expect(intDef.normalize(-3), 1);
    expect(intDef.decode('7'), 7);
    expect(intDef.decode('x'), isNull);
    expect(intDef.describe(4), '4 s');
  });

  test('double settings snap to their precision and clamp', () {
    expect(doubleDef.normalize(0.123), 0.5);
    expect(doubleDef.normalize(1.26), 1.3);
    expect(doubleDef.encode(1.5), '1.5');
    expect(doubleDef.describe(1.5), '1.5 x');
    expect(doubleDef.decode('abc'), isNull);
  });

  test('bool settings accept only true and false', () {
    expect(boolDef.decode('true'), isTrue);
    expect(boolDef.decode('false'), isFalse);
    expect(boolDef.decode('yes'), isNull);
    expect(boolDef.describe(false), 'Off');
  });

  test('enum settings round trip by name and have labels', () {
    expect(enumDef.encode(Mode.second), 'second');
    expect(enumDef.decode('second'), Mode.second);
    expect(enumDef.decode('third'), isNull);
    expect(enumDef.describe(Mode.second), 'Second');
  });

  test('text settings are trimmed', () {
    expect(textDef.normalize('  x, y '), 'x, y');
    expect(textDef.decode('q'), 'q');
  });
}
