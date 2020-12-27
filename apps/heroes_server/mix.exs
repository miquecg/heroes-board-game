defmodule HeroesServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_server,
      version: "0.1.0",
      build_path: "../../_build",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      mod: {Game.Application, []},
      extra_applications: [:crypto, :logger, :sasl]
    ]
  end

  defp deps do
    []
  end
end
