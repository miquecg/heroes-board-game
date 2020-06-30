defmodule Web.RedirectController do
  use HeroesWeb, :controller

  alias Phoenix.Router.NoRouteError

  def perform(conn, %{"path" => []}) do
    game_path = Routes.game_path(conn, :index)

    conn
    |> redirect(to: game_path)
    |> halt()
  end

  def perform(conn, _) do
    raise NoRouteError, conn: conn, router: Web.Router
  end
end
