library scalecodec_test.compact_tests;

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'str_refl_tests.reflectable.dart';

String encode(String input) {
  createWriterInstance();
  Str.fromJson(input).objToBinary();
  return hex.encode(getWriterInstance().finalize());
}

String decode(String encoded) {
  createReaderInstance(encoded);
  var s = fromBinary('Str');
  return (s as Str).val;
}
void main() {
  initializeReflectable();
  test('test encode', () {
    expect(encode('a'), '0461');
    expect(encode('test string1'), '307465737420737472696e6731');
    expect(
      encode('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'), 
      '11014141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141');
  });

  test('test decode', () {
    expect(decode('0461'), 'a');
    expect(decode('307465737420737472696e6731'), 'test string1');
    expect(decode('11014141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141'),
     'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
  });
}