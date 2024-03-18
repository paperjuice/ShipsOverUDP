defmodule ShipsOverUdp.MessageProcessor.ProducerWorker do
  @moduledoc false
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:ais_msg, msg}, state) do
    IO.inspect(msg, label: MSG_PUBLISHED)
    {:noreply, state}
  end

  def publish(msg) do
    Task.start(fn ->
      :poolboy.transaction(
        :producer_worker,
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
