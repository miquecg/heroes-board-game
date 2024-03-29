defmodule HeroesWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      mod: {Web.Application, []}
    ]
  end

  defp deps do
    [
      {:esbuild, "~> 0.4.0", runtime: Mix.env() == :dev},
      {:hammox, "~> 0.5", only: :test},
      {:heroes_server, in_umbrella: true},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.6"},
      {:phoenix_html, "~> 3.1"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_view, "~> 0.17.4"},
      {:plug_cowboy, "~> 2.0"},
      {:wallaby, "~> 0.29.0", only: :test, runtime: false}
    ]
  end
end
