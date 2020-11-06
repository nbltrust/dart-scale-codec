library scalecodec_test.compact_tests;

import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

void main() {
  test('unsigned u8 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 1));
    };
    expect(convert('0'), '0x00');
    expect(convert('100'), '0x64');
    expect(convert('255'), '0xff');

    expect(() => convert('256'), throwsException);
    expect(() => convert('-1'), throwsException);
  });

  test('unsigned u16 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 2));
    };
    expect(convert('0'), '0x0000');
    expect(convert('100'), '0x6400');
    expect(convert('256'), '0x0001');
    expect(convert('1000'), '0xe803');
    expect(convert('65535'), '0xffff');

    expect(() => convert('65536'), throwsException);
    expect(() => convert('-1'), throwsException);
  });

  test('unsigned u32 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 4));
    };
    expect(convert('0'), '0x00000000');
    expect(convert('100'), '0x64000000');
    expect(convert('256'), '0x00010000');
    expect(convert('1000'), '0xe8030000');
    expect(convert('4294967295'), '0xffffffff');

    expect(() => convert('4294967296'), throwsException);
    expect(() => convert('-1'), throwsException);
  });

  test('unsigned u64 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 8));
    };
    expect(convert('0'), '0x0000000000000000');
    expect(convert('100'), '0x6400000000000000');
    expect(convert('256'), '0x0001000000000000');
    expect(convert('1000'), '0xe803000000000000');
    expect(convert('4294967295'), '0xffffffff00000000');
    expect(convert('18446744073709551615'), '0xffffffffffffffff');
    expect(() => convert('18446744073709551616'), throwsException);
    expect(() => convert('-1'), throwsException);
  });

  test('unsigned u128 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 16));
    };
    expect(convert('0'), '0x00000000000000000000000000000000');
    expect(convert('100'), '0x64000000000000000000000000000000');
    expect(convert('256'), '0x00010000000000000000000000000000');
    expect(convert('1000'), '0xe8030000000000000000000000000000');
    expect(convert('4294967295'), '0xffffffff000000000000000000000000');
    expect(convert('18446744073709551615'), '0xffffffffffffffff0000000000000000');
    expect(convert('56498941321546547897984132123121564551'), '0x873bfa696d1af5ebbf704aebdf4c812a');
    expect(convert('340282366920938463463374607431768211455'), '0xffffffffffffffffffffffffffffffff');
    expect(() => convert('340282366920938463463374607431768211456'), throwsException);
    expect(() => convert('-1'), throwsException);
  });

  test('signed i8 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 1, signed: true));
    };

    expect(convert('0'), '0x00');
    expect(convert('100'), '0x64');
    expect(convert('127'), '0x7f');
    expect(convert('-1'), '0xff');
    expect(convert('-128'), '0x80');

    expect(() => convert('128'), throwsException);
    expect(() => convert('-129'), throwsException);
  });

  test('signed i16 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 2, signed: true));
    };

    expect(convert('0'), '0x0000');
    expect(convert('100'), '0x6400');
    expect(convert('127'), '0x7f00');
    expect(convert('128'), '0x8000');
    expect(convert('32767'), '0xff7f');
    expect(convert('-1'), '0xffff');
    expect(convert('-128'), '0x80ff');
    expect(convert('-32768'), '0x0080');

    expect(() => convert('32768'), throwsException);
    expect(() => convert('-32769'), throwsException);
  });

  test('signed i32 encode test', () {
    var convert = (s) {
      var v = BigInt.parse(s);
      return '0x' + hex.encode(BigIntToUint8List(v, 4, signed: true));
    };

    expect(convert('0'), '0x00000000');
    expect(convert('100'), '0x64000000');
    expect(convert('127'), '0x7f000000');
    expect(convert('128'), '0x80000000');
    expect(convert('32767'), '0xff7f0000');
    expect(convert('-1'), '0xffffffff');
    expect(convert('-128'), '0x80ffffff');
    expect(convert('-32768'), '0x0080ffff');
    expect(convert('-2147483648'), '0x00000080');

    expect(() => convert('2147483648'), throwsException);
    expect(() => convert('-2147483649'), throwsException);
  });

  test('unsigned decode test', () {
    var convert = (hexStr) {
      var r = Uint8ListToBigInt(hex.decode(hexStr));
      return r.toString();
    };

    expect(convert('00'), '0');
    expect(convert('6400'), '100');
    expect(convert('ff'), '255');
    expect(convert('e803'), '1000');
    expect(convert('ffff'), '65535');
    expect(convert('c0d3270aa47cf6e914666b'), '129837129873698798791283648');
  });

  test('signed decode test', () {
    var convert = (hexStr) {
      var r = Uint8ListToBigInt(hex.decode(hexStr), signed: true);
      return r.toString();
    };

    expect(convert('00'), '0');
    expect(convert('6400'), '100');
    expect(convert('ff'), '-1');
    expect(convert('e803'), '1000');
    expect(convert('ffff'), '-1');
    expect(convert('ffffffff'), '-1');
    expect(convert('0080'), '-32768');
    expect(convert('80ff'), '-128');
    expect(convert('c0d3270aa47cf6e914666b'), '129837129873698798791283648');
    expect(convert('2c4f9e1106fccf08154fec2a17728a6fffffffffffffffffffffffffffffffff'), '-192019208392108390878912399812038078676');
  });

  Uint8List convertBinary(List<String> args)
    => Uint8List.fromList(args.map((i) => int.parse(i, radix: 2)).toList());

  test('shift right of Uint8List', () {
    var compare = (List<String> a, List<String> b, int shift) {
      var la = convertBinary(a);
      var lb = convertBinary(b);
      expect(Uint8ListShiftRight(la, shift), lb);
    };

    compare(
      [
        '00000110',
        '00011000',
        '01100000',
        '10000000',
        '01100001'
      ],
      [
        '00000001',
        '00000110',
        '00011000',
        '01100000',
        '00011000'
      ],
      2
    );

    compare(
      [
        '00000110',
        '00011000',
        '01100000',
        '10000000',
        '01100001'
      ],
      [
        '00000110',
        '00011000',
        '01100000',
        '00011000'
      ],
      10
    );

    
    compare(
      [
        '00000110',
        '00011000',
        '01100000',
        '10000000',
        '01100001'
      ],
      [
        '00000001',
      ],
      38
    );

    compare(
      [
        '00000110',
        '00011000',
        '01100000',
        '10000000',
        '01100001'
      ],
      [],
      40
    );
  });

  test('shift left of Uint8List', () {
    var compare = (List<String> a, List<String> b, int shift) {
      var la = convertBinary(a);
      var lb = convertBinary(b);
      expect(Uint8ListShiftLeft(la, shift), lb);
    };

    compare(
      [
        '00000001',
        '00000110',
        '00011000',
        '01100000',
        '00011000'
      ],
      [
        '00000100',
        '00011000',
        '01100000',
        '10000000',
        '01100001'
      ],
      2
    );

    compare(
      [
        '00000110',
        '00011000',
        '01100000',
        '00011000'
      ],
      [
        '00000000',
        '00011000',
        '01100000',
        '10000000',
        '01100001'
      ],
      10
    );

    
    compare(
      [
        '00000001',
      ],
      [
        '00000000',
        '00000000',
        '00000000',
        '00000000',
        '01000000'
      ],
      38
    );

    compare(
      [],
      [
        '00000000',
        '00000000',
        '00000000',
        '00000000',
        '00000000'
      ],
      40
    );
  });
}

