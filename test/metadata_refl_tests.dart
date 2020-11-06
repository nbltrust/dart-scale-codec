library scalecodec_test.metadata_tests;

import 'dart:io';

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';

import 'metadata_refl_tests.reflectable.dart';

void main() {
  initializeReflectable();
  File f = new File('metadata.bin');
  String hex_str = f.readAsStringSync();
  createReaderInstance(hex_str);
  getReaderInstance().read(4);//skip magic
  dynamic metadata = fromBinary('MetadataEnum');

  createWriterInstance();
  (metadata as MetadataEnum).objToBinary();
  var encoded = getWriterInstance().finalize();
  var encoded_str = hex.encode(encoded);
  assert(encoded_str == hex_str.substring(10));
}
