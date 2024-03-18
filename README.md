# ShipsOverUDP
![banner](https://4kwallpapers.com/images/walls/thumbs_3t/9460.jpg)

ShipsOverUDP is a compact service designed to handled thousands of messaged streamed over UDP. It tries to achieve this by making use of Nginx Load Balancer to distribute load, Kafka to store and stream messages and CassandraDB to persist those messages.

## Architecture
![design](https://github.com/paperjuice/ShipsOverUDP/assets/15971255/1be93cc2-2d0f-4c37-b273-5f64409cb3f2)

### Rational
We have setup a load balancer to listen to the UDP messages. The load balancer distributes the load to the available service instances. In our case, we have two Elixir nodes running but we can expand horizontally with more nodes. This way we ensure better performance, splitting the load, as well as aiming to ensure up to 100% uptime: if the any of the nodes goes down, there are still alive ones to continue processing.
Once the data is distributed, the system makes use of Poolboy to spawn a controlled number of processes to handle those messages. At this point in the flow our number one priority is to facilitate the flow of data in order to avoid congestion and therefore UDP packet loss.
The data is then asynchronously (based on threads) or in parallel (based on cores) pushed to our Kafka topics. In our case we run 2 brokers, again, to maximize uptime. The Kafka brokers replicate messages so in case of outages, we are covered.
Once the data is pushed to Kafka topics, we are able to consume any new messages. We have a Kafka consumer group setup which allows us to consume messages once per consumer regardles of how many consumers are in the cluster.
Consumed messages are commited every X amount of time meaning that, in case all Elixir nodes go down, Kafka will be able to resume where we left off.
Every time we consume a message we persist it to our CassandraDB setup. In this example we run two shards that share the data. CassandraDB, as a NoSQL database is very well suited to handle very hight load.

## Running the system
### Prerequisites
The project requires you to have [Docker](https://www.docker.com/), [make](https://en.wikipedia.org/wiki/Make_(software)) and [Git](https://git-scm.com/book/en/v2/Getting-Started-The-Command-Line) installed on your machine.
The project was build using Docker version 25.0.3
```
Ξ docker --version
Docker version 25.0.3, build 4debf41
```

### Running the project
First, clone the git project and cd into it
```
git clone https://github.com/paperjuice/ShipsOverUDP.git ships_over_udp && cd ships_over_udp
```

In order to start the project all you have to do is run
```
make up
```
This command will start 1 Nginx Load Balancer, 1 Zookeeper (Kafka manager), 2 Kafka brokers, 2 Elixir nodes and 2 CassandraDB Shards
It does take a bit of time to load.

### Testing
If you wish to test the application you will have to push UDP packets to localhost:2052
I personally used [PacketSender](https://packetsender.com/), free to use and it works with minimum configuration.
![udp](https://github.com/paperjuice/ShipsOverUDP/assets/15971255/baf79aa2-7221-4b9f-bcce-a69f5a4a400e)

For the purpose of this exercise, I am logging each choke point (udp, produce, consume, insert)
We don't want this in production because we will clutter the Logging system very quickly

### Web API
The app also provides a Web API to retrieve stored messages:
```
http://localhost:4000/?vessel_id=<vessel_id>&last_x_msgs=<last_x_msgs>
```
vessel_id = Identifer of the ship
last_x_msgs = The last X messages in descending order based on `creation` time
<img width="1371" alt="image" src="https://github.com/paperjuice/ShipsOverUDP/assets/15971255/d3eba8b4-67d0-4fe8-9e67-c98bcb82e362">


Get total number of records stored in the DB
```
http://localhost:4000/count
```

## Throubleshooting
- If you encounter any issues while running `make up`: force cancel -> `make clean` -> `make up`
- Sometimes the Load Balancer fails with `upstream timed out`. This usually gets fixed if you wait a bit. I have to look into it, not sure why it's happening

## Styleguide
For code consistency I refer to [this style guide](https://github.com/christopheradams/elixir_style_guide)(except for the module directives, those I order alphabetically because it is easier to remember)

## Improvements
This project was done in a short amount of time and the focus was on the high level architecture. There are countless improvements that can be done to it. Some more notable are:
- Tests
- Use @callback for API modules to facilitate mocking and public function transparency
- CI/CD
- Specs
- Telemetry, track each chokepoint for time to complete/latency
- Git hooks to mix format/credo on `git add`
- What happens if the producer worker crashes?
- Improve logging by creating a module on top of Logger so the log messages are consistent + include module name using __ENV__
- Add schema validation. Potential issue is that you have to maintain the schema in two places, tho tests will handle that
- Better understanding of Xandra & KafkaEx
- Instead of starting the App in interactive shell, start in executable (`mix release`)
- Extend the configuration. The app is hightly configurable (e.g. poolboy consumer/producer, number or app nodes, kafka brokers, cassandra instances etc.)
- ScyllaDB potentially better alternative to CassandraDB

## Learning material
[KAFKA cheat sheet](https://medium.com/@TimvanBaarsen/apache-kafka-cli-commands-cheat-sheet-a6f06eac01b)

[CassandraDB best practices](https://www.heatware.net/cassandra/cassandra-data-model-best-practices/)
