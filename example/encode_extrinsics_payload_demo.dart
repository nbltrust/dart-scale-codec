library scalecodec_demo.encode_extrinsics_demo;

import 'package:scalecodec/scalecodec.dart';
import 'package:convert/convert.dart';

import 'encode_extrinsics_payload_demo.reflectable.dart';
import 'runtime.dart';

void main() async {
  initializeReflectable();
  var metadata = await getMetadata('wss://cc1-1.polkadot.network/');
  RuntimeConfigration().registMetadata(metadata);

  Map<String, dynamic> extrinsicsJson = {
    'era': {
      'period': null,
      'phase': null
    },
    'call': {
      'module': "Balances",
      'function': "transfer",
      'args': {
        'dest': '14HSB7tpJf17F1XXzC1GUiPH6c6g9UvTkKC4w4edX8vKte84',
        'value': '10000000000' // if val greater than 2^64, should place string here
      }
    },
    'nonce': 6,
    'tip': 0,
    'spec_version': 22,
    'transaction_version': 4,
    'genesis_hash': '97094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d575',
    'block_hash': '97094e6fb7fb6066cacbf47074a16ce8d4f38a9d02493635f543e2da6d20d575'
  };
  var extrinsics = ExtrinsicsPayloadValue.fromJson(extrinsicsJson);
  createWriterInstance();
  extrinsics.objToBinary();
  print(hex.encode(getWriterInstance().finalize()));
}