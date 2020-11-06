library scalecodec_test.generic_call_tests;

import 'dart:io';
import 'dart:convert';

import 'package:scalecodec/scalecodec.dart';
import 'package:convert/convert.dart';

import 'generic_call_refl_tests.reflectable.dart';

void main() {
  initializeReflectable();
  File f = new File('metadata.bin');
  String hex_str = hex.encode(f.readAsBytesSync());
  createReaderInstance(hex_str);
  getReaderInstance().read(4);//skip magic
  dynamic metadata = fromBinary('MetadataEnum');
  
  RuntimeConfigration().registMetadata(metadata);
  String call_hex_str = '0x0600913d5f22d531d1ab7f7ec337f50a5e856e83d2c145f009f0b23514c088f86a270700e40b5402001800160000000400000097094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d57597094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d575';
  createReaderInstance(call_hex_str);
  dynamic call = fromBinary('GenericCall');
  print(jsonEncode(call));
}