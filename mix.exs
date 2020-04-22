defmodule HeroesGame.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      deps: deps()
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev], runtime: false}
    ]
  end
end
