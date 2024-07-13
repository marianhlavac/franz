part of 'kafka_topic.dart';

class KafkaConsumerTopic extends KafkaTopic {
  KafkaConsumerTopic({required super.kafkaNativeInstance, required super.name});

  Future<KafkaTopicAttachment> attachHandler(
      KafkaBaseHandler handler, int partition, ConsumerOffset offset) async {
    librdkafka.rd_kafka_consume_start(
        _$native, partition, offset.numericOffset);

    final messagesSink = ReceivePort();
    final isolate = await Isolate.spawn(
        (sendPort) => _consumerIsolate(handler, partition, sendPort),
        messagesSink.sendPort,
        debugName: "franz-consumer-$name-$partition");

    final sinkListener = messagesSink.listen((message) {
      handler.handleRecord(message);
    });

    return KafkaTopicAttachment(isolate, _$native, sinkListener);
  }

  void _consumerIsolate(
      KafkaBaseHandler consumer, int partition, SendPort messagesOutlet) {
    // - This method loops in isolate
    while (true) {
      final message =
          librdkafka.rd_kafka_consume(_$native, partition, 1000 /* FIXME */);

      if (message == nullptr) continue;

      if (message.ref.err > 0) {
        if (message.ref.err ==
            rd_kafka_resp_err_t.RD_KAFKA_RESP_ERR__PARTITION_EOF) {
          print(
              "!! Reached end of topic $name [${message.ref.partition}] at offset ${message.ref.offset}");
          // TODO
        } else {
          final errorCstr =
              librdkafka.rd_kafka_message_errstr(message).cast<Utf8>();
          print("Consumption error: ${errorCstr.toDartString()}");
          // TODO
        }
      } else {
        final consumerRecord = ConsumerRecord(
          topic: name,
          partition: partition,
          offset: message.ref.offset,
          timestamp: DateTime
              .now(), // FIXME!!! HOW TO GET TIMESTAMP FROM message.ref???
          key: message.ref.key.cast<Uint8>().asTypedList(message.ref.key_len),
          payload:
              message.ref.payload.cast<Uint8>().asTypedList(message.ref.len),
        );
        messagesOutlet.send(consumerRecord);
        librdkafka.rd_kafka_message_destroy(message);
      }
    }
  }
}
