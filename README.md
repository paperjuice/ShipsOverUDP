# ShipsOverUDP

ShipsOverUDP is a compact service designed to handled thousands of messaged streamed over UDP. It tries to achieve this by making use of a Load balancer to distribute load, Kafka to stream messages and CassandraDB to persist those messages

## Architecture



KAFKA cheat sheet
https://medium.com/@TimvanBaarsen/apache-kafka-cli-commands-cheat-sheet-a6f06eac01b

CassandraDB
https://www.heatware.net/cassandra/cassandra-data-model-best-practices/

IMPROVMENTS
- use callback for util modules to facilitate mocking
- telemetry, track each chokepoint for time to complete
- if the producer worker crashes, handle the message some other way. This should happen very rarely so special condition can be used
- improve logging by creating a module on top of Logger so the message is consistent + include module name using __ENV__
- Potential improvement: add schema validation. Issue is that you have to maintain the schema in two places, tho tests will handle that
- tests
- better understanding of Xandra & KafkaEx
- add behaviour to all api modules
- show in the readme the coding standard document
- mix release
- extend the configuration. The app is hightly configurable (e.g. poolboy consumer/producer, number or app nodes, kafka brokers, cassandra instances etc.)
- ScyllaDB potentially better alternative to CassandraDB
- What is %Xandra.Page{}
- spec
- CI/CD
- git hook to mix format on git add


For the purpose of this exercise, I am logging each choke point (udp, produce, consume, insert)
We don't want that in production because we will fill in the logging system very quickly


Commit after each msg with multiple instances or just one instance with delayed commit
