part of 'types.dart';

/// Generic call encodes call params into call bytes, prefixed with encoded module
/// index and function index
/// 
/// Should init metadata in [RuntimeConfigration] before calling constructor.
class GenericCall extends GeneralStruct {
  List<MetadataModuleCallArgument> callArgs = [];
  Map<String, ScaleCodecBase> argValues = {};

  static const List<Tuple2<String, String>> fields = [
    Tuple2('module_index', 'u8'),
    Tuple2('function_index', 'u8'),
  ];

  GenericCall.fromBinary(): super.fromBinary(){
    dynamic meta = RuntimeConfigration().runtimeMetadata;
    var function = meta.obj.modules[module_index].calls.obj[function_index];
    for(var arg in function.args.objects) {
      callArgs.add(arg);
    }

    for(dynamic arg in callArgs) {
      argValues[arg.name.val] = fromBinary(arg.type.val);
    }
    print(argValues);
  }

  int get module_index => (values['module_index'] as u8).val;
  int get function_index => (values['function_index'] as u8).val;

  GenericCall.fromJson(Map<String, dynamic> s): super.fromJson(s);
}

class Extrinsics extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('call', 'GenericCall'),
    Tuple2('era', 'Era'),
    Tuple2('nonce', 'Compact<Index>'),
    Tuple2('tip', 'Compact<Balance>'),
    Tuple2('spec_version', 'u32'),
    Tuple2('transaction_version', 'u32'),
    Tuple2('genesis_hash', 'Hash'),
    Tuple2('block_hash', 'Hash')
  ];

  Extrinsics.fromBinary(): super.fromBinary();
  Extrinsics.fromJson(Map<String, dynamic> s): super.fromJson(s);
}