import 'package:franz/franz.dart';

void main() async {
  // Set-up Kafka server
  final kafka = KafkaServer.redpanda(clientId: 'random-franz');

  // Create producer & producing topic
  final producer = kafka.createProducer();

  // Create handler for later async consumption
  final handler = KafkaCallbackHandler((record) {
    final textRecord = record.toTextRecord();
    print(textRecord.toString());
  });
  final produceTopic = producer.useTopic("franz.test2");

  // Create consumer & attach previously created handler
  final consumer = kafka.createConsumer(groupId: 'franz-1');
  final consumeTopic = consumer.useTopic("funnel.telemetry-ua");

  await consumeTopic.attachHandler(handler, 0, ConsumerOffset.end());

  // While consumer is consuming, produce some messages, asynchronously ofc
  while (true) {
    produceTopic.produceStringMessage(
        key: "zdar", payload: "no nazdaaaar", partition: 0);
    await Future.delayed(const Duration(seconds: 2));
  }
}
