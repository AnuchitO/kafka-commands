#!bin/bash

edit: kafka_2.13-3.0.0/config/zookeeper.properties
+#dataDir=/tmp/zookeeper
+dataDir=$HOME/go/src/github.com/anuchito/kafka-commands/data/zookeeper

edit: kafka_2.13-3.0.0/config/server.properties
+#log.dirs=/tmp/kafka-logs
+log.dirs=$HOME/go/src/github.com/anuchito/kafka-commands/data/kafka



Start servers 1 Broker
./bin/zookeeper-server-start.sh config/zookeeper.properties
./bin/kafka-server-start.sh config/server.properties


Create topic
./bin/kafka-topics.sh --create --topic event --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

List all topics
./bin/kafka-topics.sh --list --bootstrap-server localhost:9092
./bin/kafka-topics.sh --topic event --describe --bootstrap-server localhost:9092


Produces
NOTE: if we produce data to topic does not exist Kafka will automated create that topic with default configuration in config/server.properties
Warning message: `[2021-12-18 14:04:09,776] WARN [Producer clientId=console-producer] Error while fejtching metadata with correlation id 3 : {newtopic=LEADER_NOT_AVAILABLE} (org.apache.kafka.clients.NetworkClient)`

./bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic event --producer-property acks=all

NOTE: produce many message (and stop start producer 2 times) to demostrate the order of message only guaranteed at partitions level only


Consumer
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event

NOTE: show the order of message
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --from-beginning


Consumer with group
Scenario: Consumer less than partitions (2 consumers, 3 partitions)
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services

Scenario: Consumer equal to partitions (3 consumers, 3 partitions)
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
NOTE: demostrate if some of them die

Scenario: Consumer more than partitions (4 consumers, 3 partitions)
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group announce-event-services
NOTE: some of them will be inactive

Scenario: New Consumer from subscribe to same topic 
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --group show-event-services --from-beginning
NOTE: if we run it again with --from-beginning it will only read from the last offset commited. it mean --from-beginning have no effect. 
if we stop the show-event-services group then produce message then start show-event-services group again it will show all the message
stop and produce more message to show LAG message in next command


Consumer Groups Manangment
List all consumer groups
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

Describe group
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group show-event-services
AFTER see LAG message then run consumer to comsume message then describe again to see LAG is set to zero


Resetting Offsets
NOTE: we need to stop all consumer in thos group frist before we can reset-offset
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group list-event-services --topic event --reset-offsets --to-earliest
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group list-event-services --topic event --reset-offsets --to-earliest --dry-run
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group list-event-services --topic event --reset-offsets --to-earliest --execute
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group list-event-services --topic event --reset-offsets --shift-by 3 --execute
./bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group list-event-services --topic event --reset-offsets --shift-by -2 --execute

start consumer again we will see message from new offset

CLI Options
./bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic event --property parse.key=true --property key.separator=,
> key,value
> another key,another value

./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic event --property print.key=true --property key.separator=,

Kafkacat
https://medium.com/@coderunner/debugging-with-kafkacat-df7851d21968
brew install kcat
kcat -C -b localhost:9092 -t event

Conduktor - Kafka GUI : https://www.conduktor.io/


Acks & min.insync.replicas
example: replication-factor=3 , min.insync=2, acks=all
we can tolerate 1 Broker going down, otherwise the producer will receive an exception on send


Producer Retries

retry.backoff.ms=100ms
if you reply on key-based ordering, that can be an issue for retires.

how long to keep retry
delivery.timeout.ms=120000ms 

how many requests can be made in parallel:
max.in.flight.requests.per.connection=5


Idempotent Producer
producerProps.put("enable.idempotence", true)

they come with 
- retires = Integer.MAX_VALUE(2^31-1)
- max.in.flight.requests=1
- max.in.flight.requests=5
- acks=all


Safe producer Summary & Demo
Kafka < 0.11
- acks=all
- min.insync.replicas=2
  - ensured two brokers in ISR at least have the data after ack
- retries=MAX_INT
- max.in.flight.requests.per.connection=1
  - ensured only one request is tried at any time, preventing message re-ordering in case of retries

Kafka >= 0.11
- enable.idempotence=true (producer level)
- min.insync.replicas=2 (broker/topic level)
- max.in.flight.requests.per.connection=5
