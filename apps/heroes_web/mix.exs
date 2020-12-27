defmodule HeroesWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_web,
      version: "0.1.0",
      build_path: "../../_build",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
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
      {:heroes_server, in_umbrella: true},
      {:phoenix, "~> 1.5.3"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:wallaby, "~> 0.28.0", only: :test, runtime: false},
      {:hammox, "~> 0.2.5", only: :test}
    ]
  end
end
