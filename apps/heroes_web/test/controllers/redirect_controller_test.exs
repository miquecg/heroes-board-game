defmodule HeroesWeb.RedirectControllerTest do
  use HeroesWeb.ConnCase, async: true

  test "Web root redirects to /game", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn, 302) == Routes.game_path(conn, :index)
  end

  test "404 error on routes other than /game", %{conn: conn} do
    assert_error_sent 404, fn ->
      get(conn, "/not-found")
    end
  end
end
