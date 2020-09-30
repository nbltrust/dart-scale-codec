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
  assert(mirror != null, "Class ${class_name} not found in reflection system");
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

// =============================================================
// Numeric conversion functions deal with little endian integers
// =============================================================
int Uint8ListToint(Uint8List l) {
  int res = 0;
  int shift = 0;
  l.forEach((v) {
    res += (v << shift);
    shift += 8;
  });
  return res;
}

BigInt Uint8ListToBigInt(Uint8List l) {
  BigInt res = BigInt.zero;
  int shift = 0;
  l.forEach((v) {
    res += BigInt.from(v << shift);
    shift += 8;
  });
  return res;
}

Uint8List intToUint8List(int v, int byteLength) {
  var res = Uint8List(byteLength);
  for(var i = 0; i < byteLength; i++) {
    res[i] = v >> (8 * i);
  }
  return res;
}

Uint8List BigIntToUint8List(BigInt v, int byteLength) {
  var res = Uint8List(byteLength);
  for(var i = 0; i < byteLength; i++) {
    res[i] = (v >> (8 * i)).toInt();
  }
  return res;
}

// ===========
// Basic types
// ===========
class u8 extends ScaleCodecBase {
  int val;
  u8(this.val);
  u8.fromBinary() {
    val = getReaderInstance().read(1)[0];
  }
  void objToBinary() {
    getWriterInstance().write(intToUint8List(val, 1));
  }
  dynamic toJson() => val;
  u8.fromJson(this.val);
}

class u16 extends ScaleCodecBase {
  int val;
  u16(this.val);
  u16.fromBinary() {
    val = Uint8ListToint(getReaderInstance().read(2));
  }

  void objToBinary() {
    getWriterInstance().write(intToUint8List(val, 2));
  }

  dynamic toJson() => val;
  String toString() => val.toString();
  u16.fromJson(this.val);
}

class u32 extends ScaleCodecBase {
  int val;
  u32(this.val);
  u32.fromBinary() {
    val = Uint8ListToint(getReaderInstance().read(4));
  }

  void objToBinary() {
    getWriterInstance().write(intToUint8List(val, 4));
  }
  dynamic toJson() => val;
  String toString() => val.toString();
  u32.fromJson(this.val);
}

class u128 extends ScaleCodecBase {
  BigInt val;
  u128(this.val);

  u128.fromBinary() {
    val = Uint8ListToBigInt(getReaderInstance().read(16, false));
  }

  void objToBinary() {
    getWriterInstance().write(BigIntToUint8List(val, 16));
  }

  dynamic toJson() => val.toString();
  u128.fromJson(String s): val = BigInt.parse(s);

  String toString() => val.toString();
}

class Int8 extends ScaleCodecBase {
  int val;
  Int8(this.val);
  Int8.fromBinary() {
    val = getReaderInstance().read(1)[0];
  }
  Int8.fromJson(this.val);

  void objToBinary() {
    getWriterInstance().write(intToUint8List(val, 1));
  }
  dynamic toJson() => val;
  String toString() => val.toString();  
}

class Int32 extends ScaleCodecBase {
  int val;
  Int32(this.val);
  Int32.fromBinary() {
    val = Uint8ListToint(getReaderInstance().read(4));
  }

  void objToBinary() {
    getWriterInstance().write(intToUint8List(val, 4));
  }

  dynamic toJson() => val;
  String toString() => val.toString();
  Int32.fromJson(this.val);
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

class H256 extends FixedLengthArr {
  H256.fromBinary() : super.fromBinary(32, 'u8');
  H256.fromJson(String hexStr) : super.fromJson(32, 'u8', hex.decode(hexStr));
  dynamic toJson() {
    List<int> bytes = [];
    values.forEach((element) {bytes.add((element as u8).val);});
    return hex.encode(bytes);
  }
}

class Bool extends ScaleCodecBase {
  bool val;
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
    index = (fromBinary('Int8') as Int8).val;
    assert(index < enumTypes.length && index >= 0, 
      "Enum index out of range ${this.runtimeType}:${index}");
    obj = fromBinary(enumTypes[index]);
  }

  void objToBinary() {
    Int8(index).objToBinary();
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

    // createCompactReaderInstance(compactBytes);
    var templateName = templateTypes[0];
    switch (templateName) {
      case 'u32':
        int val = 0;
        if(compactLength <= 4) {
          val = Uint8ListToint(compactBytes) >> 2;
        } else {
          val = Uint8ListToint(compactBytes);
        }
        obj = u32(val);
        break;
      case 'u128':
        BigInt val;
        val = Uint8ListToBigInt(compactBytes);
        obj = u128(val);
        break;
      default:
        createCompactReaderInstance(compactBytes);
        obj = fromBinary(templateTypes[0]);
        finishCompactReader();
    }
  }

  void objToBinary() {
    createCompactWriterInstance();
    obj.objToBinary();
    var plainData = finishCompactWriter();
    var idx = plainData.lastIndexWhere((element) => element > 0);
    if(idx <= 3) {
      int val = Uint8ListToint(plainData);
      Uint8List encoded = null;
      if(val <= 0x3f) {// <= 00111111
        encoded = intToUint8List((val << 2), 1);
      } else if(val <= 0x3fff) {// <= 0011111111111111
        encoded = intToUint8List((val << 2) | 0x01, 2);
      } else if(val <= 0x3fffffff) {// <= 00111111111111111111111111111111
        encoded = intToUint8List((val << 2) | 0x02, 4);
      }

      if(encoded != null) {
        getWriterInstance().write(encoded);
        return;
      }
    }
    
    int byteLength = idx + 1;
    int encodedByteLength = ((byteLength - 4) << 2) | 0x03;
    var encoded = Uint8List.fromList(
      [encodedByteLength] + 
      plainData.sublist(0, byteLength)
    );
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