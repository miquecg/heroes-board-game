import Config

config :heroes_web, HeroesWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :heroes_web, HeroesWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/heroes_web/(live|views)/.*(ex)$",
      ~r"lib/heroes_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console,
  format: "[$level] $message\n"

config :phoenix, :plug_init_mode, :runtime

config :phoenix, :stacktrace_depth, 20
