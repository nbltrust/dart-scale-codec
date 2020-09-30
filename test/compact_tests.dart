library scalecodec_test.compact_tests;

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'compact_tests.reflectable.dart';


int testDecode(String input) {
  createReaderInstance(input);
  var r = fromBinary('Compact<u32>');
  assert(r is Compact);
  var obj = (r as Compact).obj;
  assert(obj is u32);
  return (obj as u32).val;
}

String testEncode(int val) {
  var c = Compact(u32(val));
  createWriterInstance();
  c.objToBinary();
  return "0x" + hex.encode(getWriterInstance().finalize());
}

void main() {
  initializeReflectable();
  test('test 1 byte decode', () {
    assert(testDecode("0x00") == 0);
    assert(testDecode("0x14") == 5);
    assert(testDecode("0xfc") == 0x3f);
  });

  test('test 2 bytes decode', () {
    assert(testDecode("0x0101") == 0x40);
    assert(testDecode("0x0902") == 130);
    assert(testDecode("0xfdff") == 0x3fff);
  });

  test('test 4 bytes decode', () {
    assert(testDecode("0x02000100") == 0x4000);
    assert(testDecode("0xbe370100") == 0x4def);
    assert(testDecode("0xfeffffff") == 0x3fffffff);
  });

  test('test 1 byte encode', () {
    assert(testEncode(0) == "0x00");
    assert(testEncode(5) == "0x14");
    assert(testEncode(0x3f) == "0xfc");
  });

  test('test 2 bytes encode', () {
    assert(testEncode(0x40) == "0x0101");
    assert(testEncode(130) == "0x0902");
    assert(testEncode(0x3fff) == "0xfdff");
  });

  test('test 4 bytes encode', () {
    assert(testEncode(0x4000) == "0x02000100");
    assert(testEncode(0x4def) == "0xbe370100");
    assert(testEncode(0x3fffffff) == "0xfeffffff");
  });
}