import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import '../src/exceptions.dart';
import 'generated_bindings.dart';

const rootLibraryName = 'package:franz/franz.dart';
const minSupportedVersion = 0x10901FF; // >=1.9.1
const maxSupportedVersionLt = 0x20000FF; // <2.0.0

Uri? _getBundledRootDirectoryPath() {
  final rootPath = Isolate.resolvePackageUriSync(Uri.parse(rootLibraryName));
  return rootPath?.resolve("./librdkafka/bundled/");
}

DynamicLibrary _loadSystemLibrdkafka() {
  if (Platform.isMacOS) {
    return DynamicLibrary.open('librdkafka.dylib');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('librdkafka.dll');
  } else {
    return DynamicLibrary.open('librdkafka.so');
  }
}

DynamicLibrary _loadBundledLibrdkafka() {
  final rootUri = _getBundledRootDirectoryPath();

  if (rootUri == null) {
    exit(169);
  }

  // FIXME: Detect x64/ARM !
  if (Platform.isMacOS) {
    return DynamicLibrary.open(
        rootUri.resolve("./osx-arm64/native/librdkafka.dylib").toFilePath());
  } else if (Platform.isWindows) {
    return DynamicLibrary.open(rootUri
        .resolve("./win-x64/native/librdkafka.dll")
        .toFilePath(windows: true));
  } else {
    return DynamicLibrary.open(
        rootUri.resolve("./linux-arm64/native/librdkafka.so").toFilePath());
  }
}

LibRdKafka _verifyVersion(LibRdKafka library) {
  final version = library.rd_kafka_version();

  if (version < minSupportedVersion || version >= maxSupportedVersionLt) {
    throw UnsupportedLibRdKafkaVersion(
        version: version,
        supportedRange: (minSupportedVersion, maxSupportedVersionLt));
  }

  return library;
}

const bool loadBundledVariant = String.fromEnvironment(
        "LIBDRKAFKA_LOAD_VARIANT",
        defaultValue: "bundled") ==
    "bundled";

final dylib =
    loadBundledVariant ? _loadBundledLibrdkafka() : _loadSystemLibrdkafka();
final librdkafka = _verifyVersion(LibRdKafka(dylib));
