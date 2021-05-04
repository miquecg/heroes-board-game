defmodule HeroesGame.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      apps: [:heroes_server, :heroes_web],
      version: "0.1.0",
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_local_path: "priv/plts",
        flags: dialyzer_flags()
      ],
      releases: [
        web: [
          applications: [
            runtime_tools: :load,
            heroes_cluster: :permanent,
            heroes_web: :permanent
          ],
          version: {:from_app, :heroes_web},
          include_executables_for: [:unix]
        ]
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
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:heroes_cluster, path: "apps/heroes_cluster", only: :prod, runtime: false}
    ]
  end

  defp dialyzer_flags do
    [
      :unmatched_returns,
      :error_handling,
      :race_conditions,
      :underspecs
    ]
  end
end
