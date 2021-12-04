# Create eaten topic: 
./bin/kafka-topics.sh --create --topic eaten --partitions 1 --replication-factor 1 --bootstrap-server localhost:9092

# List all topic: 
./bin/kafka-topics.sh  --list --bootstrap-server localhost:9092
./bin/kafka-topics.sh --describe --bootstrap-server localhost:9092


# Produce message: 
./bin/kafka-console-producer.sh --topic eaten --bootstrap-server localhost:9092


# Consume message: 
./bin/kafka-console-consumer.sh --topic eaten --from-beginning --bootstrap-server localhost:9092
./bin/kafka-console-consumer.sh --topic eaten --from-beginning --bootstrap-server localhost:9092 --group my-group 


# Consumer Group:
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group mygroup
