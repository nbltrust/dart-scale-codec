library scalecodec_test.metadata_tests;

import 'dart:io';

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'metadata_refl_test.reflectable.dart';

void main() {
  initializeReflectable();
  test('test metadata reflection', () {
    File f = new File('metadata.bin');
    String hex_str = hex.encode(f.readAsBytesSync());
    createReaderInstance(hex_str);
    getReaderInstance().read(4);//skip magic
    dynamic metadata = fromBinary('MetadataEnum');

    createWriterInstance();
    (metadata as MetadataEnum).objToBinary();
    var encoded = getWriterInstance().finalize();
    var encoded_str = hex.encode(encoded);

    // the encoded metadata should be the same as original(skip first 4 magic bytes)
    expect(encoded_str, hex_str.substring(8));
  });
}
