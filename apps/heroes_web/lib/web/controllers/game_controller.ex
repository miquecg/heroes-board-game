defmodule Web.GameController do
  use HeroesWeb, :controller

  alias Web.Endpoint

  def index(conn, _params) do
    render(conn, "index.html", board: Endpoint.config(:board))
  end

  def start(conn, _params) do
    delete_csrf_token()
    game_path = Routes.game_path(conn, :index)

    conn
    |> put_status(303)
    |> redirect(to: game_path)
    |> halt()
  end
end
