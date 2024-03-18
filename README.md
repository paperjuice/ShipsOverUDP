# ShipsOverUdp

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


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

WHAT IS LEFT:
RabbitMQ at first cause ez and then we try Kafka cause better performance per broker
