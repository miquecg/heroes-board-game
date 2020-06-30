defmodule Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :heroes_web

  @session_options [
    store: :cookie,
    key: "_heroes_web_key",
    signing_salt: "+ZZP18W1"
  ]

  plug Plug.Static,
    at: "/",
    from: :heroes_web,
    gzip: false,
    only: ~w(css favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Session, @session_options
  plug Web.Router
end
