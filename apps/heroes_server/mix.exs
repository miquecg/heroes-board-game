defmodule HeroesServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_server,
      version: "0.1.0",
      build_path: "../../_build",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      mod: {HeroesServer.Application, []},
      extra_applications: [:sasl, :logger]
    ]
  end

  defp deps do
    []
  end
end
