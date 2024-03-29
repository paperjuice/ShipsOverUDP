defmodule ShipsOverUdp.MessageProcessor.ProducerWorker do
  @moduledoc """
  This module is responsible for asynchronosly pushing messages
  to Kafka topic
  """

  require Logger

  use GenServer

  # TODO: make this env var
  @topic "vessels"

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  def init(_), do: {:ok, nil}

  def publish(msg) do
    Task.start(fn ->
      :poolboy.transaction(
        :producer_worker,
        fn pid ->
          try do
            GenServer.cast(pid, {:ais_msg, msg})
          catch
            e, r ->
              Logger.error(
                "[PRODUCER_WORKER_#{inspect(self())}] poolboy transaction caught error: #{inspect(e)}, #{inspect(r)}"
              )

              :ok
          end
        end,
        60_000
      )
    end)
  end

  def handle_cast({:ais_msg, msg}, state) do
    push_to_topic(msg)
    Logger.info("[PRODUCER_WORKER_#{inspect(self())}] Message pushed to topic #{@topic}")
    {:noreply, state}
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp push_to_topic(msg) do
    KafkaEx.produce(@topic, 0, msg)
  end
end
