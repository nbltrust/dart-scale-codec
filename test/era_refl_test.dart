library scalecodec_test.era_refl_test;

import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'era_refl_test.reflectable.dart';

Era decodeEra(String hex) {
  createReaderInstance(hex);
  return fromBinary('Era');
}

String encodeEra(Map<String, dynamic> json) {
  var era = Era.fromJson(json);
  createWriterInstance();
  era.objToBinary();
  return hex.encode(getWriterInstance().finalize());
}
void main() {
  initializeReflectable();
  test('encode era test', () {
    expect(encodeEra({'period': null, 'phase': null}), '00');
    expect(encodeEra({'period': 64, 'phase': 40}), '8502');
    expect(encodeEra({'period': 64, 'phase': 60}), 'c503');
    expect(encodeEra({'period': 32768, 'phase': 20000}), '4e9c');
  });

  test('decode era test', () {
    var era1 = decodeEra('00');
    expect(era1.period, null);
    expect(era1.phase, null);

    var era2 = decodeEra('8502');
    expect(era2.period, 64);
    expect(era2.phase, 40);

    var era3 = decodeEra('c503');
    expect(era3.period, 64);
    expect(era3.phase, 60);

    var era4 = decodeEra('4e9c');
    expect(era4.period, 32768);
    expect(era4.phase, 20000);

    expect(jsonDecode(jsonEncode(era4)), {'period': 32768, 'phase': 20000});
  });

  test('decode era error', () {
    expect(() => Era.fromJson({'period': 64, 'phase': null}), throwsException);
    expect(() => Era.fromJson({'period': null, 'phase': 60}), throwsException);
  });
}