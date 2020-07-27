defmodule Web.GameController do
  use HeroesWeb, :controller

  alias Web.Endpoint

  plug :authenticate when action in [:index]
  plug :put_game_token when action in [:index]

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

  defp authenticate(conn, _opts) do
    if id = get_session(conn, "player_id") do
      conn
      |> assign(:signed_in?, true)
      |> assign(:player_id, id)
    else
      assign(conn, :signed_in?, false)
    end
  end

  defp put_game_token(conn, _opts) do
    if id = conn.assigns[:player_id] do
      token = Phoenix.Token.sign(conn, "player socket", id)
      assign(conn, :game_token, token)
    else
      conn
    end
  end
end
