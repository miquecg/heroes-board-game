import Config

config :esbuild,
  version: "0.13.10",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/images/*),
    cd: Path.expand("../apps/heroes_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :heroes_web, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tO1ViyBWg5sM5X9YiBSvkc8re8VEf3bWkJclT2J4zrNtGjispgX145VZzP3nvoRU",
  render_errors: [view: Web.ErrorView, accepts: ~w(html), layout: false],
  pubsub_server: Web.PubSub

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:application, :tag]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
