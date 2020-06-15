defmodule HeroesWeb.Router do
  use HeroesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", HeroesWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
