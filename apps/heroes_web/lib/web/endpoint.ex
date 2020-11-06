defmodule Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :heroes_web

  @session_options [
    store: :cookie,
    key: "_heroes_web_key",
    signing_salt: "+ZZP18W1"
  ]

  socket "/game/socket", Web.PlayerSocket,
    websocket: true,
    longpoll: false

  plug Plug.Static,
    at: "/",
    from: :heroes_web,
    gzip: false,
    only: ~w(css images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Parsers, parsers: [:urlencoded]

  plug Plug.Session, @session_options
  plug Web.Router
end
