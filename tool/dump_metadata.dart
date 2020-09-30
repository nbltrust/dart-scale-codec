/// Dump metadata into a bin file
/// 
/// This tool fetches metadata by 'state_getMetadata' rpc call
/// Shrinks all useless 'doc' fields (binary file size to 5-10% of origin size)
/// And dump metadata into a binary file.
/// The binary file will be named as 'metadata.${milli-second-since-epoch}.bin'
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:scalecodec/scalecodec.dart';

import 'dump_metadata.reflectable.dart';

void main(List<String> args) async {
  var url = 'wss://cc1-1.polkadot.network/';
  if(args.length > 0) {
    url = args[0];
  }
  initializeReflectable();
  var ws = await WebSocket.connect(url);
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

  String metadataHex = await result.future;
  
  await ws.close();

  createReaderInstance(metadataHex);
  var magicBytes = getReaderInstance().read(4);
  var magic = String.fromCharCodes(magicBytes);
  if(magic != 'meta') {
    print('invalid magic data');
    exit(-1);
  }

  dynamic metadata = fromBinary('MetadataEnum');
  metadata.obj.modules.objects.forEach((v8mod){
    if(v8mod.storage.presents.val) {
      v8mod.storage.obj.items.objects.forEach((v7ModStorEntry) {
        v7ModStorEntry.docs = Vec([]);
      });
    }
    if(v8mod.calls.presents.val) {
      v8mod.calls.obj.objects.forEach((moduleCall) {
        moduleCall.docs = Vec([]);
      });
    }
    if(v8mod.events.presents.val) {
      v8mod.events.obj.objects.forEach((modEvent) {
        modEvent.docs = Vec([]);
      });
    }
    v8mod.constants.objects.forEach((modConst) {
      modConst.docs = Vec([]);
    });
    v8mod.errors.objects.forEach((modError) {
      modError.docs = Vec([]);
    });
  });

  createWriterInstance();
  getWriterInstance().write(magicBytes);
  (metadata as MetadataEnum).objToBinary();
  var encoded = getWriterInstance().finalize();

  var now = new DateTime.now();
  
  var file = File('metadata.${now.millisecondsSinceEpoch}.bin');
  file.writeAsBytesSync(encoded.toList());
}