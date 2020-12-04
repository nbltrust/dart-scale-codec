library scalecodec_test.metadata_refl_test;

import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'metadata_refl_test.reflectable.dart';

void main() {
  initializeReflectable();
  test('test metadata V12 reflection', () {
    File f = new File('metadataV12.bin');
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

    var json_obj = jsonDecode(jsonEncode(metadata));
    var decoded = fromJson('MetadataEnum', json_obj);
    expect((decoded as MetadataEnum).data.runtimeType, MetadataV12);
    createWriterInstance();
    (decoded as MetadataEnum).objToBinary();
    expect(
      encoded_str,
      hex.encode(getWriterInstance().finalize()));
  });

  test('test metadata V11 reflection', () {
    File f = new File('metadataV11.bin');
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

    var json_obj = jsonDecode(jsonEncode(metadata));
    var decoded = fromJson('MetadataEnum', json_obj);
    createWriterInstance();
    expect((decoded as MetadataEnum).data.runtimeType, MetadataV11);
    (decoded as MetadataEnum).objToBinary();
    expect(
      encoded_str,
      hex.encode(getWriterInstance().finalize()));
  });
}
