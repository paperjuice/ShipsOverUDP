defmodule ShipsOverUdp.Application do
  @moduledoc false

  alias ShipsOverUdp.MessageProcessor

  use Application

  def start(_type, _args) do
    children = [
      ShipsOverUdp.UdpServer,
      :poolboy.child_spec(:producer_worker, producer_poolboy_config()),
      :poolboy.child_spec(:consumer_worker, consumer_poolboy_config()),
      cassandra(),
      kafka(),
      {Plug.Cowboy, scheme: :http, plug: ShipsOverUdp.Web.Api, options: [port: http_port()]}
    ]

    opts = [strategy: :one_for_one, name: UdpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp cassandra do
    %{
      id: ShipsOverUdp.Model.Keyspace,
      start: {ShipsOverUdp.Model.Keyspace, :start_link, []}
    }
  end

  defp kafka do
    gen_consumer_impl = MessageProcessor.Consumer
    consumer_group_name = "ships_over_udp_con_group"
    topic_names = ["vessels"]

    consumer_group_opts = [
      heartbeat_interval: 1_000,
      commit_interval: 1_000
    ]

    %{
      id: KafkaEx.ConsumerGroup,
      start: {
        KafkaEx.ConsumerGroup,
        :start_link,
        [gen_consumer_impl, consumer_group_name, topic_names, consumer_group_opts]
      }
    }
  end

  defp producer_poolboy_config do
    [
      name: {:local, :producer_worker},
      worker_module: ShipsOverUdp.MessageProcessor.ProducerWorker,
      # TODO: make this env var
      # Max number of spawned processes
      size: 5,
      max_overflow: 2,
      strategy: :fifo
    ]
  end

  defp consumer_poolboy_config do
    [
      name: {:local, :consumer_worker},
      worker_module: ShipsOverUdp.MessageProcessor.ConsumerWorker,
      # TODO: make this env var
      # Max number of spawned processes
      size: 5,
      max_overflow: 2,
      strategy: :fifo
    ]
  end

  defp http_port, do: Application.get_env(:ships_over_udp, :http_port)
end
