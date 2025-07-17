## 0.3.0

- Added support for **headers** in produced messages
    - Uses `rd_kafka_produceva` for producing messages with headers
- Fixed timestamp reading when consuming messages
- Regenerated FFI bindings using `ffigen` version 19.0.0

## 0.2.0

- Updated **support for latest librdkafka 2.8.0**

## 0.1.0

- Initial version with very basic functionalities (simple producing & consuming)
