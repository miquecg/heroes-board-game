defmodule HeroesCLI.MixProject do
  use Mix.Project

  def project do
    [
      app: :heroes_cli,
      version: "0.1.0",
      build_path: "../../_build",
      elixir: "~> 1.10",
      deps: deps()
    ]
  end

  defp deps do
    []
  end
end
