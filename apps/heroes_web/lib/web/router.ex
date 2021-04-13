defmodule Web.Router do
  use HeroesWeb, :router

  alias Web.Plugs.Redirect

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  get "/", Redirect, to: "/game"

  scope "/game", Web do
    pipe_through :browser

    get "/", GameController, :index
    post "/start", GameController, :start
    delete "/session", GameController, :logout
  end
end
