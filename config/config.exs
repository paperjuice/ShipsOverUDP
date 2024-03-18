# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kafka_ex,
  brokers: [
    # TODO: this can be done more smart, based on env vars
    {System.get_env("DOMAIN_BROKER_1", "localhost"), 9091},
    {System.get_env("DOMAIN_BROKER_2", "localhost"), 9092}
  ],
  consumer_group: "ships_consumer_group",
  client_id: "ships_over_udp_id",
  sync_timeout: 5000,
  max_restarts: 100,
  max_seconds: 60,
  commit_interval: 5_000,
  commit_threshold: 100,
  auto_offset_reset: :none,
  sleep_for_reconnect: 5_000,
  kafka_version: "0.10.1"

config :ships_over_udp,
  udp_port: "UDP_PORT" |> System.get_env("2052") |> String.to_integer(),
  http_port: "HTTP_PORT" |> System.get_env("4000") |> String.to_integer()

config :ships_over_udp,
  cassandra_db_domain: System.get_env("CASSANDRA_DB_DOMAIN", "127.0.0.1")

import_config "#{config_env()}.exs"
