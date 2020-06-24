defmodule HeroesWeb.GameControllerTest do
  use HeroesWeb.ConnCase, async: true

  @game Routes.game_path(@endpoint, :index)

  test "GET game endpoint", %{conn: conn} do
    conn = get(conn, @game)
    assert html_response(conn, 200) =~ "<h1>Heroes Board Game</h1>"
  end
end
