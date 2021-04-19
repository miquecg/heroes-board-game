import Config

if System.get_env("RELEASE_MODE") do
  config :heroes_web, Web.Endpoint,
    server: true,
    http: [port: System.fetch_env!("PORT")],
    url: [
      scheme: "https",
      host: System.fetch_env!("APP_NAME") <> ".gigalixirapp.com",
      port: 443
    ]
end
