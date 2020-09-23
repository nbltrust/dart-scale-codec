part of 'types.dart';

// [type; repeat]
class FixedLengthArr extends BaseType {
  List<BaseType> values = [];
  FixedLengthArr(int length, String baseType){
    for(var i = 0; i < length; i++) {
      values.add(fromBinary(baseType));
    }
  }
}

// (type1, type2, type3,...)
class AnonymousStruct extends BaseType {
  List<BaseType> data;
  AnonymousStruct(List<String> subtypes) {
    for(var s in subtypes) {
      data.add(fromBinary(s));
    }
  }
}

class StorageHasher extends Int8 {
  static const List<String> hasher_functions = 
  ['Blake2_128', 'Blake2_256', 'Blake2_128Concat', 'Twox128', 'Twox256', 'Twox64Concat', 'Identity'];
  dynamic toJson() => hasher_functions[val];
}

class PlainType extends Bytes {
  dynamic toJson() => String.fromCharCodes(val);
}

class MapType extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('hasher', 'StorageHasher'),
    Tuple2('key', 'Str'),
    Tuple2('value', 'Str'),
    Tuple2('isLinked', 'Bool')
  ];
}

class DoubleMapType extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('hasher', 'StorageHasher'),
    Tuple2('key1', 'Str'),
    Tuple2('key2', 'Str'),
    Tuple2('value', 'Bytes'),
    Tuple2('key2Hasher', 'StorageHasher')
  ];
}