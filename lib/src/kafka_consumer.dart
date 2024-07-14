part of 'kafka_instance.dart';

class KafkaConsumer extends _KafkaInstance {
  KafkaConsumer({required super.configuration})
      : super(type: KafkaInstanceType.consumer);

  @override
  KafkaConsumerTopic useTopic(String name) =>
      KafkaConsumerTopic(kafkaNativeInstance: _$native, name: name);
}
