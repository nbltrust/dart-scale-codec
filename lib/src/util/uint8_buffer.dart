import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:typed_data/typed_buffers.dart';

String strip0x(String hex) {
  if (hex.startsWith('0x')) return hex.substring(2);
  return hex;
}

class BufferedReader {
  final Uint8List _data;
  final disable_overflow;
  int _current_position;
  BufferedReader(this._data, [this.disable_overflow = true]) {
    _current_position = 0;
  }

  factory BufferedReader.fromHex(String hex_str, [disable_overflow = true]) {
    return BufferedReader(hex.decode(strip0x(hex_str)), disable_overflow);
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
    assert(length >= 0, "invalid length");
    if(disable_overflow && end > _data.length) {
      throw "read overflow";
    }
    end = end < _data.length? end : _data.length;
    int begin = _current_position;
    _current_position = end;
    return _data.sublist(begin, end);
  }
}

BufferedReader readerInstance = null;
BufferedReader compactReaderInstance = null;

void createReaderInstance(String hex) {
  readerInstance = BufferedReader.fromHex(hex);
}

void createCompactReaderInstance(Uint8List data) {
  compactReaderInstance = BufferedReader(data, false);
}

void finishCompactReader() {
  assert(compactReaderInstance != null, "not in compact reader mode");

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

  Uint8List finalize() {
    return Uint8List.fromList(b.toList());
  }
}

BufferedWriter writerInstance = null;
BufferedWriter compactWriterInstance = null;

void createWriterInstance() {
  writerInstance = BufferedWriter();
}

void createCompactWriterInstance() {
  compactWriterInstance = BufferedWriter();
}

Uint8List finishCompactWriter() {
  assert(compactWriterInstance != null, "not in compact writer mode");
  var r = compactWriterInstance.finalize();
  compactWriterInstance = null;
  return r;
}

BufferedWriter getWriterInstance() {
  return compactWriterInstance ?? writerInstance;
}