import 'kafka_configuration.dart';
import 'kafka_instance.dart';

class KafkaServerSslOptions {
  final bool rejectUnauthorized;
  final dynamic ca;
  final dynamic key;
  final dynamic cert;

  const KafkaServerSslOptions(
      {required this.rejectUnauthorized,
      required this.ca,
      required this.key,
      required this.cert});
}

class KafkaServerRetryOptions {
  final Duration maxRetryTime;
  final Duration initialRetryTime;
  final int retries;

  const KafkaServerRetryOptions(
      {required this.maxRetryTime,
      required this.initialRetryTime,
      required this.retries});
}

const defaultRetryOptions = KafkaServerRetryOptions(
  maxRetryTime: Duration(seconds: 30),
  initialRetryTime: Duration(seconds: 10),
  retries: 5,
);

class KafkaServer {
  final List<String> bootstrapServers;
  final String clientId;
  final KafkaServerSslOptions? sslOptions;
  final Duration connectionTimeout;
  final Duration requestTimeout;
  final KafkaServerRetryOptions retryOptions;
  final bool enforceRequestTimeout;

  const KafkaServer({
    required this.bootstrapServers,
    this.clientId = 'franz',
    this.sslOptions,
    this.connectionTimeout = const Duration(seconds: 5),
    this.requestTimeout = const Duration(seconds: 10),
    this.retryOptions = defaultRetryOptions,
    this.enforceRequestTimeout = false,
  });

  factory KafkaServer.redpanda({
    String hostname = 'localhost',
    int port = 19092,
    String clientId = 'franz',
    KafkaServerSslOptions? sslOptions,
    Duration connectionTimeout = const Duration(seconds: 5),
    Duration requestTimeout = const Duration(seconds: 10),
    KafkaServerRetryOptions retryOptions = defaultRetryOptions,
    bool enforceRequestTimeout = false,
  }) =>
      KafkaServer(
        bootstrapServers: ['$hostname:$port'],
        clientId: clientId,
        sslOptions: sslOptions,
        connectionTimeout: connectionTimeout,
        requestTimeout: requestTimeout,
        retryOptions: retryOptions,
        enforceRequestTimeout: enforceRequestTimeout,
      );

  KafkaProducer createProducer({
    bool createTopicsAutomatically = true,
  }) =>
      KafkaProducer(
        configuration: KafkaConfiguration(
          bootstrapServers: bootstrapServers.join(','),
          clientId: clientId,
          // autoCreateTopicsEnable: createTopicsAutomatically,
        ),
      );

  KafkaConsumer createConsumer({
    bool createTopicsAutomatically = true,
    String? groupId,
  }) =>
      KafkaConsumer(
        configuration: KafkaConfiguration(
          bootstrapServers: bootstrapServers.join(','),
          clientId: clientId,
          // autoCreateTopicsEnable: createTopicsAutomatically,
          groupId: groupId,
        ),
      );
}
