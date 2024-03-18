defmodule ShipsOverUdp.MessageProcessor.ConsumerWorker do
  @moduledoc false
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:consume_ais_msg, msg}, state) do
    IO.inspect(msg, label: MSG_Consumed)

    #TODO insert into cassandra
    {:noreply, state}
  end

  def consume(msg) do
    Task.start(fn ->
      :poolboy.transaction(
        :consumer_worker,
        fn pid ->
          try do
            GenServer.cast(pid, {:consume_ais_msg, msg})
          catch
            e, r -> IO.inspect("poolboy transaction caught error: #{inspect(e)}, #{inspect(r)}")
              :ok
          end
        end,
        60_000
      )
    end)
  end
end
