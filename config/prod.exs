import Config

config :heroes_web, Web.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
