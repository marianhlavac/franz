import 'dart:convert';

import 'models/consumer_record.dart';

typedef BytesConsumerRecord = ConsumerRecord<List<int>, List<int>>;

abstract interface class KafkaBaseHandler {
  void handleRecord(ConsumerRecord<List<int>, List<int>> record);
}

class KafkaCallbackHandler implements KafkaBaseHandler {
  final void Function(BytesConsumerRecord) callback;

  KafkaCallbackHandler(this.callback);

  @override
  void handleRecord(BytesConsumerRecord record) => callback.call(record);
}

abstract interface class KafkaBaseJsonHandler extends KafkaBaseHandler {
  void handleJsonRecord(Map<String, dynamic> data, ConsumerRecord record);

  @override
  void handleRecord(ConsumerRecord record) {
    final json = jsonDecode(record.payload);
    return handleJsonRecord(json, record);
  }
}
