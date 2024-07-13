import 'dart:ffi';

import 'package:ffi/ffi.dart';

const defaultMaxLength = 256;

class ErrorStringHandler {
  final int maxLength;
  late Pointer<Char> ptr;

  ErrorStringHandler({this.maxLength = defaultMaxLength}) {
    ptr = malloc.allocate<Char>(maxLength);
  }

  String get string => ptr.cast<Utf8>().toDartString();

  void dispose() {
    malloc.free(ptr);
  }
}
