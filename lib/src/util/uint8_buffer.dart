import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:typed_data/typed_buffers.dart';

String strip0x(String hex) {
  if (hex.startsWith('0x')) return hex.substring(2);
  return hex;
}

class BufferedReader {
  final Uint8List _data;
  int _current_position;
  BufferedReader(this._data) {
    _current_position = 0;
  }

  factory BufferedReader.fromHex(String hex_str) {
    return BufferedReader(hex.decode(strip0x(hex_str)));
  }

  void reset() {
    _current_position = 0;
  }

  // return true if has read to end position
  bool isFinished() {
    return _current_position == _data.length;
  }

  Uint8List read(int length) {
    int end = length + _current_position;
    if(length > 0 && end > _data.length) {
      throw "read overflow";
    }

    int begin = _current_position;
    _current_position += length;
    return _data.sublist(begin, end);
  }
}

BufferedReader readerInstance = null;
BufferedReader compactReaderInstance = null;

void createReaderInstance(String hex) {
  readerInstance = BufferedReader.fromHex(hex);
}

void createCompactReaderInstance(Uint8List data) {
  compactReaderInstance = BufferedReader(data);
}

void finishCompactMode() {
  if(compactReaderInstance == null) {
    throw "not in compact mode";
  }

  if(!compactReaderInstance.isFinished()) {
    throw "have not read all compact bytes when finish compact mode";
  }
  compactReaderInstance = null;
}

BufferedReader getReaderInstance() {
  return compactReaderInstance ?? readerInstance;
}

class BufferedWriter {
  Uint8Buffer b = new Uint8Buffer();

  void write(Uint8List data) {
    b.addAll(data);
  }
}