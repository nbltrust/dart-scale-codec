library scalecodec_test.compact_tests;

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'address_refl_tests.reflectable.dart';

String encode(String hexStr) {
  var a = Address(hex.decode(hexStr));
  return a.toJson();
}

String decode(String b58Str) {
  var a = Address.fromJson(b58Str);
  var b = hex.encode(a.address);
  return b;
}

void main() {
  initializeReflectable();
  test('test decode', () {
    expect(
      decode('14HSB7tpJf17F1XXzC1GUiPH6c6g9UvTkKC4w4edX8vKte84'),
      '913d5f22d531d1ab7f7ec337f50a5e856e83d2c145f009f0b23514c088f86a27');
  });

  test('test encode', () {
    expect(
      encode('913d5f22d531d1ab7f7ec337f50a5e856e83d2c145f009f0b23514c088f86a27'), 
      '14HSB7tpJf17F1XXzC1GUiPH6c6g9UvTkKC4w4edX8vKte84');
  });

  test('test encode', () {
    expect(
      encode('e92adb4530de173812e9a3516fe844ba94d9050f5444719290422389785ed349'),
      '16GitWrCRnWJKQmeSGi5kUzCreeHQYSc8AWNm4LHZgNT6WNh'
    );
  });
}
