import 'dart:typed_data';

// =============================================================
// Numeric conversion functions deal with little endian integers
// =============================================================
BigInt Uint8ListToBigInt(Uint8List l, {bool signed = false}) {
  var isNag = signed && (l.last & 0x80 != 0);
  BigInt res = BigInt.zero;
  int shift = 0;
  l.forEach((v) {
    res += (BigInt.from(v) << shift);
    shift += 8;
  });

  if(isNag) {
    res -= BigInt.one << (l.length * 8);
  }
  return res;
}

Uint8List BigIntToUint8List(BigInt v, int byteLength, {bool signed = false}) {
  if(byteLength > 0) {
    var upper, lower;
    if(signed) {
      upper = (BigInt.one << (byteLength * 8 - 1)) - BigInt.one;
      lower = -(BigInt.one << (byteLength * 8 - 1));
    } else {
      upper = (BigInt.one << (byteLength * 8)) - BigInt.one;
      lower = BigInt.zero;
    }
    if(v > upper || v < lower) {
      throw Exception("Integer value ${v.toString()} overflow");
    }
  }
  
  List<int> res = [];
  
  var isNag = v.isNegative;
  if(isNag) {
    // convert v to 2's complement of v
    v += (BigInt.one << (byteLength * 8));
  }

  while(v > BigInt.zero) {
    res.add((v & BigInt.from(0xff)).toInt());
    v >>= 8;
  }

  if(res.length == 0) { // return [0] if v = 0
    res.add(0);
  }

  if(byteLength > res.length) {
    res.addAll(List.filled(byteLength - res.length, isNag ? 0xff : 0));
  }

  return Uint8List.fromList(res);
}

Uint8List Uint8ListShiftRight(Uint8List l, int shift) {
  List<int> ret = [];
  var skip = shift ~/ 8;
  var _shift = shift - skip * 8;
  if(skip >= l.length) {
    return Uint8List.fromList(ret);
  }
  var lower_mask = (1 << _shift) - 1;

  for(var i = skip; i < l.length; i++) {
    var next = i + 1 == l.length ? 0 : l[i + 1];
    ret.add((l[i] >> _shift) | ((next & lower_mask) << (8 - _shift)));
  }
  return Uint8List.fromList(ret);
}

Uint8List Uint8ListShiftLeft(Uint8List l, int shift) {
  List<int> ret = [];
  var pad = shift ~/ 8;
  var _shift = shift - pad * 8;
  ret.addAll(List.filled(pad, 0));
  int prev = 0;
  l.forEach((e) {
    ret.add((e << _shift) | (prev >> (8 - _shift)));
    prev = e;
  });
  return Uint8List.fromList(ret);
}