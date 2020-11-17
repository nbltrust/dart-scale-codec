# dart-scale-codec
scalecodec library for substrate based blockchains in native dart

# This library does NOT
* hash and digest serialized data
* fetch/send any data from/to blockchain
* sign extrinsics

# Environment setup
Since scalecodec depends on reflectable package, users need to first build a reflectable file of the main entrypoint.

Usage of reflectable can be found in [reflectable homepage](https://pub.dev/packages/reflectable)

Setup these sections in your build.yaml file
```yaml
targets:
  $default:
    builders:
      reflectable:
        generate_for:
          - src/your-entry-point.dart

```
After that, run build command to generate reflectable file

```bash
pub run build_runner build ./
```

And setup reflectable code in your main entrypoint
```dart
...
import 'your-entry-point.reflectable.dart'
...

void main() {
    initializeReflectable();
    ...
}
```

# Usage
## Global reader and writer instance
Global reader/writer instance is used to store on-way binary data when converting from/to binary. They are singleton instances, initialized by caller, used by library and finished by caller.

* Global reader instance usage
```dart
createReaderInstance('hex string input');
// calling fromBinary will pop binary data from global reader and contruct structured data
```

* Global writer instance usage
```dart
createWriterInstance();
object.objToBinary();
// return Uint8List
// calling finalize will return all encoded data
var encoded = getWriterInstance().finalize();
```

## Initialize global metadata
Demo file at example/metadata_demo.dart

Current supported metadata version includes v11 and v12.
```dart
createReaderInstance(metaHex);
var magic = String.fromCharCodes(getReaderInstance().read(4));
if(magic != 'meta') {
    throw Exception("Invalid metadata");
}

// decode metadata binary to metadata object
var metadata = fromBinary('MetadataEnum');

// dumps metadata as json
print(jsonEncode(metadata));

// or you can cache metadata json and initialize metadata from json
// var metadata = MetadataEnum.fromJson(jsonDecode(jsonEncode(metadata)));

// set global runtime metadata
RuntimeConfigration().registMetadata(metadata);
```

## Supported typenames
* Numeric: u8, u16, u32, u64, u128, u256, i8, i16, i32, i64, i128, i256
* Hash: H160, H256, H512
* Basic types: Str, Bytes, Bool
* Fixed length array: [typename, repeatCount]
* Dynamic array: Vec<typename>
* Compact: Compact<typename>
* Optional: Option<typename>
* Tuples: (typename1, typename2, ...)
* Complex types: Address, Era, StorageHasher, Extrinsics, ExtrinsicsPayloadValue, GenericCall, MetadataEnum

## Convert from json to object
```dart
var obj = fromJson('typename', json);
```

## Convert from binary to object
```dart
createReaderInstance(hexStr);
var obj = fromBinary('typename');
```

## Convert from object to json
```dart
var jsonStr = jsonEncode(obj);
```

## Convert from object to binary
```dart
createWriterInstance();
obj.objToBinary();
// returns Uint8List
var bytes = getWriterInstance().finalize();
```