part of 'types.dart';

class StorageHasher extends Int8 {
  static const List<String> hasher_functions = 
  ['Blake2_128', 'Blake2_256', 'Blake2_128Concat', 'Twox128', 'Twox256', 'Twox64Concat', 'Identity'];
  dynamic toJson() => hasher_functions[val];
  StorageHasher.fromJson(dynamic s):super(-1) {
    var idx = hasher_functions.indexOf(s as String);
    assert(idx >= 0, "invalid value of StorageHasher");
    val = idx;
  }
  StorageHasher.fromBinary():super.fromBinary();
}

// class PlainType extends Str {
//   PlainType.fromJson(String s):super.fromJson(s);
//   PlainType.fromBinary():super.fromBinary();
// }

class MapType extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('hasher', 'StorageHasher'),
    Tuple2('key', 'Str'),
    Tuple2('value', 'Str'),
    Tuple2('isLinked', 'Bool')
  ];
  MapType.fromBinary():super.fromBinary();
  MapType.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class DoubleMapType extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('hasher', 'StorageHasher'),
    Tuple2('key1', 'Str'),
    Tuple2('key2', 'Str'),
    Tuple2('value', 'Bytes'),
    Tuple2('key2Hasher', 'StorageHasher')
  ];
  DoubleMapType.fromBinary():super.fromBinary();
  DoubleMapType.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class Address extends ScaleCodecBase {
  Uint8List address;

  Address(this.address);

  void objToBinary() {
    getWriterInstance().write(address);
  }

  dynamic toJson() => base58.encode(address);

  Address.fromBinary() {
    address = getReaderInstance().read(32);
  }

  Address.fromJson(String s) {
    address = base58.decode(s);
  }
}

/// An Era represents a range of blocks in which a transaction is allowed to be
/// executed.
/// 
/// An Era may either be "immortal", in which case the transaction is always 
/// valid, or "mortal", in which case the transaction has a defined start block
/// and period in which it is valid.
class Era extends  ScaleCodecBase {
  int firstByte;
  int secondByte;

  /// Override constructor of [GeneralStruct]
  /// Two fields of Era are not always presented 
  Era.fromBinary(){
    firstByte = (fromBinary('u8') as u8).val;
    if(firstByte != 0) {
      secondByte = (fromBinary('u8') as u8).val;
    }
  }

  void objToBinary() {
    u8(firstByte).objToBinary();
    if(firstByte != 0) {
      u8(secondByte).objToBinary();
    }
  }

  int get encoded => firstByte | (secondByte << 8);

  int get period {
    if(firstByte == 0) {
      return null;
    }
    int _period = 2 << (firstByte & 0xf);
    assert(_period >= 4, "invalid period");
    return _period;
  }

  int get phase {
    int factor = max(1, period >> 12);
    int _phase = (encoded >> 4) * factor;
    assert(_phase < period);
    return _phase;
  }

  dynamic toJson() => {'period': period, 'phase': phase};

  Era.fromJson(Map<String, dynamic> s) {
    if(s['period'] == null || s['phase'] == null) {
      assert(s['period'] == null && s['phase'] == null, "period and phase must be both (or both not) be null");
      firstByte = 0;
      secondByte = 0;
    } else {
      int period = s['period'] as int;
      int phase = s['phase'] as int;
      int factor = max(1, period >> 12);
      firstByte = min(15, max(1, trailing_zeros(period) - 1));
      secondByte = (phase ~/ factor) << 4;
    }
  }
}