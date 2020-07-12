defmodule Web.GameController do
  use HeroesWeb, :controller

  alias Web.Endpoint

  plug :game_state when action in [:index]

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

  defp game_state(conn, _opts) do
    case get_session(conn, "player_id") do
      nil -> assign(conn, :players, [])
      _id -> assign(conn, :players, HeroesServer.players())
    end
  end
end
