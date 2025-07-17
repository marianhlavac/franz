import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../src/exceptions.dart';
import 'generated_bindings.g.dart';

const rootLibraryName = 'package:franz/franz.dart';

String get libraryName {
  if (Platform.isLinux) return "librdkafka.so";
  if (Platform.isMacOS) return "librdkafka.dylib";
  if (Platform.isWindows) return "librdkafka.dll";
  throw UnsupportedError("Franz library is not supported by this platform");
}

String get libraryPath {
  final envVar = Platform.environment["LIBRDKAFKA_PATH"];
  if (envVar != null) return p.join(envVar, libraryName);

  final dartVar = String.fromEnvironment("LIBRDKAFKA_PATH");
  if (dartVar.isNotEmpty) return p.join(dartVar, libraryName);

  return libraryName;
}

LibRdKafka _verifyVersion(LibRdKafka library) {
  final version = library.rd_kafka_version();

  if (version != RD_KAFKA_VERSION) {
    throw UnsupportedLibRdKafkaVersion(
      version: version,
      supported: RD_KAFKA_VERSION,
    );
  }

  return library;
}

final dylib = DynamicLibrary.open(libraryPath);
final librdkafka = _verifyVersion(LibRdKafka(dylib));
