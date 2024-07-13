FROM dart:stable

# Install librdkafka from the official Confluent repository
RUN apt-get update && apt-get install -y software-properties-common wget gnupg \
    && wget -qO - https://packages.confluent.io/deb/7.0/archive.key | gpg --dearmor > /usr/share/keyrings/confluent-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/confluent-archive-keyring.gpg] https://packages.confluent.io/deb/7.0 stable main" | tee /etc/apt/sources.list.d/confluent.list \
    && apt-get update && apt-get install -y \
    librdkafka-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app
RUN dart pub get
CMD ["dart", "example/franz_example.dart"]
