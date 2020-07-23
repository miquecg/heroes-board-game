defmodule Web.GameController do
  use HeroesWeb, :controller

  alias Web.Endpoint

  plug :get_players when action in [:index]

  def index(conn, _params) do
    render(conn, "index.html", board: Endpoint.config(:board))
  end

  def start(conn, _params) do
    delete_csrf_token()

    id = HeroesServer.join()
    game_path = Routes.game_path(conn, :index)

    conn
    |> put_session("player_id", id)
    |> put_status(303)
    |> redirect(to: game_path)
    |> halt()
  end

  defp get_players(conn, _opts) do
    if get_session(conn, "player_id") do
      assign(conn, :players, HeroesServer.players())
    else
      conn
    end
  end
end
