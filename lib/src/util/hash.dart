import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as Crypto;

Uint8List doubleSha256(Uint8List data) {
  var sink = Crypto.sha256.newSink();
  sink.add(data.toList());
  sink.close();
  var sink2 = Crypto.sha256.newSink();
  sink2.add(sink.hash.bytes);
  sink2.close();
  return Uint8List.fromList(sink2.hash.bytes);
}