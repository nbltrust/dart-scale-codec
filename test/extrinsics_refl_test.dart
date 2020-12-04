library scalecodec_test.extrinsics_refl_test;

import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:scalecodec/scalecodec.dart';
import 'package:test/test.dart';

import 'extrinsics_refl_test.reflectable.dart';
import 'runtime.dart';

Extrinsics decodeExtrinsics(String callHexStr) {
  createReaderInstance(callHexStr);
  return fromBinary('Extrinsics');
}

String encodeExtrinsics(Map<String, dynamic> json) {
  var extrinsics = Extrinsics.fromJson(json);
  createWriterInstance();
  extrinsics.objToBinary();
  return '0x' + hex.encode(getWriterInstance().finalize());
}

void main() {
  initializeReflectable();
  initRuntimeMetadata();

  void runTest(String hexInput) {
    var extrinsics = decodeExtrinsics(hexInput);
    var jsonObj = jsonDecode(jsonEncode(extrinsics));
    expect(encodeExtrinsics(jsonObj), 
      hexInput);
  }

  test('test extrinsics Balance::transfer', () {
    runTest('0x84bed0076497173deb0b724cfea499d5654a005063bf8b2266a0fe0c8da49bc15c016a5cba4bf4ad428b048433b8768620bfc7cbcb7e6d78abb1f486d759fc76676833bdecc9897d55703f8aac64ca7845d5b92db06249c94616be7b597854f9718f4501100005009f8684961961faa278012d5011ad2e60e6d3c8731c4a73a584eee1c7247918e40b00d054ab7a37');
  });

  test('test extrinsics Balance::transferKeepAlive', () {
    runTest('0x84c98987f6277e0b6880bdf0ccec4a7be9cb1d832e26cf90194eb44df8aeb289c800c05a3af908667ff211b2f8e1aa171885ef66f97131949640805254250b2b2112659946562a10c4513ce1a9d94811aa30f2ee27793568fa42fe23636ef5633a05792d0d05000503d21a5689680a5e569d3c4370d2a94daab5fbdf5befaa07b58d0a1658b0c6a4ad0b00e3b8dca10d');
  });

  test('test timestamp::set', () {
    runTest('0x0403000b40738b2b7601');
  });

  test('test staking::bond_extra', () {
    runTest('0x8402b9948ac3d5571d4461bb132819c1b4eb72bafd8b9ebcc39832f9b418cc204c01622658d977f8fa7cc769eb9688e182078fce0e2317385bf0921266faf9eb21669459feb16428bac42ebb0f18cfe5ccad5fab5ff82828eb305ae951a63f14388155022400070107400d653d01');
  });

  test('test staking::chill', () {
    runTest('0x84e66546e67242fef800f81047373ce196985e7066ab47abd2bd135045a077052a0180dbdc1138e99b781024000d1c0998042fc44721375cd6e6abe5898397758371180a0c4bbd785d1d944e25394886e5d14a9d68d64def27ce2121494ea9488183450110000706');
  });

  test('test staking::nominate', () {
    runTest('0x847043be448517d1439167ea63440918bd7e3613da5876274594eb10483142fd7401b4139acfe48f4000bcddb9f9d32b65294d460906567a5cc2c6401bf86767f83b70f3b551edda7c6561eefc8e24d003d2696b3dcd875717a6b7d7a9ee43d1918fe50004000705102c2a55b5cf8d00511ef54ac7a60773810e906befb1b322f2d58199963dc973072c2a55b5a6413894e13836fb0165e6adce7d77c06dccf42b3b288397a27ddd3b2c2a55b5b7e13a772e0b693c3b351d2fb5e5b4da18ac379ebdb2f1f2e75597761baa453966c043ca367ccfa19f450244447b9d32f4b7af2d9749e55a57ac09cc');
  });

  test('test staking::payout_stakers', () {
    runTest('0x84defd2f95f5158e420a92a0d1e2934d532c9d6624dacc7d57abe2d5ccf7d341b0005d3d0fc7ae1868da68a142f57d04b2a87de8130dacd9298c49955164ae1c664e9af4a40d2df1a57f4eff77a6ac3ddb485a6d0be83525cc7053982fbc586953011503c80007129c6a3401d06cef30fdbb33901328f3611dae8253708779a5d66179c967582635b8000000');
  });

  test('test staking::rebond', () {
    runTest('0x842ea5d9ff643083efbe5e8e96b484e58042f270e3144d8a9150b8fbf78237ce470154cff92ad58e5550355686e4946d005ae5a104c61efbbb8d7039d246046dbc5fc270d4379a01f917db069ad782f9e0f5e635f82668d465ff145e085941e9b98f65000c0007130700e40b5402');
  });

  test('test staking::unbond', () {
    runTest('0x84468ae159f9a99defe5ba4a8dc1d3d1a1f5c53aabca8fe4c1972c05d84bf11a6c01f674edc61d4dbedf60a86db3d49160027394a3f8b4c6bc3749a9cd315ef3824408765295653a513d81d371789790da69d022635cf2e4ba914ce52a290c82b483f5010402180d8f07020b00794cc7d402');
  });

  test('test identity::set_identity', () {
    runTest('0x842a9254c4842e2903b50dbd76b28a8f346ad050735ab7533c420451a75b311b6d019ea1391eb351053bbd5fc9ff7c86b7a0722dbb4f4a027faac6e24a9011829e6928bfafde228cc1bc4a88972494ad48ca583c2e39c2304424e7864a83ff911181550378001c01000f416e63686f72205374616b696e6700000000000000');
  });
}