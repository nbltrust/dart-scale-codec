library scalecodec_test.generic_call_tests;

import 'dart:convert';

import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';
import 'runtime.dart';
import 'generic_call_refl_test.reflectable.dart';

void main() {
  initializeReflectable();
  initRuntimeMetadata();
  String call_hex_str = '0x0500913d5f22d531d1ab7f7ec337f50a5e856e83d2c145f009f0b23514c088f86a270700e40b5402001800160000000400000097094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d57597094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d575';
  createReaderInstance(call_hex_str);
  dynamic call = fromBinary('GenericCall');
  // print(jsonEncode(call));
  test('Generic call v11 decode', () {
    expect(call.runtimeType, GenericCall);
    var c = call as GenericCall;
    expect((c.module.name as Str).val, 'Balances');
    expect(c.function_name.val, 'transfer');
  });
}