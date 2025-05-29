#!/bin/bash

echo "Ожидание запуска Kafka..."
sleep 30

echo "Создание топиков..."

kafka-topics --create \
  --if-not-exists \
  --bootstrap-server kafka_broker_1:29092 \
  --replication-factor 3 \
  --partitions 3 \
  --topic board.event \
  --config retention.ms=604800000 \
  --config compression.type=snappy

kafka-topics --create \
  --if-not-exists \
  --bootstrap-server kafka_broker_1:29092 \
  --replication-factor 3 \
  --partitions 3 \
  --topic calendar.notify \
  --config retention.ms=604800000 \
  --config compression.type=snappy

echo "Топики созданы успешно!"

echo "Список топиков:"
kafka-topics --list --bootstrap-server kafka_broker_1:29092