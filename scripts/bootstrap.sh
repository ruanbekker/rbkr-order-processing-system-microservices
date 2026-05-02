#!/usr/bin/env bash

echo "creating kafka topics"
docker exec -it kafka kafka-topics.sh \
  --create --topic order_created \
  --bootstrap-server localhost:9092 \
  --partitions 1 --replication-factor 1

docker exec -it kafka kafka-topics.sh \
  --create --topic order_reserved \
  --bootstrap-server localhost:9092 \
  --partitions 1 --replication-factor 1

docker exec -it kafka kafka-topics.sh \
  --create --topic order_failed \
  --bootstrap-server localhost:9092 \
  --partitions 1 --replication-factor 1

echo "creating database tables"
pushd ../rbkr-ops-order-service
migrate -path migrations -database "postgres://user:pass@localhost:5432/orders?sslmode=disable" up
popd

echo "setting quantity for books to 10"
docker exec -it redis redis-cli SET books 10

