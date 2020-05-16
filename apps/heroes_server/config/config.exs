import Config

config :logger,
  handle_sasl_reports: true

config :logger, :console,
  level: :warn,
  metadata: [:tag, :mfa, :file, :line]

config :heroes_server, []

if Mix.env() == :test, do: import_config("test.exs")
