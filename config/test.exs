import Config

config :heroes_server,
  board: GameBoards.Test2x2w1,
  start_tile: :first

config :heroes_web, HeroesWeb.Endpoint,
  http: [port: 4002],
  server: true

config :logger,
  handle_sasl_reports: false,
  level: :warn

config :wallaby,
  base_url: "http://localhost:4002",
  driver: Wallaby.Chrome
