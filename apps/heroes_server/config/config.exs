import Config

config :heroes_server, []

if Mix.env() == :test, do: import_config("test.exs")
