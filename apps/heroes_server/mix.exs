defmodule HeroesServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_server,
      version: "0.1.0",
      build_path: "../../_build",
      elixir: "~> 1.10",
      elixirc_paths: compiler_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp compiler_paths(:test), do: ["test/helpers"] ++ compiler_paths(:prod)
  defp compiler_paths(_), do: ["lib"]

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
