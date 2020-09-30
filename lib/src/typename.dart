/// Processes with string of typenames
part of 'types.dart';

/// Defines a set of type name aliases
/// When given a typename as map key, system will actually take the
/// corresponding value as actual type
Map<String, String> _typeDefines = {
  'PlainType': 'Str',
  'Hash': 'H256',
  '<T::Lookup as StaticLookup>::Source': 'Address',
  'Balance': 'u128'
};

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

/// Analyze typeName and return a tuple of<category, dynamic>
/// 
Tuple2<String, dynamic> processTypeName(String typeName) {
  RegExp reg;
  RegExpMatch match;

  if(typeName.startsWith('T::')) {
    typeName = typeName.substring(3);
  }

  if(typeName.length == 0) {
    throw "empty typeName not supported";
  }

  typeName = _typeDefines[typeName] ?? typeName;

  // process with anonumous structure
  // (type1, type2, type3...)
  if(typeName.endsWith(')')) {
    if(typeName.length > 2 && typeName[0] == '(' && typeName[typeName.length - 1] == ')') {
      var subTypes = splitSubTypes(typeName.substring(1, typeName.length - 1));
      return Tuple2('AnonymousStruct', subTypes);
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
      return Tuple2('FixedLengthArr', Tuple2(length, baseType));
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
      return Tuple2('Template', Tuple2(baseType, subTypes));
    }
    throw "invalid typeName ${typeName}";
  }

  return Tuple2('CommonType', typeName);
}