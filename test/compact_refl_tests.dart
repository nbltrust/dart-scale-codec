library scalecodec_test.compact_tests;

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'compact_refl_tests.reflectable.dart';

dynamic decode(String type, String input) {
  createReaderInstance(input);
  var r = fromBinary('Compact<${type}>');
  expect(r is Compact, true);
  var obj = (r as Compact).obj;
  return obj;
}

String encode(dynamic val) {
  var c = Compact(val);
  createWriterInstance();
  c.objToBinary();
  return "0x" + hex.encode(getWriterInstance().finalize());
}

void main() {
  initializeReflectable();
  test('test u8 decode', () {
    expect(decode('u8', '0x00').val, 0);
  });

  test('test u32 decode', () {
    expect(decode('u32', "0x00").val, 0);
    expect(decode('u32', "0x14").val, 5);
    expect(decode('u32', "0x18").val, 6);
    expect(decode('u32', "0xfc").val, 0x3f);

    expect(decode('u32', "0x0101").val, 0x40);
    expect(decode('u32', "0x0902").val, 130);
    expect(decode('u32', "0xfdff").val, 0x3fff);
    
    expect(decode('u32', "0x02000100").val, 0x4000);
    expect(decode('u32', "0xbe370100").val, 0x4def);
    expect(decode('u32', "0xfeffffff").val, 0x3fffffff);

    expect(decode('u32', "0x02093d00").val, 1000000);
  });

  test('test u32 encode', () {
    expect(encode(u32(0)), "0x00");
    expect(encode(u32(5)), "0x14");
    expect(encode(u32(6)), "0x18");
    expect(encode(u32(0x3f)), "0xfc");
  
    expect(encode(u32(0x40)), "0x0101");
    expect(encode(u32(130)), "0x0902");
    expect(encode(u32(0x3fff)), "0xfdff");
    
    expect(encode(u32(0x4000)), "0x02000100");
    expect(encode(u32(0x4def)), "0xbe370100");
    expect(encode(u32(1000000)), '0x02093d00');
    expect(encode(u32(0x3fffffff)), "0xfeffffff");
  });

  test('test compact balance', () {
    var b = decode('Balance', '0x130080cd103d71bc22');
    expect(b.val, '2503000000000000000');
  
    expect(encode(u128('2503000000000000000')), '0x130080cd103d71bc22');
  });

  test('test compact bool', () {
    var b_true = decode('Bool', '0x04');
    expect(b_true.val, true);

    expect(encode(Bool(true)), '0x04');

    var b_false = decode('Bool', '0x00');
    expect(b_false.val, false);

    expect(encode(Bool(false)), '0x00');
  });
}