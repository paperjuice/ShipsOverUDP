defmodule ShipsOverUdp.UdpServer do
  @moduledoc false
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, name: __MODULE__)

    def init(_) do
    # Use erlang's `gen_udp` module to open a socket
    # With options:
    #   - binary: request that data be returned as a `String`
    #   - active: gen_udp will handle data reception, and send us a message `{:udp, socket, address, port, data}` when new data arrives on the socket
    # Returns: {:ok, socket}


    # TODO: Move port to config
    :gen_udp.open(2052, [:binary, active: true])
    |> IO.inspect(label: "UPD init")
  end

  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    # punt the data to a new function that will do pattern matching
    IO.inspect(data, label: Data)
    publish(data)

#    Task.Supervisor.start_child(ShipsOverUdp.Supervisor, fn ->
#      IO.inspect(HERE)
#    end)

    Task.start(fn ->
      IO.inspect(HERE)
    end)

    {:noreply, socket}
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
#      ports:
#      - 5433:5432


  defp publish(msg) do

    Task.start(fn ->
      :poolboy.transaction(
        :worker,
        fn pid ->
          # Let's wrap the genserver call in a try - catch block. This allows us to trap any exceptions
          # that might be thrown and return the worker back to poolboy in a clean manner. It also allows
          # the programmer to retrieve the error and potentially fix it.
          try do
            GenServer.cast(pid, {:ais_msg, msg})
           # ShipsOverUdp.Producer.temp(msg)
          catch
            #TODO: handle the message in some way tho
            e, r -> IO.inspect("poolboy transaction caught error: #{inspect(e)}, #{inspect(r)}")

              :ok
          end
        end,
        60_000
      )
    end)
  end


end
