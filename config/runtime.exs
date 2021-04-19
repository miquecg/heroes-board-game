import Config

config :heroes_web, Web.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [
    scheme: "https",
    host: System.get_env("APP_NAME") <> ".gigalixirapp.com",
    port: 443
  ]
