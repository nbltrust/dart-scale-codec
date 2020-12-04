# Tool usage

## dump_metadata.dart
This tool is used to fetch the latest metadata from blockchain, and dump it as binary file. Since metadata content is extremely large ( ~300KB, for V12), and most of it are useless documents, we eliminate it from binary file to save space ( ~16KB).
```bash
dart dump_metadata.dart
# metadata.$timestamp.bin file will be generated at current working directory
```
Init metadata from local file
```dart
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';

File f = new File('metadata bin file name');
String hex_str = hex.encode(f.readAsBytesSync());
createReaderInstance(hex_str);
getReaderInstance().read(4);//skip magic
dynamic metadata = fromBinary('MetadataEnum');
RuntimeConfigration().registMetadata(metadata);
```
