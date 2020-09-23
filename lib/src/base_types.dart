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
/// to gain same capabilities of BaseType
@scaleTypeReflector
abstract class BaseType {}

ClassMirror getDecoderClass(String class_name) {
  var libraryMirror = scaleTypeReflector.findLibrary('scalecodec.types');
  return libraryMirror.declarations[class_name];
}

/// Split string of subtype definition into list of subtypes
List<String> splitSubTypes(String subTypeContents) {
  List<String> subTypes = [];
  List<String> stack = [];
  int current_start = 0;
  for(var i = 0; i < subTypeContents.length; i++) {
    var c = subTypeContents[i];
    switch (c) {
      case '<':
        stack.add(c);
        break;
      case '>':
        stack.removeLast();
        break;
      case ',':
        if(stack.isEmpty) {
          subTypes.add(subTypeContents.substring(current_start, i).trim());
          current_start = i + 1;
        }
        break;
      default:
    }
  }
  subTypes.add(subTypeContents.substring(current_start, subTypeContents.length));
  return subTypes;
}

/// Build an object of [typeName] from universal BufferedReader
/// 
/// ```dart
/// createReaderInstance(hex_str);
/// var obj = fromBinary('Option<Vec<MapType>>');
/// for(var i in (obj as Option) as Vec) {
///   print((i as MapType).key);
/// }
/// ```
BaseType fromBinary(String typeName) {
  RegExp reg;
  RegExpMatch match;

  if(typeName.length == 0) {
    throw "empty typeName not supported";
  }

  // process with anonumous structure
  // (type1, type2, type3...)
  if(typeName.endsWith(')')) {
    if(typeName.length > 2 && typeName[0] == '(' && typeName[typeName.length - 1] == ')') {
      var subTypes = splitSubTypes(typeName.substring(1, typeName.length - 1));
      return AnonymousStruct(subTypes);
    }
    throw "invalid typeName ${typeName}";
  }

  // process with fixed length array
  // [typename; repeat-count]
  if(typeName.endsWith(']')) {
    reg = RegExp(r"^\[([A-Za-z0-9]+); ([0-9]+)\]$");
    match = reg.firstMatch(typeName);
    if(match != null) {
      var baseType = match.group(1);
      var length = int.parse(match.group(2));
      return FixedLengthArr(length, baseType);
    }
    throw "invalid typeName ${typeName}";
  }

  // process with general type
  // typename<subtype>
  if(typeName.endsWith('>')) {
    reg = RegExp(r"^([^<]*)<(.+)>$");
    match = reg.firstMatch(typeName);
    if(match != null) {
      var baseType = match.group(1);
      var subTypes = splitSubTypes(match.group(2));
      var clsMirror = getDecoderClass(baseType);
      // print("${baseType}, ${clsMirror}, ${subTypes}");
      var instance = (clsMirror.newInstance('', [subTypes]) as BaseType);
      return instance;
    }
    throw "invalid typeName ${typeName}";
  }

  var clsMirror = getDecoderClass(typeName);
  if(clsMirror == null) {
    throw "can not find decoder for ${typeName}";
  }
  return clsMirror.newInstance('', []) as BaseType;
}

class u32 extends BaseType {
  int val;
  u32() {
    val = int.parse(hex.encode(getReaderInstance().read(4)), radix: 16);
  }
  u32.fromData(this.val);
}

class Int8 extends BaseType {
  int val;
  Int8() {
    val = getReaderInstance().read(1)[0];
  }
}

class Int32 extends BaseType {
  int val;
  Int32() {
    val = int.parse(hex.encode(getReaderInstance().read(4)), radix: 16);
  }
}

class Bytes extends BaseType {
  Uint8List val;
  Bytes() {
    var obj = fromBinary('Compact<u32>');
    var length = ((obj as Compact).obj as u32).val;
    val = getReaderInstance().read(length);
  }
}

class Str extends BaseType {
  String val;
  Str() {
    var obj = fromBinary('Compact<u32>');
    var length = ((obj as Compact).obj as u32).val;
    val = String.fromCharCodes(getReaderInstance().read(length));
  }
}

class Bool extends BaseType {
  bool val;
  Bool() {
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
}

abstract class GeneralStruct extends BaseType {
  Map<String, dynamic> values = {};
  GeneralStruct() {
    var mirror = scaleTypeReflector.reflect(this);
    var fields = mirror.type.invokeGetter('fields');
    for(var f in fields) {
      // print('${mirror.type.simpleName}::${f.item1}');
      values[f.item1] = fromBinary(f.item2);
      // if(f.item1 == 'name') {
      //   print((values['name'] as Str).val);
      // }
    }
  }
}

abstract class GeneralEnum extends BaseType {
  int index;
  BaseType obj;
  GeneralEnum() {
    index = (fromBinary('Int8') as Int8).val;
    var mirror = scaleTypeReflector.reflect(this);
    var types = mirror.type.invokeGetter('types') as List<String>;
    if(this.index >= types.length) {
      throw "enum index out of range ${mirror.type.simpleName}:${index}";
    }
    obj = fromBinary(types[this.index]);
  }
}

abstract class GeneralTemplate extends BaseType {
}

class Compact extends GeneralTemplate {
  BaseType obj;
  Compact(List<String> templateTypes) {
    if(templateTypes.length != 1) {
      throw "invalid template type for compact";
    }

    var compactByte0 = getReaderInstance().read(1);
    Uint8List compactBytes;
    int compactLength;
    switch (compactByte0[0] % 4) {
      case 0:
        compactLength = 1;
        compactBytes = compactByte0;
        break;
      case 1:
        compactLength = 2;
        compactBytes = Uint8List.fromList((compactByte0 + getReaderInstance().read(1)).reversed.toList());
        break;
      case 2:
        compactLength = 4;
        compactBytes = Uint8List.fromList((compactByte0 + getReaderInstance().read(3)).reversed.toList());
        break;
      default:
        compactLength = (5 + (compactByte0[0] - 3) / 4).toInt();
        compactBytes = Uint8List.fromList(getReaderInstance().read(compactLength).reversed.toList());
    }

    // createCompactReaderInstance(compactBytes);
    if(templateTypes[0] == 'u32') {
      int val = 0;
      if(compactLength <= 4) {
        val = int.parse(hex.encode(compactBytes), radix: 16) >> 2;
      } else {
        val = int.parse(hex.encode(compactBytes), radix: 16);
      }
      obj = u32.fromData(val);
    } else {
      obj = fromBinary(templateTypes[0]);
      if(obj.runtimeType == u32) {
        (obj as u32).val >>= 2;
      }
    }
  }
}

class Vec extends GeneralTemplate {
  List<BaseType> objects = [];
  Vec(List<String> templateTypes) {
    if(templateTypes.length != 1) {
      throw "invalid template type for vec";
    }
    var obj = fromBinary('Compact<u32>');
    var length = ((obj as Compact).obj as u32).val;
    for(var i = 0; i < length; i++) {
      objects.add(fromBinary(templateTypes[0]));
    }
  }
}

class Option extends GeneralTemplate {
  Bool presents;
  BaseType obj;
  Option(List<String> subTypes) {
    if(subTypes.length != 1) {
      throw "invalid template type for option";
    }
    presents = fromBinary('Bool');
    if(presents.val) {
      obj = fromBinary(subTypes[0]);
    } else {
      obj = null;
    }
  }
}