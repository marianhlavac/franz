import 'dart:isolate';

import 'consumer_record.dart';

class ActiveConsumer {
  final Stream<ConsumerRecord> _stream;
  final int _partition;
  final Isolate _isolate;

  int get partition => _partition;
  Stream<ConsumerRecord> get stream => _stream;

  ActiveConsumer(this._stream, this._partition, this._isolate);

  Future<void> cancel() async {
    _isolate.kill();
  }
}
