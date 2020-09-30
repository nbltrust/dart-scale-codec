library scalecodec_test.compact_tests;

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'compact_tests.reflectable.dart';

void testDecode(String hexInput) {
  createReaderInstance(hexInput);
  var r = fromBinary('Vec<Str>');
  assert(r is Vec);
  for(Str s in ((r as Vec).objects as List)){
    print(s.val);
  }
}
void main() {
  initializeReflectable();
  //print(String.fromCharCodes(hex.decode(
  testDecode("2040436865636b5370656356657273696f6e38436865636b547856657273696f6e30436865636b47656e6573697338436865636b4d6f7274616c69747928436865636b4e6f6e63652c436865636b576569676874604368617267655472616e73616374696f6e5061796d656e744850726576616c696461746541747465737473"
  );
  //)));
}