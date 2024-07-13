import '../../librdkafka/generated_bindings.dart';

class ConsumerOffset {
  final int _offset;
  const ConsumerOffset(int offset) : _offset = offset;

  int get numericOffset => _offset;

  factory ConsumerOffset.beginning() =>
      ConsumerOffset(RD_KAFKA_OFFSET_BEGINNING);
  factory ConsumerOffset.end() => ConsumerOffset(RD_KAFKA_OFFSET_END);
  factory ConsumerOffset.stored() => ConsumerOffset(RD_KAFKA_OFFSET_STORED);
  factory ConsumerOffset.tail() => ConsumerOffset(RD_KAFKA_OFFSET_TAIL_BASE);
}
