library scalecodec_demo.decode_extrinsics_demo;

import 'dart:convert';
import 'package:scalecodec/scalecodec.dart';

import 'decode_extrinsics_demo.reflectable.dart';
import 'runtime.dart';

Extrinsics decodeExtrinsics(String callHexStr) {
  createReaderInstance(callHexStr);
  return fromBinary('Extrinsics');
}

void main() async {
  initializeReflectable();
  var metadata = await getMetadata('wss://cc1-1.polkadot.network/');
  RuntimeConfigration().registMetadata(metadata);
  dynamic extrinsics = decodeExtrinsics(
    "0x0500913d5f22d531d1ab7f7ec337f50a5e856e83d2c145f009f0b23514c088f86a270700e40b5402001800160000000400000097094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d57597094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d575");
  print(extrinsics.call.module_index);
  print(extrinsics.call.function_index);
  print(extrinsics.call.argValues['dest'].toJson());
  print(extrinsics.call.argValues['value'].toJson());
  print(jsonEncode(extrinsics));
  print(extrinsics.tip.obj.toJson());
}