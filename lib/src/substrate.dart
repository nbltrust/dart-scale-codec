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
  List<BaseType> fields;
  AnonymousStruct(List<String> subtypes) {
    for(var s in subtypes) {
      fields.add(fromBinary(s));
    }
  }
}

class StorageHasher extends Int8 {
}

class PlainType extends Bytes {
}

class MapType extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('hasher', 'StorageHasher'),
    Tuple2('key', 'Bytes'),
    Tuple2('value', 'Bytes'),
    Tuple2('isLinked', 'Bool')
  ];
}

class DoubleMapType extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('hasher', 'StorageHasher'),
    Tuple2('key1', 'Bytes'),
    Tuple2('key2', 'Bytes'),
    Tuple2('value', 'Bytes'),
    Tuple2('key2Hasher', 'StorageHasher')
  ];
}