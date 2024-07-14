part of 'kafka_instance.dart';

class KafkaProducer extends _KafkaInstance {
  KafkaProducer({required super.configuration})
      : super(type: KafkaInstanceType.producer);

  @override
  KafkaProducerTopic useTopic(String name) =>
      KafkaProducerTopic(kafkaNativeInstance: _$native, name: name);
}
