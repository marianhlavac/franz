part of 'kafka_topic.dart';

class KafkaConsumerTopic extends KafkaTopic {
  final StreamController<ConsumerRecord> _sink =
      StreamController<ConsumerRecord>.broadcast();

  KafkaConsumerTopic({required super.kafkaNativeInstance, required super.name});

  Stream<ConsumerRecord> get stream => _sink.stream;

  Future<ActiveConsumer> consumeStart(
    int partition,
    ConsumerOffset offset,
  ) async {
    librdkafka.rd_kafka_consume_start(
      _$native,
      partition,
      offset.numericOffset,
    );

    final messagesSink = ReceivePort();
    final isolate = await Isolate.spawn(
      (sendPort) => _consumerIsolate(partition, sendPort),
      messagesSink.sendPort,
      debugName: "franz-consumer-$name-$partition",
    );

    return ActiveConsumer(
      messagesSink.asBroadcastStream().cast<ConsumerRecord>(),
      partition,
      isolate,
    );
  }

  Future<void> consumeStop(ActiveConsumer activeConsumer) async {
    librdkafka.rd_kafka_consume_stop(_$native, activeConsumer.partition);
    activeConsumer.cancel();
  }

  void _consumerIsolate(int partition, SendPort messagesOutlet) {
    // - This method loops in isolate
    while (true) {
      final message = librdkafka.rd_kafka_consume(
        _$native,
        partition,
        1000 /* FIXME */,
      );

      if (message == nullptr) continue;

      if (message.ref.err.value > 0) {
        if (message.ref.err ==
            rd_kafka_resp_err_t.RD_KAFKA_RESP_ERR__PARTITION_EOF) {
          print(
            "!! Reached end of topic $name [${message.ref.partition}] at offset ${message.ref.offset}",
          );
          // TODO
        } else {
          final errorCstr =
              librdkafka.rd_kafka_message_errstr(message).cast<Utf8>();
          print("Consumption error: ${errorCstr.toDartString()}");
          // TODO
        }
      } else {
        final timestampValue = librdkafka.rd_kafka_message_timestamp(
          message,
          nullptr,
        );

        final consumerRecord = ConsumerRecord(
          topic: name,
          partition: partition,
          offset: message.ref.offset,
          timestamp:
              timestampValue == -1
                  ? DateTime.now()
                  : DateTime.fromMillisecondsSinceEpoch(timestampValue),
          key: message.ref.key.cast<Uint8>().asTypedList(message.ref.key_len),
          payload: message.ref.payload.cast<Uint8>().asTypedList(
            message.ref.len,
          ),
        );
        messagesOutlet.send(consumerRecord);
        librdkafka.rd_kafka_message_destroy(message);
      }
    }
  }
}
