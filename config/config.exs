# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kafka_ex,
  brokers: [
    #TODO: this can be done more smart, based on env vars
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





config :ships_over_udp,
  ecto_repos: [ShipsOverUdp.Repo]

# Configures the endpoint
config :ships_over_udp, ShipsOverUdpWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ShipsOverUdpWeb.ErrorHTML, json: ShipsOverUdpWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ShipsOverUdp.PubSub,
  live_view: [signing_salt: "SI2/x+/D"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ships_over_udp, ShipsOverUdp.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
