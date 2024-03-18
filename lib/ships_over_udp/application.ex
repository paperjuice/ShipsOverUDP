defmodule ShipsOverUdp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
alias ShipsOverUdp.MessageProcessor

  use Application

  @impl true
  def start(_type, _args) do
      gen_consumer_impl = MessageProcessor.Consumer
      consumer_group_name = "ships_over_udp_con_group"
      topic_names = ["vessels"]
      consumer_group_opts = [
        heartbeat_interval: 1_000,
        commit_interval: 1_000
      ]

    children = [
      ShipsOverUdp.UdpServer,

      :poolboy.child_spec(:producer_worker, producer_poolboy_config()),
      :poolboy.child_spec(:consumer_worker, consumer_poolboy_config()),

      %{
        id: ShipsOverUdp.Model.Keyspace,
        start: {ShipsOverUdp.Model.Keyspace, :start_link, []}
      },


      %{
        id: KafkaEx.ConsumerGroup,
        start: {
          KafkaEx.ConsumerGroup,
          :start_link,
          [gen_consumer_impl, consumer_group_name, topic_names, consumer_group_opts]
        }
      },

      {Plug.Cowboy, scheme: :http, plug: ShipsOverUdp.Web.Api, options: [port: http_port()]},






      #TODO: Bunch of not necessary things below, clean up

      # Start the Telemetry supervisor
      ShipsOverUdpWeb.Telemetry,
      # Start the Ecto repository
#      ShipsOverUdp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ShipsOverUdp.PubSub},
      # Start Finch
      {Finch, name: ShipsOverUdp.Finch},
      # Start the Endpoint (http/https)
      ShipsOverUdpWeb.Endpoint
      # Start a worker by calling: ShipsOverUdp.Worker.start_link(arg)
      # {ShipsOverUdp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShipsOverUdp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShipsOverUdpWeb.Endpoint.config_change(changed, removed)
    :ok
  end



  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
   defp producer_poolboy_config do
    [
      name: {:local, :producer_worker},
      worker_module: ShipsOverUdp.MessageProcessor.ProducerWorker,
      #TODO: make this env var
      size: 5, # Max number of spawned processes
      max_overflow: 2,
      strategy: :fifo
    ]
  end

  defp consumer_poolboy_config do
    [
      name: {:local, :consumer_worker},
      worker_module: ShipsOverUdp.MessageProcessor.ConsumerWorker,
      #TODO: make this env var
      size: 5, # Max number of spawned processes
      max_overflow: 2,
      strategy: :fifo
    ]
  end

  defp http_port , do: Application.get_env(:ships_over_udp, :http_port)
end
