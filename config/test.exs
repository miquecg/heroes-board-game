import Config

config :heroes_server,
  board: GameBoards.Test2x2w1,
  start_tile: :first

config :logger,
  handle_sasl_reports: false,
  level: :warn
