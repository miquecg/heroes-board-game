defmodule Web.GameControllerTest do
  use HeroesWeb.ConnCase, async: true

  test "GET /game renders header", context do
    conn = get(context.conn, @game)
    assert html_response(conn, 200) =~ "<h1>Heroes Board Game</h1>"
  end

  test "POST /game redirects to inject game token", context do
    conn = post(context.conn, @game)
    assert redirected_to(conn, 303) == @game

    conn =
      conn
      |> recycle()
      |> get(@game)

    assert html_response(conn, 200) =~ ~r/gameToken="[\w-\.]+";/
  end

  test "POST /game fails without a CSRF token", context do
    conn =
      context.conn
      |> get(@game)
      # recycling removes CSRF token
      |> recycle()
      |> put_private(:plug_skip_csrf_protection, false)

    assert_error_sent 403, fn ->
      post(conn, @game)
    end
  end
end
