import 'dart:io';

import 'package:franz/franz.dart';

void main() async {
  final hostname = Platform.environment["HOSTNAME"] ?? "default";

  // Set-up Kafka server
  final kafka =
      KafkaServer.redpanda(hostname: hostname, clientId: 'random-franz');

  // Create producer & producing topic
  final producer = kafka.createProducer();
  final produceTopic = producer.useTopic("franz.test2");

  // Create consumer & attach previously created handler
  final consumer = kafka.createConsumer(groupId: 'franz-1');
  final consumeTopic = consumer.useTopic("funnel.telemetry-ua");

  // Start consuming & listen to consumer stream
  final activeConsumer =
      await consumeTopic.consumeStart(0, ConsumerOffset.end());
  final listener = activeConsumer.stream.listen((record) {
    final textRecord = record.toTextRecord();
    print(textRecord.toString());
  });

  // While consumer is consuming, produce some messages, asynchronously ofc
  while (true) {
    produceTopic.produceStringMessage(
        key: "zdar", payload: "no nazdaaaar", partition: 0);
    await Future.delayed(const Duration(seconds: 2));
  }

  await listener.cancel();
  await consumeTopic.consumeStop(activeConsumer);
}
