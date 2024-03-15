defmodule ShipsOverUdp.Producer do
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

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp publish_msg(msg) do
    # This takes roughly 0.2 milliseconds and the result is 20%~ lower in byte size
    # The argument here is whether we need smaller messages before pushing to queue or
    # save 0.2 milliseconds and just publish
    # Assuming worst case scenario, at 200k msg/s, it would take roughly 40s
    # to do this action on a single node
    compressed_msg = LSString.compress(msg)
  end

end
