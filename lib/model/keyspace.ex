defmodule ShipsOverUdp.Model.Keyspace do
  @moduledoc """
  Module in charge with setting up CassandraDB
  """

  # TODO: make this a variable
  @cluster ShipsOverUdpXandra

  require Logger

  def start_link do
    resp =
      Xandra.Cluster.start_link(
        nodes: ["#{db_domain()}:9042", "#{db_domain()}:9043"],
        pool_size: 10,
        load_balancing: {Xandra.Cluster.LoadBalancingPolicy.DCAwareRoundRobin, []},
        name: @cluster,
        # TODO: look into this
        queue_checkouts_before_connecting: [max_size: 100, timeout: 5_000]
      )

    with {:ok, _} <- create_keyspace(),
         {:ok, _} <- create_table() do
      Logger.info("DB successfully initialised")
      resp
    end
  end

  def available_con, do: Xandra.Cluster.connected_hosts(@cluster)

  def create_keyspace do
    # TODO: maybe env var this? replication_factor: 2
    statement =
      "CREATE KEYSPACE default_schema WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 2 };"

    execute_init("keyspace", statement)
  end

  def create_table do
    statement = """
    CREATE TABLE default_schema.vessels (
      coordinates_id UUID,
      vessel_id text,
      sentence_type text,
      current_time text,
      latitude text,
      lat_compass_direction text,
      longitude text,
      long_compass_direction text,
      metadata map<text, text>,
      created_at timestamp,
      PRIMARY KEY (vessel_id, created_at, coordinates_id)
      ) WITH CLUSTERING ORDER BY (created_at DESC);
    """

    execute_init("create_table", statement)
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp execute_init(action, statement) do
    case Xandra.Cluster.execute(@cluster, statement, []) do
      {:error, %{reason: :already_exists}} ->
        {:ok, "#{action} aready exists"}

      {:ok, _} ->
        {:ok, "successfully created"}

      {:error, %{reason: reason}} ->
        {:error, "#{action} creation failed with reason #{inspect(reason)}"}
    end
  end

  defp db_domain, do: Application.get_env(:ships_over_udp, :cassandra_db_domain)
end
