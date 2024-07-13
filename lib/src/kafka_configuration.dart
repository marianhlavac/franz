import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:franz/src/utils/error_handler.dart';

import '../librdkafka/generated_bindings.dart';
import '../librdkafka/loader.dart';
import 'exceptions.dart';

class KafkaConfiguration {
  final Map<String, String> _config;

  KafkaConfiguration({
    String? bootstrapServers,
    String? clientId,
    String? metadataBrokerList,
    int? acks,
    int? batchSize,
    String? compressionCodec,
    int? lingerMs,
    int? maxInFlightRequestsPerConnection,
    String? groupId,
    String? autoOffsetReset,
    bool? enableAutoCommit,
    int? maxPollRecords,
    bool? autoCreateTopicsEnable,
    int? messageTimeoutMs,
    String? securityProtocol,
    String? sslCaLocation,
    String? sslCertificateLocation,
    String? sslKeyLocation,
    String? saslMechanisms,
    String? saslUsername,
    String? saslPassword,
    String? logLevel,
  }) : _config = {
          if (bootstrapServers != null) "bootstrap.servers": bootstrapServers,
          if (clientId != null) "client.id": clientId,
          if (metadataBrokerList != null)
            "metadata.broker.list": metadataBrokerList,
          if (acks != null) "acks": acks.toString(),
          if (batchSize != null) "batch.size": batchSize.toString(),
          if (compressionCodec != null) "compression.codec": compressionCodec,
          if (lingerMs != null) "linger.ms": lingerMs.toString(),
          if (maxInFlightRequestsPerConnection != null)
            "max.in.flight.requests.per.connection":
                maxInFlightRequestsPerConnection.toString(),
          if (groupId != null) "group.id": groupId,
          if (autoOffsetReset != null) "auto.offset.reset": autoOffsetReset,
          if (enableAutoCommit != null)
            "enable.auto.commit": enableAutoCommit.toString(),
          if (maxPollRecords != null)
            "max.poll.records": maxPollRecords.toString(),
          if (autoCreateTopicsEnable != null)
            "auto.create.topics.enable": autoCreateTopicsEnable.toString(),
          if (messageTimeoutMs != null)
            "message.timeout.ms": messageTimeoutMs.toString(),
          if (securityProtocol != null) "security.protocol": securityProtocol,
          if (sslCaLocation != null) "ssl.ca.location": sslCaLocation,
          if (sslCertificateLocation != null)
            "ssl.certificate.location": sslCertificateLocation,
          if (sslKeyLocation != null) "ssl.key.location": sslKeyLocation,
          if (saslMechanisms != null) "sasl.mechanisms": saslMechanisms,
          if (saslUsername != null) "sasl.username": saslUsername,
          if (saslPassword != null) "sasl.password": saslPassword,
          if (logLevel != null) "log_level": logLevel,
        };

  Pointer<rd_kafka_conf_s> toNative() {
    final nativeConfigObject = librdkafka.rd_kafka_conf_new();
    final errHandler = ErrorStringHandler();

    for (final entry in _config.entries) {
      final nameCstr = entry.key.toNativeUtf8();
      final valueCstr = entry.value.toNativeUtf8();

      final result = librdkafka.rd_kafka_conf_set(
          nativeConfigObject,
          nameCstr.cast<Char>(),
          valueCstr.cast<Char>(),
          errHandler.ptr,
          errHandler.maxLength);

      malloc.free(nameCstr);
      malloc.free(valueCstr);

      if (result == rd_kafka_conf_res_t.RD_KAFKA_CONF_OK) continue;

      final errorText = errHandler.string;

      switch (result) {
        case rd_kafka_conf_res_t.RD_KAFKA_CONF_INVALID:
          throw KafkaConfigurationInvalidValueError(errorText: errorText);
        case rd_kafka_conf_res_t.RD_KAFKA_CONF_UNKNOWN:
          throw KafkaConfigurationUnknownNameError(errorText: errorText);
        default:
          throw KafkaConfigurationResultError(errorText: errorText);
      }
    }

    errHandler.dispose();
    return nativeConfigObject;
  }
}
