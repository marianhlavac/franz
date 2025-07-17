part of 'kafka_instance.dart';

class KafkaProducer extends _KafkaInstance {
  KafkaProducer({required super.configuration})
    : super(type: KafkaInstanceType.producer);

  @override
  KafkaProducerTopic useTopic(String name) =>
      KafkaProducerTopic(kafkaNativeInstance: _$native, name: name);

  void produceMessage({
    required String topic,
    required Uint8List payload,
    Uint8List? key,
    int partition = 0,
    Map<String, Uint8List>? headers,
  }) {
    final args = VariableArguments();

    args.add(rd_kafka_vtype_t.RD_KAFKA_VTYPE_TOPIC, topic);
    args.add(rd_kafka_vtype_t.RD_KAFKA_VTYPE_MSGFLAGS, RD_KAFKA_MSG_F_COPY);
    args.add(rd_kafka_vtype_t.RD_KAFKA_VTYPE_PARTITION, partition);
    args.add(rd_kafka_vtype_t.RD_KAFKA_VTYPE_VALUE, payload);
    if (key != null) {
      args.add(rd_kafka_vtype_t.RD_KAFKA_VTYPE_KEY, key);
    }
    if (headers != null) {
      args.add(rd_kafka_vtype_t.RD_KAFKA_VTYPE_HEADERS, headers);
    }

    final vus = args.build();
    final result = librdkafka.rd_kafka_produceva(_$native, vus, args.count);
    final errorCode = librdkafka.rd_kafka_error_code(result);

    malloc.free(vus);
    args.destroy();

    if (errorCode != rd_kafka_resp_err_t.RD_KAFKA_RESP_ERR_NO_ERROR) {
      throw KafkaProduceError(
        errorNumber: errorCode.value,
        // errorText: librdkafka.rd_kafka_error_string(result),
      );
    }
  }

  void produceStringMessage({
    required String topic,
    required String payload,
    String? key,
    int partition = 0,
    Map<String, Uint8List>? headers,
  }) => produceMessage(
    topic: topic,
    payload: utf8.encode(payload),
    key: key != null ? utf8.encode(key) : null,
    partition: partition,
    headers: headers,
  );
}
