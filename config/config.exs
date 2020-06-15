import Config

config :heroes_web, HeroesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tO1ViyBWg5sM5X9YiBSvkc8re8VEf3bWkJclT2J4zrNtGjispgX145VZzP3nvoRU",
  render_errors: [view: HeroesWeb.ErrorView, accepts: ~w(html), layout: false],
  pubsub_server: HeroesWeb.PubSub

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:application, :tag]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
