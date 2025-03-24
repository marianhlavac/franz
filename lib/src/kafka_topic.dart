import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:franz/librdkafka/generated_bindings.g.dart';
import 'package:franz/librdkafka/loader.dart';
import 'package:franz/src/utils/uint8list_native.dart';

import 'exceptions.dart';
import 'models/active_consumer.dart';
import 'models/consumer_offset.dart';
import 'models/consumer_record.dart';

part 'kafka_topic_consumer.dart';
part 'kafka_topic_producer.dart';

class KafkaTopic {
  final String name;
  late Pointer<rd_kafka_topic_s> _$native;

  KafkaTopic(
      {required Pointer<rd_kafka_s> kafkaNativeInstance, required this.name}) {
    final namePtr = name.toNativeUtf8();

    _$native = librdkafka.rd_kafka_topic_new(
        kafkaNativeInstance, namePtr.cast<Char>(), nullptr);

    malloc.free(namePtr);

    if (_$native == nullptr) {
      throw KafkaTopicCreateError(
          errorNumber: librdkafka.rd_kafka_errno()); // FIXME: probably wrong
    }
  }

  void dispose() {
    librdkafka.rd_kafka_topic_destroy(_$native);
  }
}
