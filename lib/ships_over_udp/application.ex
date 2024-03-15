defmodule ShipsOverUdp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShipsOverUdp.UdpServer,
      :poolboy.child_spec(:worker, poolboy_config()),

      %{
        id: ShipsOverUdp.Model.Keyspace,
        start: {ShipsOverUdp.Model.Keyspace, :start_link, []}
      },


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
   defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: ShipsOverUdp.Producer,
      #TODO: make this env var
      size: 5, # Max number of spawned processes
      max_overflow: 2,
      strategy: :fifo
    ]
  end


end
