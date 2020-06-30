defmodule Web.GameController do
  use HeroesWeb, :controller

  alias Web.Endpoint

  def index(conn, _params) do
    render(conn, "index.html", board: Endpoint.config(:board))
  end
end
