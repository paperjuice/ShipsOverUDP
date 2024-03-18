defmodule ShipsOverUdp.Model.Table.Vessels do
  @moduledoc """
  Helper CassandraDB queries.
  Available so far:
  - get_by_vessel_id_with_limit/2 # returns all rows for for vessel_id with limit
  - row_num/0 # count for how many rows in the DB
  - insert/1 # create a new record in the DB
  """

  require Logger

  @cluster ShipsOverUdpXandra
  @schema "default_schema"
  @table "vessels"

  def get_by_vessel_id_with_limit(vessel_id, limit) do
    query = "SELECT * FROM #{@schema}.#{@table} where vessel_id=? limit ?;"

    Xandra.Cluster.run(@cluster, fn conn ->
      with {:ok, prepared} <- Xandra.prepare(conn, query),
           {:ok, %Xandra.Page{} = page} <- Xandra.execute(conn, prepared, [vessel_id, limit]) do
        Enum.to_list(page)
      end
    end)
  end

  def row_num do
    query = "SELECT COUNT(*) FROM #{@schema}.#{@table};"

    Xandra.Cluster.run(@cluster, fn conn ->
      with {:ok, prepared} <- Xandra.prepare(conn, query),
           {:ok, %Xandra.Page{} = page} <- Xandra.execute(conn, prepared, []) do
        [%{"count" => count}] = Enum.to_list(page)
        count
      end
    end)
  end

  def insert(%{vessel_id: vessel_id} = params) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    query = """
    INSERT INTO #{@schema}.#{@table} (
      coordinates_id,
      vessel_id,
      sentence_type,
      current_time,
      latitude,
      lat_compass_direction,
      longitude,
      long_compass_direction,
      metadata,
      created_at
    ) VALUES (
     :coordinates_id,
     :vessel_id,
     :sentence_type,
     :current_time,
     :latitude,
     :lat_compass_direction,
     :longitude,
     :long_compass_direction,
     :metadata,
     :created_at
    );
    """

    Xandra.Cluster.run(@cluster, fn conn ->
      prepared = Xandra.prepare!(conn, query)

      Xandra.execute!(conn, prepared, %{
        "coordinates_id" => UUID.uuid1(),
        "vessel_id" => vessel_id,
        "sentence_type" => Map.get(params, :sentence_type),
        "current_time" => Map.get(params, :current_time),
        "latitude" => Map.get(params, :latitude),
        "lat_compass_direction" => Map.get(params, :lat_compass_direction),
        "longitude" => Map.get(params, :longitude),
        "long_compass_direction" => Map.get(params, :long_compass_direction),
        # TODO: make sure keys & values are strings validation
        "metadata" => Map.get(params, :metadata),
        "created_at" => timestamp
      })
    end)

    Logger.info("[PERSISTENCY] Message successfully stored")
  end
end
