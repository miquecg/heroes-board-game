defmodule HeroesWeb.PageControllerTest do
  use HeroesWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Coming soon..."
  end
end
