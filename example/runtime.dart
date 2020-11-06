import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';

/// Get metadata object
/// 
/// ### Usage1: 
/// set [from] to url to load from substrate node
/// ```
/// var metadata = initRuntimeMetadata('wss://cc1-1.polkadot.network/');
/// ```
/// 
/// ### Usage2:
/// set [from] to local file path to load from local file system
/// ```
/// var metadata = initRuntimeMetadata('local_metadata_file.bin');
/// ```
/// metadata file can be generated from command line tool tool/dump_metadata.dart
/// 
/// return [MetadataEnum] as loaded data
Future<MetadataEnum> getMetadata(String from) async {
  var metadataHex = '';
  if(from.startsWith('wss')) {
    var ws = await WebSocket.connect(from);
    var result = new Completer();
    ws.listen((msg) {
      result.complete(jsonDecode(msg)['result']);
    });
    ws.add(jsonEncode(
      {
        "jsonrpc": "2.0",
        "method": 'state_getMetadata',
        "params": null,
        "id": 1
      }
    ));

    metadataHex = await result.future;
    await ws.close();
  } else {
    File f = new File('metadata.bin');
    metadataHex = hex.encode(await f.readAsBytes());
  }

  createReaderInstance(metadataHex);
  var magic = String.fromCharCodes(getReaderInstance().read(4));
  if(magic != 'meta') {
    throw "Invalid metadata file";
  }

  return fromBinary('MetadataEnum');
}