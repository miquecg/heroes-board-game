defmodule HeroesCluster.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_cluster,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Cluster.Application, []}
    ]
  end

  defp deps do
    [
      {:libcluster, "~> 3.2"}
    ]
  end
end
