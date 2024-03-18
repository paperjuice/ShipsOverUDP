defmodule ShipsOverUdp.UdpServer do
  @moduledoc false
  alias ShipsOverUdp.MessageProcessor.ProducerWorker
  use GenServer
  @port 2052

  def start_link(_), do: GenServer.start_link(__MODULE__, name: __MODULE__)

    def init(_) do
    # Use erlang's `gen_udp` module to open a socket
    # With options:
    #   - binary: request that data be returned as a `String`
    #   - active: gen_udp will handle data reception, and send us a message `{:udp, socket, address, port, data}` when new data arrives on the socket
    # Returns: {:ok, socket}


    # TODO: Move port to config
    :gen_udp.open(@port, [:binary, active: true])
  end

  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    ProducerWorker.publish(data)
    {:noreply, socket}
  end

end
