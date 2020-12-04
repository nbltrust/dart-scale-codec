library scalecodec_test.base_types_refl_test;

import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'base_types_refl_test.reflectable.dart';

String encode(ScaleCodecBase val) {
  createWriterInstance();
  val.objToBinary();
  return "0x" + hex.encode(getWriterInstance().finalize());
}

ScaleCodecBase decode(String hexInput, String type) {
  createReaderInstance(hexInput);
  return fromBinary(type);
}

void main() {
  initializeReflectable();

  test('test encode Bool', () {
    expect(encode(Bool(true)), '0x01');
    expect(encode(Bool(false)), '0x00');
  });

  test('test decode Bool', () {
    Bool b = decode('0x00', 'Bool');
    expect(b.val, false);
    Bool b2 = decode('0x01', 'Bool');
    expect(b2.val, true);
  });

  test('test encode u8', () {
    expect(encode(u8(0)), '0x00');
    expect(encode(u8(1)), '0x01');
    expect(encode(u8(100)), '0x64');
    expect(encode(u8(255)), '0xff');
  });

  test('test encode u8 overflow', () {
    expect(() => encode(u8(256)), throwsException);
    expect(() => encode(u8(-1)), throwsException);
  });

  test('test decode u8', () {
    var u8_decode = (String hexInput, u8 expectVal) {
      var v = decode(hexInput, 'u8');
      expect(v.runtimeType, u8);
      expect((v as u8).val, expectVal.val);
    };

    u8_decode('00', u8(0));
    u8_decode('01', u8(1));
    u8_decode('64', u8.fromJson(100));
    u8_decode('ff', u8(255));
  });

  test('test encode i8', () {
    expect(encode(i8(0)), '0x00');
    expect(encode(i8(127)), '0x7f');
    expect(encode(i8(-128)), '0x80');
  });

  test('test encode i8 overflow', () {
    expect(() => encode(i8(128)), throwsException);
    expect(() => encode(i8(-129)), throwsException);
  });

  test('test decode i8', () {
    var i8_decode = (String hexInput, i8 expectVal) {
      var v = decode(hexInput, 'i8');
      expect(v.runtimeType, i8);
      expect((v as i8).val, expectVal.val);
    };

    i8_decode('00', i8(0));
    i8_decode('01', i8(1));
    i8_decode('64', i8(100));
    i8_decode('ff', i8.fromJson(-1));
    i8_decode('80', i8(-128));
  });

  test('test encode u16', () {
    expect(encode(u16(0)), '0x0000');
    expect(encode(u16(100)), '0x6400');
    expect(encode(u16(256)), '0x0001');
    expect(encode(u16(65535)), '0xffff');
  });

  test('test encode u16 overflow', () {
    expect(() => encode(u16(65536)), throwsException);
    expect(() => encode(u16(-1)), throwsException);
  });

  test('test decode u16', () {
    var u16_decode = (String hexInput, u16 expectVal) {
      var v = decode(hexInput, 'u16');
      expect(v.runtimeType, u16);
      expect((v as u16).val, expectVal.val);
    };

    u16_decode('0000', u16(0));
    u16_decode('6400', u16(100));
    u16_decode('e803', u16(1000));
    u16_decode('ffff', u16.fromJson(65535));
  });
  
  test('test encode i16', () {
    expect(encode(i16(0)), '0x0000');
    expect(encode(i16(100)), '0x6400');
    expect(encode(i16(127)), '0x7f00');
    expect(encode(i16(32767)), '0xff7f');
    expect(encode(i16(-1)), '0xffff');
    expect(encode(i16(-128)), '0x80ff');
    expect(encode(i16(-32768)), '0x0080');
  });
  
  test('test encode i16 overflow', () {
    expect(() => encode(i16(32768)), throwsException);
    expect(() => encode(i16(-32769)), throwsException);
  });
  
  test('test decode i16', () {
    var i16_decode = (String hexInput, i16 expectVal) {
      var v = decode(hexInput, 'i16');
      expect(v.runtimeType, i16);
      expect((v as i16).val, expectVal.val);
    };

    i16_decode('0000', i16(0));
    i16_decode('6400', i16(100));
    i16_decode('7f00', i16(127));
    i16_decode('ff7f', i16(32767));
    i16_decode('ffff', i16(-1));
    i16_decode('80ff', i16.fromJson(-128));
  });
  
  test('test encode u32', () {
    expect(encode(u32(0)), '0x00000000');
    expect(encode(u32(100)), '0x64000000');
    expect(encode(u32(256)), '0x00010000');
    expect(encode(u32(1000)), '0xe8030000');
    expect(encode(u32(4294967295)), '0xffffffff');
  });

  test('test encode u32 overflow', () {
    expect(() => encode(u32(4294967296)), throwsException);
    expect(() => encode(u32(-1)), throwsException);
  });

  test('test decode u32', () {
    var u32_decode = (String hexInput, u32 expectVal) {
      var v = decode(hexInput, 'u32');
      expect(v.runtimeType, u32);
      expect((v as u32).val, expectVal.val);
    };
    u32_decode('00000000', u32(0));
    u32_decode('64000000', u32(100));
    u32_decode('00010000', u32(256));
    u32_decode('e8030000', u32.fromJson(1000));
    u32_decode('ffffffff', u32(4294967295));
  });
  
  test('test encode i32', () {
    expect(encode(i32(0)), '0x00000000');
    expect(encode(i32(100)), '0x64000000');
    expect(encode(i32(127)), '0x7f000000');
    expect(encode(i32(128)), '0x80000000');
    expect(encode(i32(32767)), '0xff7f0000');
    expect(encode(i32(-1)), '0xffffffff');
    expect(encode(i32(-128)), '0x80ffffff');
    expect(encode(i32(-32768)), '0x0080ffff');
    expect(encode(i32(-2147483648)), '0x00000080');
  });
  
  test('test encode i32 overflow', () {
    expect(() => encode(i32(2147483648)), throwsException);
    expect(() => encode(i32(-2147483649)), throwsException);
  });
  
  test('test decode i32', () {
    var i32_decode = (String hexInput, i32 expectVal) {
      var v = decode(hexInput, 'i32');
      expect(v.runtimeType, i32);
      expect((v as i32).val, expectVal.val);
    };
    i32_decode('0x00000000', i32(0));
    i32_decode('0x64000000', i32(100));
    i32_decode('0x7f000000', i32(127));
    i32_decode('0x80000000', i32(128));
    i32_decode('0xff7f0000', i32(32767));
    i32_decode('0xffffffff', i32(-1));
    i32_decode('0x80ffffff', i32.fromJson(-128));
    i32_decode('0x0080ffff', i32.fromJson(-32768));
    i32_decode('0x00000080', i32(-2147483648));
  });

  test('test encode u64', () {
    expect(encode(u64(0)), '0x0000000000000000');
    expect(encode(u64(100)), '0x6400000000000000');
    expect(encode(u64(256)), '0x0001000000000000');
    expect(encode(u64(1000)), '0xe803000000000000');
    expect(encode(u64(4294967295)), '0xffffffff00000000');
    expect(encode(u64('18446744073709551615')), '0xffffffffffffffff');
  });

  test('test encode u64 overflow', () {
    expect(() => encode(u64('18446744073709551616')), throwsException);
    expect(() => encode(u64(-1)), throwsException);
  });

  test('test decode u64', () {
    var u64_decode = (String hexInput, u64 expectVal) {
      var v = decode(hexInput, 'u64');
      expect(v.runtimeType, u64);
      expect((v as u64).val, expectVal.val);
    };
    u64_decode('0x0000000000000000', u64(0));
    u64_decode('0x6400000000000000', u64(100));
    u64_decode('0x0001000000000000', u64(256));
    u64_decode('0xe803000000000000', u64(1000));
    u64_decode('0xffffffff00000000', u64.fromJson(4294967295));
    u64_decode('0xffffffffffffffff', u64.fromJson('18446744073709551615'));
  });

  test('test encode i64', () {
    expect(encode(i64(0)), '0x0000000000000000');
    expect(encode(i64(100)), '0x6400000000000000');
    expect(encode(i64(256)), '0x0001000000000000');
    expect(encode(i64(1000)), '0xe803000000000000');
    expect(encode(i64(-1)), '0xffffffffffffffff');
    expect(encode(i64('9223372036854775807')), '0xffffffffffffff7f');
    expect(encode(i64('-9223372036854775808')), '0x0000000000000080');
  });

  test('test encode i64 overflow', () {
    expect(() => encode(i64('9223372036854775808')), throwsException);
    expect(() => encode(i64('-9223372036854775809')), throwsException);
  });

  test('test decode i64', () {
    var i64_decode = (String hexInput, i64 expectVal) {
      var v = decode(hexInput, 'i64');
      expect(v.runtimeType, i64);
      expect((v as i64).val, expectVal.val);
    };
    i64_decode('0x0000000000000000', i64(0));
    i64_decode('0x6400000000000000', i64(100));
    i64_decode('0x0001000000000000', i64(256));
    i64_decode('0xe803000000000000', i64(1000));
    i64_decode('0xffffffffffffffff', i64(-1));
    i64_decode('0xffffffffffffff7f', i64.fromJson('9223372036854775807'));
    i64_decode('0x0000000000000080', i64('-9223372036854775808'));
  });

  test('test encode u128', () {
    expect(encode(u128(0)), '0x00000000000000000000000000000000');
    expect(encode(u128(100)), '0x64000000000000000000000000000000');
    expect(encode(u128(256)), '0x00010000000000000000000000000000');
    expect(encode(u128(1000)), '0xe8030000000000000000000000000000');
    expect(encode(u128(4294967295)), '0xffffffff000000000000000000000000');
    expect(encode(u128('18446744073709551615')), '0xffffffffffffffff0000000000000000');
    expect(encode(u128(BigInt.parse('340282366920938463463374607431768211455'))), '0xffffffffffffffffffffffffffffffff');
  });

  test('test encode u128 overflow', () {
    expect(() => encode(u128('340282366920938463463374607431768211456')), throwsException);
    expect(() => encode(u128(-1)), throwsException);
  });

  test('test decode u128', () {
    var u128_decode = (String hexInput, u128 expectVal) {
      var v = decode(hexInput, 'u128');
      expect(v.runtimeType, u128);
      expect((v as u128).val, expectVal.val);
    };
    u128_decode('0x00000000000000000000000000000000', u128(0));
    u128_decode('0x64000000000000000000000000000000', u128(100));
    u128_decode('0x00010000000000000000000000000000', u128(256));
    u128_decode('0xe8030000000000000000000000000000', u128.fromJson(1000));
    u128_decode('0xffffffffffffffff0000000000000000', u128.fromJson('18446744073709551615'));
    u128_decode('0xffffffffffffffffffffffffffffffff', u128('340282366920938463463374607431768211455'));
  });

  test('test encode i128', () {
    expect(encode(i128(0)), '0x00000000000000000000000000000000');
    expect(encode(i128(100)), '0x64000000000000000000000000000000');
    expect(encode(i128(256)), '0x00010000000000000000000000000000');
    expect(encode(i128(1000)), '0xe8030000000000000000000000000000');
    expect(encode(i128(4294967295)), '0xffffffff000000000000000000000000');
    expect(encode(i128('170141183460469231731687303715884105727')), '0xffffffffffffffffffffffffffffff7f');
    expect(encode(i128('123456789123456789123456789')), '0x155f047c9fb1e3f2fd1e660000000000');
    expect(encode(i128(-1)), '0xffffffffffffffffffffffffffffffff');
    expect(encode(i128('-123456789123456789123456789')), '0xeba0fb83604e1c0d02e199ffffffffff');
    expect(encode(i128('-170141183460469231731687303715884105728')), '0x00000000000000000000000000000080');
  });

  test('test encode i128 overflow', () {
    expect(() => encode(i128('170141183460469231731687303715884105728')), throwsException);
    expect(() => encode(i128('-170141183460469231731687303715884105729')), throwsException);
  });

  test('test decode i128', () {
    var i128_decode = (String hexInput, i128 expectVal) {
      var v = decode(hexInput, 'i128');
      expect(v.runtimeType, i128);
      expect((v as i128).val, expectVal.val);
    };
    i128_decode('0x00000000000000000000000000000000', i128(0));
    i128_decode('0x64000000000000000000000000000000', i128(100));
    i128_decode('0x00010000000000000000000000000000', i128(256));
    i128_decode('0xe8030000000000000000000000000000', i128(1000));
    i128_decode('0x155f047c9fb1e3f2fd1e660000000000', i128('123456789123456789123456789'));
    i128_decode('ffffffffffffffffffffffffffffff7f', i128.fromJson('170141183460469231731687303715884105727'));
    i128_decode('0xffffffffffffffffffffffffffffffff', i128.fromJson(-1));
    i128_decode('0xeba0fb83604e1c0d02e199ffffffffff', i128('-123456789123456789123456789'));
    i128_decode('00000000000000000000000000000080', i128('-170141183460469231731687303715884105728'));
  });

  test('test encode u256', () {
    expect(encode(u256(0)), '0x0000000000000000000000000000000000000000000000000000000000000000');
    expect(encode(u256(100)), '0x6400000000000000000000000000000000000000000000000000000000000000');
    expect(encode(u256(256)), '0x0001000000000000000000000000000000000000000000000000000000000000');
    expect(encode(u256(1000)), '0xe803000000000000000000000000000000000000000000000000000000000000');
    expect(encode(u256(4294967295)), '0xffffffff00000000000000000000000000000000000000000000000000000000');
    expect(encode(u256('18446744073709551615')), '0xffffffffffffffff000000000000000000000000000000000000000000000000');
    expect(encode(u256(BigInt.parse('115792089237316195423570985008687907853269984665640564039457584007913129639935'))), '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
  });

  test('test encode u256 overflow', () {
    expect(() => encode(u256('115792089237316195423570985008687907853269984665640564039457584007913129639936')), throwsException);
    expect(() => encode(u256(-1)), throwsException);
  });

  test('test decode u256', () {
    var u256_decode = (String hexInput, u256 expectVal) {
      var v = decode(hexInput, 'u256');
      expect(v.runtimeType, u256);
      expect((v as u256).val, expectVal.val);
    };
    u256_decode('0x0000000000000000000000000000000000000000000000000000000000000000', u256(0));
    u256_decode('0x6400000000000000000000000000000000000000000000000000000000000000', u256(100));
    u256_decode('0x0001000000000000000000000000000000000000000000000000000000000000', u256(256));
    u256_decode('0xe803000000000000000000000000000000000000000000000000000000000000', u256.fromJson(1000));
    u256_decode('0xffffffffffffffff000000000000000000000000000000000000000000000000', u256.fromJson('18446744073709551615'));
    u256_decode('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', u256('115792089237316195423570985008687907853269984665640564039457584007913129639935'));
  });

  test('test encode i256', () {
    expect(encode(i256(0)), '0x0000000000000000000000000000000000000000000000000000000000000000');
    expect(encode(i256(100)), '0x6400000000000000000000000000000000000000000000000000000000000000');
    expect(encode(i256(256)), '0x0001000000000000000000000000000000000000000000000000000000000000');
    expect(encode(i256(1000)), '0xe803000000000000000000000000000000000000000000000000000000000000');
    expect(encode(i256(4294967295)), '0xffffffff00000000000000000000000000000000000000000000000000000000');
    expect(encode(i256('57896044618658097711785492504343953926634992332820282019728792003956564819967')), '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f');
    expect(encode(i256(-1)), '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
    expect(encode(i256('-123456789123456789123456789')), '0xeba0fb83604e1c0d02e199ffffffffffffffffffffffffffffffffffffffffff');
    expect(encode(i256('-57896044618658097711785492504343953926634992332820282019728792003956564819968')), '0x0000000000000000000000000000000000000000000000000000000000000080');
  });

  test('test encode i256 overflow', () {
    expect(() => encode(i256('57896044618658097711785492504343953926634992332820282019728792003956564819968')), throwsException);
    expect(() => encode(i256('-57896044618658097711785492504343953926634992332820282019728792003956564819969')), throwsException);
  });

  test('test decode i256', () {
    var i256_decode = (String hexInput, i256 expectVal) {
      var v = decode(hexInput, 'i256');
      expect(v.runtimeType, i256);
      expect((v as i256).val, expectVal.val);
    };
    i256_decode('0x0000000000000000000000000000000000000000000000000000000000000000', i256(0));
    i256_decode('0x6400000000000000000000000000000000000000000000000000000000000000', i256(100));
    i256_decode('0x0001000000000000000000000000000000000000000000000000000000000000', i256(256));
    i256_decode('0xe803000000000000000000000000000000000000000000000000000000000000', i256(1000));
    i256_decode('0xffffffff00000000000000000000000000000000000000000000000000000000', i256(4294967295));
    i256_decode('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f', i256.fromJson('57896044618658097711785492504343953926634992332820282019728792003956564819967'));
    i256_decode('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', i256.fromJson(-1));
    i256_decode('0xeba0fb83604e1c0d02e199ffffffffffffffffffffffffffffffffffffffffff', i256('-123456789123456789123456789'));
    i256_decode('0x0000000000000000000000000000000000000000000000000000000000000080', i256('-57896044618658097711785492504343953926634992332820282019728792003956564819968'));
  });

  test('test conversion between string and int', () {
    expect(i32(123456).toString(), '123456');
    expect(i32(0).toString(), '0');
    expect(i128(-1234567891233456789).toString(), '-1234567891233456789');
    expect(i64('-1234567891233456789').toString(), '-1234567891233456789');
    expect(i256(BigInt.parse('-57896044618658097711785492504343953926634992332820282019728792003956564819968')).toString(), '-57896044618658097711785492504343953926634992332820282019728792003956564819968');
  });

  test('test invalid integer value', () {
    expect(() => i32('0xzzz'), throwsException);
    expect(() => i32([1,2,3]), throwsException);
  });

  test('test decode Option<Bool>', () {
    var obj1 = decode('00', 'Option<Bool>');
    expect(obj1.runtimeType, Option);
    expect((obj1 as Option).presents.val, false);
    expect((obj1 as Option).obj, null);

    var obj2 = decode('01', 'Option<Bool>');
    expect(obj2.runtimeType, Option);
    expect((obj2 as Option).presents.val, true);
    expect((obj2 as Option).obj.runtimeType, Bool);
    expect(((obj2 as Option).obj as Bool).val, true);

    var obj3 = decode('02', 'Option<Bool>');
    expect(obj3.runtimeType, Option);
    expect((obj3 as Option).presents.val, true);
    expect((obj3 as Option).obj.runtimeType, Bool);
    expect(((obj3 as Option).obj as Bool).val, false);

    expect(() => decode('03', 'Option<Bool>'), throwsException);
  });

  test('test encode Option<Bool>', () {
    expect(encode(Option(null)), '0x00');
    expect(encode(Option(Bool(true))), '0x01');
    expect(encode(Option(Bool(false))), '0x02');
  });

  test('test encode Option<i32>', () {
    expect(encode(Option(i32(-32768))), '0x010080ffff');
  });
  
  test('test decode Option<i32>', () {
    var obj = decode('0x010080ffff', 'Option<i32>');
    expect(obj.runtimeType, Option);
    expect((obj as Option).presents.val, true);
    expect((obj as Option).obj.runtimeType, i32);
    expect(((obj as Option).obj as i32).val, -32768);
    expect((obj as Option).data.runtimeType, i32);
  });

  test('test encode H160', () {
    expect(
      encode(H160.fromJson('0102030405060708090a0b0c0d0e0f1011121314')),
      '0x0102030405060708090a0b0c0d0e0f1011121314');
  });

  test('test decode H160', () {
    var obj = decode('0x0102030405060708090a0b0c0d0e0f1011121314', 'H160');
    expect(obj.runtimeType, H160);
    expect(obj.toJson(), '0x0102030405060708090a0b0c0d0e0f1011121314');
  });

  test('test encode H256', () {
    expect(
      encode(H256.fromJson('0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f00')),
      '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f00');
  });

  test('test decode H256', () {
    var obj = decode('0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f00', 'H256');
    expect(obj.runtimeType, H256);
    expect(obj.toJson(), '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f00');
  });

    test('test encode H512', () {
    expect(
      encode(H512.fromJson('0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f002122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f00')),
      '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f002122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f00');
  });

  test('test decode H512', () {
    var obj = decode('0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f002122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f00', 'H512');
    expect(obj.runtimeType, H512);
    expect(obj.toJson(), '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f002122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f00');
  });

  test('test encode fixed length array', () {
    expect(encode(FixedLengthArr.fromJson(0, 'u32', [])), '0x');
    expect(encode(FixedLengthArr.fromJson(1, 'u32', [100])), '0x64000000');
    expect(encode(FixedLengthArr.fromJson(5, 'u32', [100, 0, 256, 1000, 4294967295])), '0x640000000000000000010000e8030000ffffffff');
    expect(() => FixedLengthArr.fromJson(3, 'u32', [1,2]), throwsException);
  });

  test('test decode fixed length array', () {
    var obj1 = decode('0x640000000000000000010000e8030000ffffffff', '[u32; 5]');
    expect(obj1.runtimeType, FixedLengthArr);
    expect((obj1 as FixedLengthArr).values.length, 5);
    expect((obj1 as FixedLengthArr).values[0].runtimeType, u32);
    expect(((obj1 as FixedLengthArr).values[0] as u32).val, 100);

    var obj2 = decode('0x', '[u32; 0]');
    expect(obj2.runtimeType, FixedLengthArr);
    expect((obj2 as FixedLengthArr).values.length, 0);

    var obj3 = fromJson('[u32; 5]', [100, 0, 256, 1000, 4294967295]);
    expect(obj3.runtimeType, FixedLengthArr);
    expect((obj3 as FixedLengthArr).values.length, 5);
    expect((obj3 as FixedLengthArr).values[0].runtimeType, u32);
    expect(((obj3 as FixedLengthArr).values[0] as u32).val, 100);

    expect((obj3.toJson()[2] as u32).val, 256);
  });

  test('test anonymous structure decode/encode', () {
    var obj1 = decode('0x0102', '(u8,u8)') as AnonymousStruct;
    expect(obj1.data.length, 2);
    expect(obj1.data[0] is u8, true);
    expect(obj1.data[1] is u8, true);
    expect((obj1.data[0] as u8).val, 1);
    expect((obj1.data[1] as u8).val, 2);
    expect(encode(obj1), '0x0102');
  
    var obj2 = decode('0x0102030405060708090a0b0c0d0e0f1011121314fffdff', '(H160,u8,Compact<u32>)') as AnonymousStruct;
    expect(obj2.data.length, 3);
    expect(obj2.data[0] is H160, true);
    expect(obj2.data[1] is u8, true);
    expect(obj2.data[2] is Compact, true);
    expect((obj2.data[0] as H160).toJson(), '0x0102030405060708090a0b0c0d0e0f1011121314');
    expect((obj2.data[1] as u8).val, 255);
    var compacted = (obj2.data[2] as Compact).obj;
    expect(compacted is u32, true);
    expect((compacted as u32).val, 0x3fff);
    expect(encode(obj2), '0x0102030405060708090a0b0c0d0e0f1011121314fffdff');

    var obj3 = fromJson('(H512,Option<Bool>,i64)', 
      ['0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f002122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f00',
       true,
       '9223372036854775807']) as AnonymousStruct;
    expect(obj3.data.length, 3);
    expect((obj3.data[0] as H512).toJson(), '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f002122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f00');
    expect(((obj3.data[1] as Option).obj as Bool).val, true);
    expect((obj3.data[2] as i64).val, 9223372036854775807);

    expect(
      jsonDecode(jsonEncode(obj3)),
      [
        '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f002122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f00',
        true,
        9223372036854775807
      ]);
  });

  test('test encode Vec', () {
    var obj1 = fromJson('Vec<u64>', [100, 200, '9223372036854775807', '18446744073709551615', 12345]);
    expect(encode(obj1), '0x146400000000000000c800000000000000ffffffffffffff7fffffffffffffffff3930000000000000');

    var obj2 = fromJson('Vec<Compact<u32>>', [0,5,6,0x40,130,0x4def,1000000]);
    expect(encode(obj2), '0x1c00141801010902be37010002093d00');

    (obj2 as Vec)[2] = Compact(u32(0x4000));
    expect(encode(obj2), '0x1c00140200010001010902be37010002093d00');

    var obj3 = Vec([i32(10), i32(100), i32(1000), i32(10000), i32(10000000)]);
    expect(encode(obj3), '0x140a00000064000000e80300001027000080969800');
  });

  test('test decode Vec', () {
    var obj1 = decode('0x146400000000000000c800000000000000ffffffffffffff7fffffffffffffffff3930000000000000', 'Vec<u64>') as Vec;
    expect(obj1.objects.length, 5);
    expect(obj1[2].toString(), '9223372036854775807');
    expect(obj1[4].toString(), '12345');

    var obj2 = decode('0x1c00141801010902be37010002093d00', 'Vec<Compact<u32>>') as Vec;
    expect(obj2.objects.length, 7);
    expect(obj2[0] is Compact, true);
    expect(((obj2[0] as Compact).obj as u32).toString(), '0');
    expect(((obj2[5] as Compact).obj as u32).toString(), '19951');
  });
}