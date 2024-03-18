defmodule ShipsOverUdp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ships_over_udp,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ShipsOverUdp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:poolboy, "~> 1.5.1"},
      {:xandra, "~> 0.14"},
      {:kafka_ex, "~> 0.11"},
      {:uuid, "~> 1.1"},
      {:plug_cowboy, "~> 2.5"},
      {:jason, "~> 1.2"},
      {:decimal, "~> 2.0"}
    ]
  end
end
