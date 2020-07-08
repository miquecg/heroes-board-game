defmodule Web.GameController do
  use HeroesWeb, :controller

  alias Web.Endpoint

  plug :player_state when action in [:index]

  def index(conn, _params) do
    render(conn, "index.html", board: Endpoint.config(:board))
  end

  def start(conn, _params) do
    delete_csrf_token()

    {id, tile} = HeroesServer.join()
    game_path = Routes.game_path(conn, :index)

    conn
    |> put_session("player", %{id: id, tile: tile})
    |> put_status(303)
    |> redirect(to: game_path)
    |> halt()
  end

  defp player_state(conn, _opts) do
    state = get_session(conn, "player")
    assign(conn, :player, state)
  end
end
