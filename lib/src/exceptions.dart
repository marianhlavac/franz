class UnsupportedLibRdKafkaVersion {
  final int version;
  final int supported;

  UnsupportedLibRdKafkaVersion({
    required this.version,
    required this.supported,
  });

  @override
  String toString() =>
      "The loaded librdkafka version ($version) is not compatible "
      "with franz library (supported is $supported)";
}

class ExceptionWithErrorText implements Exception {
  final String errorText;
  ExceptionWithErrorText({required this.errorText});

  @override
  String toString() => "$runtimeType\n($errorText)";
}

class KafkaInstanceCreationError extends ExceptionWithErrorText {
  KafkaInstanceCreationError({required super.errorText});
}

class KafkaTopicCreateError implements Exception {
  final int errorNumber;

  KafkaTopicCreateError({required this.errorNumber});
}

class KafkaProduceError implements Exception {
  final int errorNumber;

  KafkaProduceError({required this.errorNumber});
}

class KafkaConfigurationInvalidValueError
    extends KafkaConfigurationResultError {
  KafkaConfigurationInvalidValueError({required super.errorText});
  @override
  String toString() =>
      "Invalid configuration value or property or value not supported in this build\n($errorText)";
}

class KafkaConfigurationUnknownNameError extends KafkaConfigurationResultError {
  KafkaConfigurationUnknownNameError({required super.errorText});
  @override
  String toString() => "Unknown configuration name\n($errorText)";
}

class KafkaConfigurationResultError extends ExceptionWithErrorText {
  KafkaConfigurationResultError({required super.errorText});
}
