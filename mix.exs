defmodule HeroesGame.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: dialyzer_flags()
      ]
    ]
  end

  defp aliases do
    [
      quality: ["format", "credo --strict", "dialyzer"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer_flags do
    [
      :unmatched_returns,
      :error_handling
    ]
  end
end
