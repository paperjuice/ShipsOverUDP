defmodule ShipsOverUdp.Web.Api do
  @moduledoc false
  alias ShipsOverUdp.Model.Table.Vessels
  use Plug.Router

  plug Plug.Parsers,
     parsers: [:urlencoded, :multipart],
     pass: ["text/*"]
  plug :match
  plug :dispatch



  get "/" do
    conn
    |> Map.get(:query_params)
    |> handle_query()
    |> case do
      {:ok, json_list} -> send_resp(conn, 200, json_list)

        # 422 - unprocessable request
      {:error, msg} -> send_resp(conn, 422, msg)
    end
  end

  match _ do
    send_resp(conn, 404, "Path not found")
  end

  # ---------------------------------------------
  #                    PRIVATE
  # ---------------------------------------------
  defp handle_query(%{"vessel_id" => vessel_id, "last_x_msgs" => last_x_msgs}) do
    int_last_x_msgs = String.to_integer(last_x_msgs)

    json_list =
      vessel_id
      |> Vessels.get_by_vessel_id_with_limit(int_last_x_msgs)
      |> Jason.encode!()

    {:ok, json_list}
  end

  defp handle_query(_) do
    {:error, "Please provider vessel_id and last_x_msgs in the query params"}
  end
end
