part of 'types.dart';

/// Generic call encodes call params into call bytes, prefixed with encoded module
/// index and function index
/// 
/// Should init metadata in [RuntimeConfigration] before calling constructor.
class GenericCall extends GeneralStruct {
  Map<String, ScaleCodecBase> argValues = {};

  static const List<Tuple2<String, String>> fields = [
    Tuple2('module_index', 'u8'),
    Tuple2('function_index', 'u8'),
  ];

  int get module_index => (values['module_index'] as u8).val;
  int get function_index => (values['function_index'] as u8).val;

  static bool get isV12orLater {
    return RuntimeConfigration().isV12OrLater;
  }
  
  static dynamic get runtimeMetadata => RuntimeConfigration().runtimeMetadata.obj;
  static List<dynamic> get metadataModules => runtimeMetadata.modules.objects;

  dynamic get module {
    if(isV12orLater) {
      return metadataModules.firstWhere((i) => i.index.val == module_index);
    } else {
      return metadataModules[module_index];
    }
  }


  Str get function_name {
    if(!module.calls.presents.val) {
      throw Exception('No calls in module');
    }
    return module.calls.obj[function_index].name;
  }

  List<MetadataModuleCallArgument> get callArgs {
    List<MetadataModuleCallArgument> ret = [];
    var function = module.calls.obj[function_index];
    for(var arg in function.args.objects) {
      ret.add(arg);
    }
    return ret;
  }

  GenericCall.fromBinary(): super.fromBinary() {
    for(dynamic arg in callArgs) {
      argValues[arg.name.val] = fromBinary(arg.type.val);
    }
  }

  void objToBinary() {
    super.objToBinary();
    for(dynamic arg in callArgs) {
      argValues[arg.name.val].objToBinary();
    }
  }

  Map<String, dynamic> toJson() => {
    'module': module.name,
    'function': function_name,
    'args': argValues
  };

  static Map<String, dynamic> extractIndex(Map<String, dynamic> json) {
    var module_name = json['module'];
    var function_name = json['function'];
    var onModuleNotFound = () { throw Exception("Module ${module_name} not found");};
    var onFunctionNotFound = () {throw Exception("Function ${function_name} not found");};
    var module_index = isV12orLater ?
        metadataModules.firstWhere((m) => m.name.val == module_name, orElse: onModuleNotFound).index.val:
        metadataModules.indexWhere((m) => m.name.val == module_name);

    if(module_index == -1) {
      onModuleNotFound();
    }

    var module = isV12orLater?
      metadataModules.firstWhere((m) => m.index.val == module_index):
      metadataModules[module_index];

    if(!module.calls.presents.val) {
      onFunctionNotFound();
    }

    var function_index = module.calls.obj.objects.indexWhere((f) => f.name.val == function_name);
    if(function_index == -1) {
      onFunctionNotFound();
    }
    return {
      "module_index": module_index,
      "function_index": function_index
    };
  }

  GenericCall.fromJson(Map<String, dynamic> json) : super.fromJson(extractIndex(json)) {
    var args = json['args'];
    for(dynamic arg in callArgs) {
      argValues[arg.name.val] = fromJson(arg.type.val, args[arg.name.val]);
    }
  }
}

class ExtrinsicsPayloadValue extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('call', 'GenericCall'),
    Tuple2('era', 'Era'),
    Tuple2('nonce', 'Compact<u32>'),
    Tuple2('tip', 'Compact<Balance>'),
    Tuple2('spec_version', 'u32'),
    Tuple2('transaction_version', 'u32'),
    Tuple2('genesis_hash', 'Hash'),
    Tuple2('block_hash', 'Hash')
  ];


  ExtrinsicsPayloadValue.fromBinary(): super.fromBinary();
  ExtrinsicsPayloadValue.fromJson(Map<String, dynamic> s): super.fromJson(s);
}

class Extrinsics extends ScaleCodecBase {
  u8 versionInfo;
  bool containsTransaction;
  Address accountId;
  u8 signatureVersion;
  H512 signature;
  Era era;
  Compact nonce;
  Compact tip;
  GenericCall call;
  
  factory Extrinsics.fromJson(Map<String, dynamic> json) {
    if(json.containsKey('accountId')) {
      // contains transaction
        return Extrinsics(
          GenericCall.fromJson(json['call']),
          u8.fromJson(json['versionInfo']),
          true,
          Address.fromJson(json['accountId']),
          u8.fromJson(json['signatureVersion']),
          H512.fromJson(json['signature']),
          Era.fromJson(json['era']),
          Compact.fromJson(['u64'], json['nonce']),
          Compact.fromJson(['Balance'], json['tip'])
        );
    } else {
      return Extrinsics(
        GenericCall.fromJson(json['call']),
        u8.fromJson(json['versionInfo']),
        false);
    }
  }

  Extrinsics(this.call, this.versionInfo, this.containsTransaction, [
    this.accountId,
    this.signatureVersion,
    this.signature,
    this.era,
    this.nonce,
    this.tip,
  ]);

  void objToBinary() {
    var writer = getWriterInstance();
    if(containsTransaction) {
      writer.write(Uint8List.fromList([0x84]));
      accountId.objToBinary();
      signatureVersion.objToBinary();
      signature.objToBinary();
      era.objToBinary();
      nonce.objToBinary();
      tip.objToBinary();
    } else {
      writer.write(Uint8List.fromList([0x04]));
    }
    call.objToBinary();
  }
}