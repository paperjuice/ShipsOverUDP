defmodule ShipsOverUdpWeb.PageController do
  use ShipsOverUdpWeb, :controller

  def home(conn, %{"last_x_msgs" => last_x_msgs, "vesssel_id" => vessel_id}) do

    render(conn, :home, layout: false)
  end
end
