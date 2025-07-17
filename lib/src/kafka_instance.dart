import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:franz/franz.dart';
import 'package:franz/librdkafka/loader.dart';
import 'package:franz/src/utils/error_handler.dart';
import 'package:franz/src/utils/uint8list_native.dart';

import '../librdkafka/generated_bindings.g.dart';
import 'exceptions.dart';
import 'utils/variable_arguments.dart';

part 'kafka_consumer.dart';
part 'kafka_producer.dart';

typedef KafkaHandle = rd_kafka_s;

enum KafkaInstanceType { producer, consumer }

class _KafkaInstance {
  late Pointer<KafkaHandle> _$native;

  _KafkaInstance(
      {required KafkaInstanceType type,
      required KafkaConfiguration configuration}) {
    final nativeConfiguration = configuration.toNative();

    final errHandler = ErrorStringHandler();

    _$native = librdkafka.rd_kafka_new(
        switch (type) {
          KafkaInstanceType.consumer => rd_kafka_type_t.RD_KAFKA_CONSUMER,
          KafkaInstanceType.producer => rd_kafka_type_t.RD_KAFKA_PRODUCER,
        },
        nativeConfiguration,
        errHandler.ptr,
        errHandler.maxLength);

    errHandler.dispose();
    // malloc.free(nativeConfiguration);

    if (_$native == nullptr) {
      throw KafkaInstanceCreationError(errorText: errHandler.string);
    }
  }

  KafkaTopic useTopic(String name) =>
      KafkaTopic(kafkaNativeInstance: _$native, name: name);

  void dispose() {
    librdkafka.rd_kafka_destroy(_$native);
  }
}
