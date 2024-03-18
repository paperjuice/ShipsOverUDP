defmodule ShipsOverUdp.MessageProcessor.ConsumerWorker do
  @moduledoc """
  This module is responsible for consuming messages async
  up to a max number of processes handled by Poolboy
  """
  alias ShipsOverUdp.Model.Table.Vessels
  require Logger

  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  def init(_), do: {:ok, nil}

  def consume(value, offset) do
    Task.start(fn ->
      :poolboy.transaction(
        :consumer_worker,
        fn pid ->
          try do
            GenServer.cast(pid, {:consume_ais_msg, value, offset})
          catch
            e, r ->
              Logger.error(
                "[CONSUMER_WORKER_#{inspect(self())}] poolboy transaction caught error: #{inspect(e)}, #{inspect(r)}"
              )
          end
        end,
        60_000
      )
    end)
  end

  def handle_cast({:consume_ais_msg, value, offset}, state) do
    Logger.info("[CONSUMER_WORKER_#{inspect(self())}] Message consumed")

    value
    |> process_value(offset)
    |> Vessels.insert()

    {:noreply, state}
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp process_value(msg, offset) do
    # e.g. $GPGGA,ABC,210230,3855.4487,N,09446.0071,W,1,07,1.1,370.5,M,-29.5,M,,*7A
    [
      sentence_type,
      vessel_id,
      current_time,
      latitude,
      comp_latitude,
      longitude,
      comp_longitude,
      _,
      _,
      _,
      _,
      _,
      _,
      _,
      _,
      _
    ] = String.split(msg, ",")

    %{
      sentence_type: "#{sentence_type}",
      vessel_id: "#{vessel_id}",
      current_time: "#{current_time}",
      latitude: "#{latitude}",
      lat_compass_direction: "#{comp_latitude}",
      longitude: "#{longitude}",
      long_compass_direction: "#{comp_longitude}",
      # TODO this definitely needs either defstruct or some validator
      metadata: %{"kafka_offset" => "#{offset}"}
    }
  end
end
