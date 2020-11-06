library scalecodec_test.extrinsics_tests;

import 'dart:convert';

import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'extrinsics_refl_tests.reflectable.dart';
import 'runtime.dart';

Extrinsics decodeExtrinsics(String callHexStr) {
  createReaderInstance(callHexStr);
  return fromBinary('Extrinsics');
}

void main() {
  initializeReflectable();
  initRuntimeMetadata();

  test('test decode', () {
      dynamic extrinsics = decodeExtrinsics(
        "0x0500913d5f22d531d1ab7f7ec337f50a5e856e83d2c145f009f0b23514c088f86a270700e40b5402001800160000000400000097094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d57597094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d575");
      expect(extrinsics.call.module_index, 5);
      expect(extrinsics.call.function_index, 0);
      expect(extrinsics.call.argValues['dest'].toJson(), '14HSB7tpJf17F1XXzC1GUiPH6c6g9UvTkKC4w4edX8vKte84');
      expect(extrinsics.call.argValues['value'].toJson(), '10000000000');
      expect(extrinsics.tip.obj.toJson(), '0');
  });
}