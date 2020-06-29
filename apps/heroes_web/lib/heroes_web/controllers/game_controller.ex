defmodule HeroesWeb.GameController do
  use HeroesWeb, :controller

  alias HeroesWeb.Endpoint

  def index(conn, _params) do
    render(conn, "index.html", board: Endpoint.config(:board))
  end
end
