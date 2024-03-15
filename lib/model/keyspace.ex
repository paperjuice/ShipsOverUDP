defmodule ShipsOverUdp.Model.Keyspace do
  @moduledoc false

  #TODO: make this a variable
  @cluster ShipsOverUdpXandra

  require Logger

  def start_link do
    #{:ok, conn} = Xandra.start_link(nodes: ["127.0.0.1:9042", "127.0.0.1:9043"])
    resp = Xandra.Cluster.start_link(
      nodes: ["127.0.0.1:9042", "127.0.0.1:9043"],
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

  def available_con do
   Xandra.Cluster.connected_hosts(@cluster)
  end

  def create_keyspace do
    #TODO: maybe env var this? replication_factor: 2
    statement = "CREATE KEYSPACE default_schema WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 2 };"
    execute_init("keyspace", statement)
  end

  def create_table do
    statement = """
    CREATE TABLE default_schema.vessels (
    vessel_id text, PRIMARY KEY (vessel_id),
    sentence_type text,
    current_time text,
    latitude text,
    lat_compass_direction text,
    longitude text,
    long_compass_direction text,
    updated timestamp,
    created timestamp,
    );
    """
    execute_init("create_table", statement)
  end


  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp execute_init(action, statement) do
    case Xandra.Cluster.execute(@cluster, statement, []) do
      {:error, %{reason: :already_exists}} -> {:ok, "#{action} aready exists"}
      {:ok, _} -> {:ok, "successfully created"}
      {:error, %{reason: reason}} -> {:error, "#{action} creation failed with reason #{inspect(reason)}"}
    end
  end


end
