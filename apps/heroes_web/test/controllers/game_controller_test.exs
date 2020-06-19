defmodule HeroesWeb.GameControllerTest do
  use HeroesWeb.ConnCase, async: true

  test "GET /game", %{conn: conn} do
    conn = get(conn, "/game")
    assert html_response(conn, 200) =~ "<h1>Heroes Board Game</h1>"
  end
end
