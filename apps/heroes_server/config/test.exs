import Config

config :logger,
  handle_sasl_reports: false

config :logger, :console, level: :info

config :heroes_server,
  board: GameBoards.Test2x2,
  start_tile: :first
