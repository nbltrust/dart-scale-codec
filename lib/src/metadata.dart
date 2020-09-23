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
    "Vec<MetadataV8Module>"
  ];
}

class MetadataV7ModuleStorageFunctionType extends GeneralEnum {
  static const List<String> types = [
    "PlainType",
    "MapType",
    "DoubleMapType"
  ];
}

class MetadataV7ModuleStorageEntry extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('modifier', 'Int8'),
    Tuple2('function_type', 'MetadataV7ModuleStorageFunctionType'),
    Tuple2('fallback', 'Bytes'),
    Tuple2('docs', 'Vec<Str>')
  ];
}

class MetadataV7ModuleStorage extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('prefix', 'Str'),
    Tuple2('items', 'Vec<MetadataV7ModuleStorageEntry>')
  ];
}

class MetadataModuleCallArgument extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('type', 'Str')
  ];
}

class MetadataModuleCall extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('args', 'Vec<MetadataModuleCallArgument>'),
    Tuple2('docs', 'Vec<Str>')
  ];
}

class MetadataModuleEvent extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('args', 'Vec<Str>'),
    Tuple2('docs', 'Vec<Str>')
  ];
}

class MetadataV7ModuleConstants extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('type', 'Str'),
    Tuple2('constant_value', 'Bytes'),
    Tuple2('docs', 'Vec<Str>')
  ];
}

class MetadataModuleError extends GeneralStruct {
  static const List<Tuple2<String, String>> fields = [
    Tuple2('name', 'Str'),
    Tuple2('docs', 'Vec<Str>')
  ];
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
}