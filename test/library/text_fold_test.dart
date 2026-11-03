import 'package:flutter_test/flutter_test.dart';

import 'package:altynemel/library/text_fold.dart';

void main() {
  test('latin accents fold to plain letters', () {
    expect(foldAccents('Bjørk Ødegård'), 'bjork odegard');
    expect(foldAccents('Beyoncé'), 'beyonce');
    expect(foldAccents('Łódź'), 'lodz');
  });

  test('cyrillic yo and short i fold to their base letters', () {
    expect(foldAccents('Ёлка'), 'елка');
    expect(foldAccents('Майк'), 'маик');
  });

  test('plain text is only lower cased', () {
    expect(foldAccents('Hello World 42'), 'hello world 42');
    expect(foldAccents(''), '');
  });
}
