defmodule Web.Router do
  use HeroesWeb, :router

  alias Web.Plugs.Redirect

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Web do
    pipe_through :browser

    get "/game", GameController, :index
    post "/game/start", GameController, :start
  end

  get "/", Redirect, to: "/game"
end
