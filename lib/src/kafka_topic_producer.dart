part of 'kafka_topic.dart';

class KafkaProducerTopic extends KafkaTopic {
  KafkaProducerTopic({required super.kafkaNativeInstance, required super.name});

  void produceMessage({
    required Uint8List payload,
    Uint8List? key,
    int partition = 0,
  }) {
    final keyData = key?.toNative();
    final messageData = payload.toNative();

    final result = librdkafka.rd_kafka_produce(
      _$native,
      partition,
      RD_KAFKA_MSG_F_COPY,
      keyData?.cast<Void>() ?? nullptr,
      key?.length ?? 0,
      messageData.cast<Void>(),
      payload.length,
      nullptr,
    );

    if (keyData != null) malloc.free(keyData);
    malloc.free(messageData);

    if (result < 0 /* FIXME: use const/enum */) {
      throw KafkaProduceError(
          errorNumber: librdkafka.rd_kafka_errno()); // FIXME: probably wrong
    }
  }

  void produceStringMessage({
    required String payload,
    String? key,
    int partition = 0,
  }) =>
      produceMessage(
        payload: utf8.encode(payload),
        key: key != null ? utf8.encode(key) : null,
        partition: partition,
      );
}
