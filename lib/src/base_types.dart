/// Defines a set of basic scale codec types
part of 'types.dart';

class ScaleTypeReflector extends Reflectable {
  const ScaleTypeReflector() : super(
    libraryCapability,
    subtypeQuantifyCapability,
    reflectedTypeCapability,
    declarationsCapability,
    newInstanceCapability,
    staticInvokeCapability,
    invokingCapability,
    typeRelationsCapability
  );
}

const scaleTypeReflector = ScaleTypeReflector();

/// Base Class of all reflected types
/// 
/// The Capability [subtypeQuantifyCapability] enables all derived classes
/// to gain same capabilities of [ScaleCodecBase]
@scaleTypeReflector
abstract class ScaleCodecBase {
  @override
  noSuchMethod(Invocation invocation) {
    var symStr = invocation.memberName.toString();
    // Any better way to get symbol name? flutter disables dart.mirrors
    var symbol = symStr.substring(8, symStr.length - 2);
    if(invocation.isGetter) {
      return getSymbol(symbol);
    } else if(invocation.isSetter) {
      symbol = symbol.substring(0, symbol.length - 1); // eliminate tailing '='
      setSymbol(symbol, invocation.positionalArguments[0]);
    }
  }
  ScaleCodecBase(){}
  ScaleCodecBase.fromBinary() {}
  void objToBinary() {}

  dynamic toJson() => {};  
  ScaleCodecBase getSymbol(String s) => null;
  void setSymbol(String s, ScaleCodecBase b) {}
}

ClassMirror getDecoderClass(String class_name) {
  var libraryMirror = scaleTypeReflector.findLibrary('scalecodec.types');
  var mirror = libraryMirror.declarations[class_name];
  if(mirror == null)
    throw Exception("Class ${class_name} not found in reflection system");
  return mirror;
}

/// Build an object of typeName from universal [BufferedReader]
/// 
/// ```dart
/// createReaderInstance(hex_str);
/// var obj = fromBinary('Option<Vec<MapType>>');
/// for(var i in (obj as Option) as Vec) {
///   print((i as MapType).key);
/// }
/// ```
ScaleCodecBase fromBinary(String typeName) {
  var typeRes = processTypeName(typeName);
  switch (typeRes.item1) {
    case 'AnonymousStruct':
      var subTypeArr = typeRes.item2 as List<String>;
      return AnonymousStruct.fromBinary(subTypeArr);
    case 'FixedLengthArr':
      var res = typeRes.item2 as Tuple2<int, String>;
      return FixedLengthArr.fromBinary(res.item1, res.item2);
    case 'Template':
      var res = typeRes.item2 as Tuple2<String, List<String>>;
      var baseType = res.item1;
      var subTypes = res.item2;
      var clsMirror = getDecoderClass(baseType);
      return (clsMirror.newInstance('fromBinary', [subTypes]) as ScaleCodecBase);
    case 'CommonType':
      var typeName = typeRes.item2 as String;
      var clsMirror = getDecoderClass(typeName);
      return clsMirror.newInstance('fromBinary', []) as ScaleCodecBase;
    default:
      return null;
  }
}

ScaleCodecBase fromJson(String typeName, dynamic val) {
  var typeRes = processTypeName(typeName);
  switch (typeRes.item1) {
    case 'AnonymousStruct':
      assert(val.runtimeType == List,
        "Incompatibal input type ${val.runtimeType} for anonymous struct");
      var subTypeArr = typeRes.item2 as List<String>;
      return AnonymousStruct.fromJson(subTypeArr, val);
    case 'FixedLengthArr':
      var res = typeRes.item2 as Tuple2<int, String>;
      assert(val.runtimeType == List,
        "Incompatibal input type ${val.runtimeType} for fixed length arr");
      return FixedLengthArr.fromJson(res.item1, res.item2, val as List<dynamic>);
    case 'Template':
      var res = typeRes.item2 as Tuple2<String, List<String>>;
      var baseType = res.item1;
      var subTypes = res.item2;
      var clsMirror = getDecoderClass(baseType);
      return (clsMirror.newInstance('fromJson', [subTypes, val]) as ScaleCodecBase);
    case 'CommonType':
      var typeName = typeRes.item2 as String;
      var clsMirror = getDecoderClass(typeName);
      return clsMirror.newInstance('fromJson', [val]) as ScaleCodecBase;
    default:
      return null;
  }
}

abstract class IntegerBase extends ScaleCodecBase {
  BigInt _val;

  static BigInt convertToBigInt(dynamic s) {
    if(s is String)
      return BigInt.parse(s);
    else if(s is num)
      return BigInt.from(s);
    else if(s is BigInt)
      return s;
    else
      throw Exception("Invalid init type for integer");
  }
  IntegerBase(dynamic s):
    _val = convertToBigInt(s);

  IntegerBase.fromBinary() {
    _val = Uint8ListToBigInt(getReaderInstance().read(byteSize));
  }

  void objToBinary() {
    getWriterInstance().write(BigIntToUint8List(_val, byteSize));
  }

  dynamic toJson() => val;
  String toString() => _val.toString();
  IntegerBase.fromJson(dynamic s):
    _val = convertToBigInt(s);

  /// return a json compatible presentation of current value
  /// 
  /// Return string repr for hudge numbers(byte size > 8) 
  /// Return numeric repr for small numbers(byte size <= 8)
  dynamic get val {
    if(byteSize > 8 || !_val.isValidInt) {
      return _val.toString();
    }
    return _val.toInt();
  }

  set val(dynamic s) {
    _val = convertToBigInt(s);
  }

  int get byteSize;
}

class u8 extends IntegerBase {
  u8(dynamic s): super(s);

  u8.fromBinary():super.fromBinary();
  u8.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 1;
}

class u16 extends IntegerBase {
  u16(dynamic s): super(s);

  u16.fromBinary():super.fromBinary();
  u16.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 2;
}

class u32 extends IntegerBase {
  u32(dynamic s): super(s);

  u32.fromBinary():super.fromBinary();
  u32.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 4;
}

class u64 extends IntegerBase {
  u64(dynamic s): super(s);
  
  u64.fromBinary():super.fromBinary();
  u64.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 8;
}

class u128 extends IntegerBase {
  u128(dynamic s): super(s);

  u128.fromBinary():super.fromBinary();
  u128.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 16;
}

class i8 extends IntegerBase {
  i8(dynamic s): super(s);

  i8.fromBinary(): super.fromBinary();
  i8.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 1;
}

class i16 extends IntegerBase {
  i16(dynamic s): super(s);

  i16.fromBinary(): super.fromBinary();
  i16.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 2;
}

class i32 extends IntegerBase {
  i32(dynamic s): super(s);

  i32.fromBinary(): super.fromBinary();
  i32.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 4;
}

class i64 extends IntegerBase {
  i64(dynamic s): super(s);

  i64.fromBinary(): super.fromBinary();
  i64.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 8;
}

class i128 extends IntegerBase {
  i128(dynamic s): super(s);

  i128.fromBinary(): super.fromBinary();
  i128.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 16;
}

class i256 extends IntegerBase {
  i256(dynamic s): super(s);

  i256.fromBinary(): super.fromBinary();
  i256.fromJson(dynamic s): super.fromJson(s);

  @override
  int get byteSize => 32;
}

class Bytes extends ScaleCodecBase {
  Uint8List val;
  Bytes.fromBinary() {
    var obj = fromBinary('Compact<u32>');
    var length = ((obj as Compact).obj as u32).val;
    val = getReaderInstance().read(length);
  }

  void objToBinary() {
    Compact(u32(val.length)).objToBinary();
    getWriterInstance().write(val);
  }
  dynamic toJson() => hex.encode(val);
  String toString() => toJson();
  Bytes.fromJson(String s): val = hex.decode(s);
}

class Str extends ScaleCodecBase {
  String val;
  Str.fromBinary() {
    var obj = fromBinary('Compact<u32>');
    var length = ((obj as Compact).obj as u32).val;
    val = String.fromCharCodes(getReaderInstance().read(length));
  }

  void objToBinary() {
    Compact(u32(val.length)).objToBinary();
    getWriterInstance().write(Uint8List.fromList(val.codeUnits));
  }

  dynamic toJson() => val;
  String toString() => val;
  Str.fromJson(this.val);
}

abstract class HashBase extends FixedLengthArr {
  HashBase.fromBinary(int byteSize) : super.fromBinary(byteSize, 'u8');
  HashBase.fromJson(int byteSize, String hexStr) : super.fromJson(byteSize, 'u8', hex.decode(strip0x(hexStr)));
  String toString() =>
    hex.encode(List.from(values.map((element) => (element as u8).val)));
  dynamic toJson() => '0x' + toString();
}

class H160 extends HashBase {
  H160.fromBinary() : super.fromBinary(20);
  H160.fromJson(String hexStr) : super.fromJson(20, hexStr);
}

class H256 extends HashBase {
  H256.fromBinary() : super.fromBinary(32);
  H256.fromJson(String hexStr) : super.fromJson(32, hexStr);
}

class H512 extends HashBase { 
  H512.fromBinary() : super.fromBinary(64);
  H512.fromJson(String hexStr) : super.fromJson(64, hexStr);
}

class Bool extends ScaleCodecBase {
  bool val;
  Bool(bool b): val = b;

  Bool.fromBinary() {
    int b = getReaderInstance().read(1)[0];
    switch(b) {
      case 0:
        val = false;
        break;
      case 1:
        val = true;
        break;
      default:
        throw "invalid bool encoding value";
    }
  }
  void objToBinary() {
    getWriterInstance().write(Uint8List.fromList(val? [1] : [0]));
  }
  dynamic toJson() => val;
  String toString() => val.toString();
  Bool.fromJson(this.val);
}

// ================
// Basic structures
// ================
// [type; repeat]
class FixedLengthArr extends ScaleCodecBase {
  List<ScaleCodecBase> values = [];
  FixedLengthArr.fromBinary(int length, String baseType){
    for(var i = 0; i < length; i++) {
      values.add(fromBinary(baseType));
    }
  }

  void objToBinary() {
    values.forEach((v) {
      v.objToBinary();
    });
  }

  FixedLengthArr.fromJson(int length, String baseType, List<dynamic> val) {
    assert(length == val.length,
      "Incompatibal length for fixed length arr, ${length} != ${val.length}");
    val.forEach((i) {
      values.add(fromJson(baseType, i));
    });
  }

  dynamic toJson() => values;
}

// (type1, type2, type3,...)
class AnonymousStruct extends ScaleCodecBase {
  List<ScaleCodecBase> data;
  AnonymousStruct.fromBinary(List<String> subtypes) {
    for(var s in subtypes) {
      data.add(fromBinary(s));
    }
  }
  void objToBinary() {
    data.forEach((d) {
      d.objToBinary();
    });
  }

  AnonymousStruct.fromJson(List<String> subtypes, List<dynamic> val) {
    assert(subtypes.length == val.length,
      "Incompatibal input length for anonymous struct");
    for(var i = 0; i < subtypes.length; i++) {
      data.add(fromJson(subtypes[i], val[i]));
    }
  }
}

abstract class GeneralStruct extends ScaleCodecBase {
  Map<String, ScaleCodecBase> values = {};

  List<Tuple2<String, String>> get params {
    var mirror = scaleTypeReflector.reflect(this);
    return mirror.type.invokeGetter('fields');
  }

  GeneralStruct.fromBinary() {
    for(var f in this.params) {
      // print('${scaleTypeReflector.reflect(this).type.simpleName}::${f.item1}');
      values[f.item1] = fromBinary(f.item2);
      // print(values[f.item1]);
    }
  }

  void objToBinary() {
    for(var f in this.params) {
      values[f.item1].objToBinary();
    }
  }

  dynamic toJson() => values;
  GeneralStruct.fromJson(Map<String, dynamic> s) {
    for(var f in this.params) {
      if(!s.containsKey(f.item1)) {
        var typeName = scaleTypeReflector.reflect(this).type.simpleName;
        throw "Field ${f.item1} not present for ${typeName}";
      }
      values[f.item1] = fromJson(f.item2, s[f.item1]);
    }
  }

  ScaleCodecBase getSymbol(String f) {
    var param = this.params.firstWhere((param) => param.item1 == f);
    return values[param.item1];
  }

  void setSymbol(String f, ScaleCodecBase v) {
    // ensure field name exists
    var param = this.params.firstWhere((param) => param.item1 == f);
    values[param.item1] = v;
  }
}

abstract class GeneralEnum extends ScaleCodecBase {
  int index;
  ScaleCodecBase obj;
  GeneralEnum.fromBinary() {
    index = (fromBinary('u8') as u8).val;
    assert(index < enumTypes.length && index >= 0, 
      "Enum index out of range ${this.runtimeType}:${index}");
    obj = fromBinary(enumTypes[index]);
  }

  void objToBinary() {
    u8(index).objToBinary();
    obj.objToBinary();
  }

  List<String> get enumTypes {
    var mirror = scaleTypeReflector.reflect(this);
    return mirror.type.invokeGetter('types') as List<String>;
  }

  String get enumTypeName => enumTypes[index];

  int indexOfType(String typeName) => enumTypes.indexOf(typeName);

  dynamic toJson() => {'type': enumTypeName, 'val': obj.toJson()};

  GeneralEnum.fromJson(Map<String, dynamic> val){
    index = enumTypes.indexOf(val['type']);
    obj = fromJson(val['type'], val['val']);
  }

  ScaleCodecBase get data => obj;
}

abstract class GeneralTemplate extends ScaleCodecBase {
}

class Compact extends GeneralTemplate {
  ScaleCodecBase obj;
  Compact(this.obj);
  Compact.fromBinary(List<String> templateTypes) {
    assert(templateTypes.length == 1, "Invalid template type for compact");

    var compactByte0 = getReaderInstance().read(1);
    Uint8List compactBytes;
    int compactLength;
    switch (compactByte0[0] & 0x03) {
      case 0:
        compactLength = 1;
        compactBytes = compactByte0;
        break;
      case 1:
        compactLength = 2;
        compactBytes = Uint8List.fromList(compactByte0 + getReaderInstance().read(1));
        break;
      case 2:
        compactLength = 4;
        compactBytes = Uint8List.fromList(compactByte0 + getReaderInstance().read(3));
        break;
      default:
        compactLength = (5 + (compactByte0[0] >> 2)).toInt();
        compactBytes = Uint8List.fromList(getReaderInstance().read(compactLength - 1));
    }

    if(compactLength <= 4) {
      createCompactReaderInstance(Uint8ListShiftRight(compactBytes, 2));
    } else {
      createCompactReaderInstance(compactBytes);
    }

    obj = fromBinary(templateTypes[0]);
    finishCompactReader();
  }

  void objToBinary() {
    createCompactWriterInstance();
    obj.objToBinary();
    var plainData = finishCompactWriter();
    
    var val = Uint8ListToBigInt(plainData); // convert it as unsigned data
    Uint8List encoded = null;
    if(val <= BigInt.from(0x3f)) {// <= 00111111
      encoded = BigIntToUint8List((val << 2), 1);
    } else if(val <= BigInt.from(0x3fff)) {// <= 0011111111111111
      encoded = BigIntToUint8List((val << 2) | BigInt.from(0x01), 2);
    } else if(val <= BigInt.from(0x3fffffff)) {// <= 00111111111111111111111111111111
      encoded = BigIntToUint8List((val << 2) | BigInt.from(0x02), 4);
    } else {
      var byteLength = plainData.lastIndexWhere((element) => element > 0) + 1;
      int encodedByteLength = ((byteLength - 4) << 2) | 0x03;
      encoded = Uint8List.fromList(
        [encodedByteLength] + 
        plainData.sublist(0, byteLength)
      );
    }

    getWriterInstance().write(encoded);
  }

  Compact.fromJson(List<String> templateTypes, dynamic val) {
    assert(templateTypes.length == 1, "Invalid template type for compact");
    obj = fromJson(templateTypes[0], val);
  }

  dynamic toJson() => obj.toJson();  
}

class Vec extends GeneralTemplate {
  List<ScaleCodecBase> objects = [];
  Vec(this.objects);

  Vec.fromBinary(List<String> templateTypes) {
    assert(templateTypes.length == 1, "Invalid template type for vec");
    var obj = fromBinary('Compact<u32>');
    var length = ((obj as Compact).obj as u32).val;
    for(var i = 0; i < length; i++) {
      objects.add(fromBinary(templateTypes[0]));
    }
  }

  void objToBinary() {
    Compact(u32(objects.length)).objToBinary();
    objects.forEach((element) {
      element.objToBinary();
    });
  }

  Vec.fromJson(List<String> templateTypes, List<dynamic> val) {
    assert(templateTypes.length == 1, "Invalid template type for vec");
    assert(val is List, "Invalid value type for Vec");
    val.forEach((i) {
      objects.add(fromJson(templateTypes[0], i));
    });
  }

  dynamic toJson() => objects.map((i) => i.toJson()).toList();
  
  ScaleCodecBase operator[](int idx) => objects[idx];
  void operator[]=(int idx, ScaleCodecBase v) {
    objects[idx] = v;
  }
}

class Option extends GeneralTemplate {
  Bool presents;
  ScaleCodecBase obj;
  Option.fromBinary(List<String> subTypes) {
    assert(subTypes.length == 1, "invalid template type for option");
    presents = fromBinary('Bool');
    if(presents.val) {
      obj = fromBinary(subTypes[0]);
    } else {
      obj = null;
    }
  }

  void objToBinary() {
    presents.objToBinary();
    if(presents.val) {
      obj.objToBinary();
    }
  }
  Option.fromJson(List<String> templateTypes, dynamic val) {
    assert(templateTypes.length == 1, "Invalid template type for option");
    if(val == null) {
      presents = Bool.fromJson(false);
      obj = null;
    } else {
      presents = Bool.fromJson(true);
      obj = fromJson(templateTypes[0], val);
    }
  }

  dynamic toJson() => presents.val ? obj.toJson() : null;
  
  ScaleCodecBase get data => presents.val ? obj : null;
}

class UserDefined extends ScaleCodecBase {

}