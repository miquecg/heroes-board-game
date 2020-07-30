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

    conn = get(recycle(conn), @game)
    token_regex = ~r/gameToken="[\w-\.]+";/
    assert html_response(conn, 200) =~ token_regex
  end

  test "POST request fails without a CSRF token", %{conn: conn} do
    conn =
      conn
      |> create_session()
      |> recycle()
      |> put_private(:plug_skip_csrf_protection, false)

    assert_error_sent 403, fn ->
      post(conn, @game)
    end
  end

  defp create_session(conn), do: get(conn, @game)
end
