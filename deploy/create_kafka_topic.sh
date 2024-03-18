#/bin/bash

/opt/bitnami/kafka/bin/kafka-topics.sh --create --topic $TEST_TOPIC_NAME --bootstrap-server broker-1:29091 --if-not-exists
/opt/bitnami/kafka/bin/kafka-topics.sh --create --topic $TEST_TOPIC_NAME --bootstrap-server broker-2:29092 --if-not-exists

#/opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker-1:29091 --topic $TEST_TOPIC_NAME --group ships_consumer_group --from-beginning
#/opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker-2:29092 --topic $TEST_TOPIC_NAME --group ships_consumer_group --from-beginning

echo "topic $TEST_TOPIC_NAME was create"
