defmodule ShipsOverUdp.Repo do
  use Ecto.Repo,
    otp_app: :ships_over_udp,
    adapter: Ecto.Adapters.Postgres
end
