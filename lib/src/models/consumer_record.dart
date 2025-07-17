import 'dart:convert';

const defaultTextCodec = Utf8Codec();

class ConsumerRecord<KT, PT> {
  final String topic;
  final int partition;
  final int offset;
  final DateTime timestamp;
  final KT? key;
  final PT? payload;
  final Map<String, dynamic>? headers;

  ConsumerRecord({
    required this.topic,
    required this.partition,
    required this.offset,
    required this.timestamp,
    this.key,
    this.payload,
    this.headers,
  });

  String _generateStringPreview(Object? object, int maxLength) {
    return switch (object) {
      String() =>
        (object.length > maxLength
            ? '${object.substring(0, maxLength)}...'
            : object),
      List<int>() =>
        object
                .take(maxLength)
                .map((b) => b.toRadixString(maxLength))
                .join(' ') +
            (object.length > maxLength ? '...' : ''),
      null => 'null',
      _ => 'unknown type?',
    };
  }

  @override
  String toString() {
    return 'ConsumerRecord { '
        'key: ${_generateStringPreview(key, 24)}, '
        'payload: ${_generateStringPreview(payload, 64)}, '
        'topic: $topic[$partition], offset: $offset, timestamp: $timestamp }';
  }

  ConsumerRecord<String, String> toTextRecord([
    Codec codec = defaultTextCodec,
  ]) => ConsumerRecord(
    key: key != null ? codec.decode(key) : null,
    payload: payload != null ? codec.decode(payload) : null,
    topic: topic,
    partition: partition,
    offset: offset,
    timestamp: timestamp,
  );
}
