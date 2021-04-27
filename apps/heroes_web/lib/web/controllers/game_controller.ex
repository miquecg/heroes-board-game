defmodule Web.GameController do
  use HeroesWeb, :controller

  alias Web.{Endpoint, ErrorView}

  plug :authenticate when action in [:index]
  plug :join when action in [:start]

  def index(conn, _params) do
    render(conn, "index.html", board: config(:board))
  end

  def start(conn, _params) do
    if id = conn.assigns[:player_id] do
      delete_csrf_token()

      conn
      |> put_session("player_id", id)
      |> redirect_index()
    else
      conn
      |> put_status(503)
      |> render_error()
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> send_resp(204, "")
  end

  defp authenticate(conn, _opts) do
    if id = get_session(conn, "player_id") do
      token = Phoenix.Token.sign(conn, "player socket", id)

      conn
      |> assign(:game_token, token)
      |> assign(:signed_in?, true)
    else
      assign(conn, :signed_in?, false)
    end
  end

  defp join(conn, _opts) do
    board = config(:board)
    dice = config(:dice)

    case Game.join(board, dice) do
      {:ok, id} -> assign(conn, :player_id, id)
      {:error, :max_heroes} -> conn
    end
  end

  defp config(key), do: Endpoint.config(key)

  defp redirect_index(conn) do
    game_path = Routes.game_path(conn, :index)

    conn
    |> put_status(303)
    |> redirect(to: game_path)
    |> halt()
  end

  defp render_error(conn) do
    conn
    |> put_layout(false)
    |> put_view(ErrorView)
    |> render(:"#{conn.status}")
  end
end
