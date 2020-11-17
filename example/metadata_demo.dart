import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'metadata_demo.reflectable.dart';

void main() async {
  initializeReflectable();
  var ws = await WebSocket.connect('wss://cc1-1.polkadot.network/');
  var fut = Completer();
  ws.listen((msg) {
    var r = jsonDecode(msg) as Map<String, dynamic>;
    fut.complete(r['result']);
  });
  ws.add(jsonEncode({
      'jsonrpc': '2.0',
      'method': 'state_getMetadata',
      'params': [],
      'id': 1
    }));

  var metaHex = await fut.future;

  createReaderInstance(metaHex);
  var magic = String.fromCharCodes(getReaderInstance().read(4));
  if(magic != 'meta') {
    throw "Invalid metadata";
  }
  var metadata = fromBinary('MetadataEnum');
  var metadataJson = jsonEncode(metadata);

  var metadata2 = MetadataEnum.fromJson(jsonDecode(metadataJson));

  createWriterInstance();
  getWriterInstance().write(Uint8List.fromList("meta".codeUnits));
  metadata2.objToBinary();
  var recoveredMeta = getWriterInstance().finalize();
  var recoveredHex = hex.encode(recoveredMeta);
  if('0x' + recoveredHex != metaHex) {
    print('recovered hex unequal to original');
  } else {
    print('ok');
  }
}