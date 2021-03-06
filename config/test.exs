import Config

config :heroes_web, Web.Endpoint,
  http: [port: 4002],
  server: true

config :logger,
  handle_sasl_reports: false,
  level: :error

config :wallaby,
  base_url: "http://localhost:4002",
  driver: Wallaby.Chrome,
  js_logger: nil
