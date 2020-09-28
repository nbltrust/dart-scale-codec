/// Runtime metadata
/// Reference:
/// https://substrate.dev/rustdocs/v2.0.0-rc6/frame_metadata/

part of 'types.dart';

class MetadataEnum extends GeneralEnum {
  static const List<String> types = [
    "MetadataV0", // not implemented
    "MetadataV1", // not implemented
    "MetadataV2", // not implemented
    "MetadataV3", // not implemented
    "MetadataV4", // not implemented
    "MetadataV5", // not implemented
    "MetadataV6", // not implemented
    "MetadataV7", // not implemented
    "MetadataV8", // not implemented
    "MetadataV9", // not implemented
    "MetadataV10", // not implemented
    "MetadataV11"
  ];
  MetadataEnum.fromBinary(): super.fromBinary();
  MetadataEnum.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataV7ModuleStorageFunctionType extends GeneralEnum {
  static const List<String> types = [
    "PlainType",
    "MapType",
    "DoubleMapType"
  ];
  MetadataV7ModuleStorageFunctionType.fromBinary(): super.fromBinary();
  MetadataV7ModuleStorageFunctionType.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataV7ModuleStorageEntry extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('modifier', 'Int8'),
    Tuple2('function_type', 'MetadataV7ModuleStorageFunctionType'),
    Tuple2('fallback', 'Bytes'),
    Tuple2('docs', 'Vec<Str>')
  ];

  MetadataV7ModuleStorageEntry.fromBinary(): super.fromBinary();
  MetadataV7ModuleStorageEntry.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataV7ModuleStorage extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('prefix', 'Str'),
    Tuple2('items', 'Vec<MetadataV7ModuleStorageEntry>')
  ];
  MetadataV7ModuleStorage.fromBinary(): super.fromBinary();
  MetadataV7ModuleStorage.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataModuleCallArgument extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('type', 'Str')
  ];
  MetadataModuleCallArgument.fromBinary(): super.fromBinary();
  MetadataModuleCallArgument.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataModuleCall extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('args', 'Vec<MetadataModuleCallArgument>'),
    Tuple2('docs', 'Vec<Str>')
  ];
  MetadataModuleCall.fromBinary(): super.fromBinary();
  MetadataModuleCall.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataModuleEvent extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('args', 'Vec<Str>'),
    Tuple2('docs', 'Vec<Str>')
  ];
  MetadataModuleEvent.fromBinary(): super.fromBinary();
  MetadataModuleEvent.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataV7ModuleConstants extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('type', 'Str'),
    Tuple2('constant_value', 'Bytes'),
    Tuple2('docs', 'Vec<Str>')
  ];
  MetadataV7ModuleConstants.fromBinary(): super.fromBinary();
  MetadataV7ModuleConstants.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataModuleError extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('docs', 'Vec<Str>')
  ];
  MetadataModuleError.fromBinary(): super.fromBinary();
  MetadataModuleError.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataV8Module extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('storage', 'Option<MetadataV7ModuleStorage>'),
    Tuple2('calls', 'Option<Vec<MetadataModuleCall>>'),
    Tuple2('events', 'Option<Vec<MetadataModuleEvent>>'),
    Tuple2('constants', 'Vec<MetadataV7ModuleConstants>'),
    Tuple2('errors', 'Vec<MetadataModuleError>')
  ];
  MetadataV8Module.fromBinary(): super.fromBinary();
  MetadataV8Module.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class ExtrinsicMetadata extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('version', 'Int8'),
    Tuple2('signed_extensions', 'Vec<Str>')
  ];
  ExtrinsicMetadata.fromBinary(): super.fromBinary();
  ExtrinsicMetadata.fromJson(Map<String, dynamic> s):super.fromJson(s);
}

class MetadataV11 extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('modules', 'Vec<MetadataV8Module>'),
    Tuple2('extrnsic', 'ExtrinsicMetadata')
  ];
  MetadataV11.fromBinary(): super.fromBinary();
  MetadataV11.fromJson(Map<String, dynamic> s):super.fromJson(s);
}