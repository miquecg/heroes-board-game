defmodule HeroesServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_server,
      version: "0.1.0",
      build_path: "../../_build",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HeroesServer, []}
    ]
  end

  defp deps do
    []
  end
end
