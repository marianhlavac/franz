import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

extension Uin8ListInNative on Uint8List {
  Pointer<Uint8> toNative() {
    final keyDataMemory = malloc.allocate<Uint8>(length);
    final keyBytes = keyDataMemory.asTypedList(length);
    keyBytes.setRange(0, length, this);
    return keyDataMemory;
  }
}
