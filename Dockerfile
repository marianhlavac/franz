# Use an official Dart runtime as a parent image
FROM dart:stable

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libsasl2-dev \
    libzstd-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install librdkafka version 2.4.0
RUN wget https://github.com/confluentinc/librdkafka/archive/refs/tags/v2.4.0.tar.gz && \
    tar -xzf v2.4.0.tar.gz && \
    cd librdkafka-2.4.0 && \
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf librdkafka-2.4.0 v2.4.0.tar.gz

# Create a directory for the app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Get the Dart dependencies
RUN dart pub get

# Run the Dart application
CMD ["dart", "example/franz_example.dart"]
