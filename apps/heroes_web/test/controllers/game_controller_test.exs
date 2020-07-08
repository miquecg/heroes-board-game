defmodule Web.GameControllerTest do
  use HeroesWeb.ConnCase, async: true

  @game Routes.game_path(@endpoint, :index)

  test "GET the game board", %{conn: conn} do
    conn = get(conn, @game)
    assert html_response(conn, 200) =~ "<h1>Heroes Board Game</h1>"
  end

  test "POST to start the game is followed by a redirect", %{conn: conn} do
    conn = post(conn, @game)
    assert redirected_to(conn, 303) == @game
  end

  test "game endpoint is CSRF protected", %{conn: conn} do
    assert_error_sent 403, fn ->
      conn
      |> put_private(:plug_skip_csrf_protection, false)
      |> post(@game)
    end
  end
end
