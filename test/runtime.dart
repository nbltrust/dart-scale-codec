import 'dart:io';
import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';

/// Load runtime data from file and init RuntimeConfiguration
/// metadataV12.bin can be generated from tool/dump_metadata.dart
void initRuntimeMetadata() {
  File f = new File('metadataV12.bin');
  String hex_str = hex.encode(f.readAsBytesSync());
  createReaderInstance(hex_str);
  getReaderInstance().read(4);//skip magic
  dynamic metadata = fromBinary('MetadataEnum');
  RuntimeConfigration().registMetadata(metadata);
}
