defmodule ShipsOverUdp.Model.Table.Vessels do
  @moduledoc false
  @cluster ShipsOverUdpXandra
  @schema "default_schema"
  @table "vessels"

  def all do
    query = "SELECT * FROM #{@schema}.#{@table}"

    Xandra.Cluster.run(@cluster, fn conn ->
      with {:ok, prepared} <- Xandra.prepare(conn, query),
           {:ok, %Xandra.Page{} = page} <- Xandra.execute(conn, prepared, []) do
        Enum.to_list(page)
      end
    end)
  end

  def insert(%{vessel_id: vessel_id} = params) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    query =
      EEx.eval_string("""
    INSERT INTO <%= schema %>.<%= table %> (
    vessel_id,
    sentence_type,
    current_time,
    latitude,
    lat_compass_direction,
    longitude,
    long_compass_direction,
    updated,
    created
      ) VALUES (
   '<%= vessel_id %>',
   '<%= sentence_type %>',
   '<%= current_time %>',
   '<%= latitude%>',
   '<%= lat_compass_direction %>',
   '<%= longitude %>',
   '<%= long_compass_direction %>',
   <%= updated %>,
   <%= created %>
        );
        """,
        schema: @schema,
        table: @table,
        vessel_id: vessel_id,
        sentence_type: Map.get(params, :sentence_type),
        current_time: Map.get(params, :current_time),
        latitude: Map.get(params, :latitude),
        lat_compass_direction: Map.get(params, :lat_compass_direction),
        longitude: Map.get(params, :longitude),
        long_compass_direction: Map.get(params, :long_compass_direction),
        updated: timestamp,
        created: timestamp
        )

    Xandra.Cluster.run(@cluster, fn conn ->
      prepared = Xandra.prepare!(conn, query)
      Xandra.execute!(conn, prepared, [])
    end)
  end
end
