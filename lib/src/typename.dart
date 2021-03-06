/// Processes with string of typenames
part of 'types.dart';

/// Defines a set of type name aliases
/// When given a typename as map key, system will actually take the
/// corresponding value as actual type
Map<String, String> _typeDefines = {
  'AccountId': 'H256',
  'GenericAccountId': 'H256',
  'EraIndex': 'u32',
  'PlainType': 'Str',
  'Hash': 'H256',
  'BlakeTwo256': 'H256',
  'Sha256': 'H256',
  'Keccak256': 'H256',
  'ShaThree256': 'H256',
  'Signature': 'H512',
  '<T::Lookup as StaticLookup>::Source': 'Address',
  'Balance': 'u128',
  'Header': 'u128',
  'Moment': 'u64',
  'BalanceOf': 'u128',
  'BalanceOf<T>': 'u128',
  'Call': 'GenericCall',
  "OpaqueTimeSlot": "Bytes",
  "AuthoritySignature": "H512",
  "<AuthorityId as RuntimeAppPublic>::Signature": "H512",
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

  typeName = typeName.replaceFirst('<T as Trait>::', '');

  if(typeName.length == 0) {
    throw Exception("empty typeName not supported");
  }

  typeName = _typeDefines[typeName] ?? typeName;

  // process with anonumous structure
  // (type1, type2, type3...)
  if(typeName.endsWith(')')) {
    if(typeName.length > 2 && typeName[0] == '(' && typeName[typeName.length - 1] == ')') {
      var subTypes = splitSubTypes(typeName.substring(1, typeName.length - 1));
      return Tuple2('AnonymousStruct', subTypes);
    }
    throw Exception("invalid typeName ${typeName}");
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
    throw Exception("invalid typeName ${typeName}");
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
    throw Exception("invalid typeName ${typeName}");
  }

  return Tuple2('CommonType', typeName);
}