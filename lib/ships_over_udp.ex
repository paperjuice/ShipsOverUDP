defmodule ShipsOverUdp do
  @moduledoc false

  def start(_type, _args) do
    children = [
      {ShipsOverUdp.UdpServer, []}
    ]

    opts = [strategy: :one_for_one, name: UdpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
