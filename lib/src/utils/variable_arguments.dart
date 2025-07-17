import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:franz/src/utils/uint8list_native.dart';

import '../../librdkafka/generated_bindings.g.dart';
import '../../librdkafka/loader.dart';

class VariableArguments {
  final Map<int, dynamic> vus;
  VariableArguments() : vus = {};

  int get count => vus.length;

  final List<Pointer> _toFree = [];

  void add(rd_kafka_vtype_t vuType, dynamic value) {
    if (vus.containsKey(vuType.value)) {
      throw ArgumentError('Variable argument of type $vuType already exists.');
    }
    vus[vuType.value] = value;
  }

  void remove(int vuType) {
    if (!vus.containsKey(vuType)) {
      throw ArgumentError('Variable argument of type $vuType does not exist.');
    }
    vus.remove(vuType);
  }

  Pointer<rd_kafka_vu_s> build() {
    final count = vus.length;
    final vusPtr = malloc.allocate<rd_kafka_vu_s>(
      count * sizeOf<rd_kafka_vu_s>() + 1,
    );

    int index = 0;
    for (final entry in vus.entries) {
      vusPtr[index].vtypeAsInt = entry.key;
      switch (entry.value) {
        case String value:
          final cstrPtr = value.toNativeUtf8();
          vusPtr[index].u.cstr = cstrPtr.cast<Char>();
          _toFree.add(cstrPtr);
          break;
        case int value:
          vusPtr[index].u.i32 = value;
          break;
        case Uint8List value:
          final nativeData = value.toNative();
          vusPtr[index].u.mem.ptr = nativeData.cast<Void>();
          vusPtr[index].u.mem.size = value.length;
          _toFree.add(nativeData);
          break;
        case Map<String, Uint8List> value
            when entry.key == rd_kafka_vtype_t.RD_KAFKA_VTYPE_HEADERS.value:
          final hdrs = librdkafka.rd_kafka_headers_new(
            value.length,
          ); // freed by consumer
          for (final header in value.entries) {
            librdkafka.rd_kafka_header_add(
              hdrs,
              header.key.toNativeUtf8().cast<Char>(),
              header.key.length,
              header.value.toNative().cast<Void>(),
              header.value.length,
            );
          }
          vusPtr[index].u.headers = hdrs;
          break;
        default:
          throw ArgumentError(
            'Unsupported variable argument type: ${entry.value.runtimeType}',
          );
      }
      index++;
    }

    // End sentinel
    vusPtr[index].vtypeAsInt = rd_kafka_vtype_t.RD_KAFKA_VTYPE_END.value;

    return vusPtr;
  }

  void destroy() {
    for (final ptr in _toFree) {
      malloc.free(ptr);
    }
    _toFree.clear();
  }
}
