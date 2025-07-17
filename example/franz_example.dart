import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:franz/franz.dart';

void main() async {
  final hostname = Platform.environment["HOSTNAME"] ?? "localhost";

  log("Running example on $hostname");

  // Set-up Kafka server
  final kafka = KafkaServer.redpanda(
    hostname: hostname,
    clientId: 'random-franz',
  );

  // Create producer & producing topic
  final producer = kafka.createProducer();
  final produceTopic = producer.useTopic("franz.test2");

  // Create consumer & attach previously created handler
  final consumer = kafka.createConsumer(groupId: 'franz-1');
  final consumeTopic = consumer.useTopic("funnel.telemetry-ua");

  // Start consuming & listen to consumer stream
  final activeConsumer = await consumeTopic.consumeStart(
    0,
    ConsumerOffset.end(),
  );
  final listener = activeConsumer.stream.listen((record) {
    final textRecord = record.toTextRecord();
    log(textRecord.toString());
  });

  // While consumer is consuming, produce some messages, asynchronously ofc
  try {
    while (true) {
      produceTopic.produceStringMessage(payload: "simple message");
      producer.produceStringMessage(
        topic: "franz.test3",
        key: "2f7622af-20ce-4c19-8d89-7f8c1090a535",
        payload: "message with key and headers",
        headers: {"foo": utf8.encode("bar")},
      );
      log("Produced message to franz.test3");
      await Future.delayed(const Duration(seconds: 1));
    }
  } finally {
    await listener.cancel();
    await consumeTopic.consumeStop(activeConsumer);
    producer.dispose();
    consumeTopic.dispose();
  }
}
