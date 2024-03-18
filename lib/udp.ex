defmodule ShipsOverUdp.UdpServer do
  @moduledoc false
  alias ShipsOverUdp.MessageProcessor.ProducerWorker
  require Logger
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, name: __MODULE__)

  @spec init(any()) :: {:ok, any()}
    def init(_) do
    # TODO: Move port to config
    :gen_udp.open(port(), [:binary, active: true])
  end

  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    Logger.info("[UDP#{port()}] Message received: #{inspect(data)}")

    ProducerWorker.publish(data)
    {:noreply, socket}
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  def port, do: Application.get_env(:ships_over_udp, :udp_port)
end
