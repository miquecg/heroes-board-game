defmodule Web.WildcardController do
  use HeroesWeb, :controller

  alias Phoenix.Router.NoRouteError

  def route(conn, %{"path" => []}) do
    game_path = Routes.game_path(conn, :index)

    conn
    |> redirect(to: game_path)
    |> halt()
  end

  def route(conn, %{"path" => _}) do
    raise NoRouteError, conn: conn, router: Web.Router
  end
end
