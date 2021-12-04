#!/bin/bash

# Download and unarchive Kafka.
curl -O https://dlcdn.apache.org/kafka/3.0.0/kafka_2.13-3.0.0.tgz

tar -xvf kafka_2.13-3.0.0.tgz
cd kafka_2.13-3.0.0


# Start Zookeeper.
./bin/zookeeper-server-start.sh config/zookeeper.properties


# Check zookeeper alive
# need to add KAFKA_OPTS="-Dzookeeper.4lw.commands.whitelist=*" to /etc/kafka/server.properties
echo ruok | nc localhost 2181

# Start Kafka
./bin/kafka-server-start.sh config/server.properties


