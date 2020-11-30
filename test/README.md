# Test Guide

This directory includes test cases for dart scalecodec library.

## Environment setup
Before running test cases, users need to fetch metadata from remote blockchain node. Use tool `./tool/dump_metadata.dart` to fetch metadata and dump it in local filesystem.
```bash
cd tool
dart dump_metadata.dart # will generate a metadata file suffixed with current timestamp
ln -s metadata.$timestamp.bin ../test/metadata.bin # setup a soft link from metadata binary file to test dir
```

and install all test dependencies
```bash
cd ./test
pub get
```

and build reflect files for test cases
```bash
cd ./ # in root directory of project
pub run build_runner build ./
```

## Run all test cases
```dart
cd ./test
pub run test .
```