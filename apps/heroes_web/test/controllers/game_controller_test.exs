defmodule Web.GameControllerTest do
  use HeroesWeb.ConnCase, async: true

  test "GET / redirects to /game", context do
    conn = get(context.conn, "/")
    assert redirected_to(conn) == @game.index
  end

  test "GET /game renders header", context do
    conn = get(context.conn, @game.index)
    assert html_response(conn, 200) =~ "<h1>Heroes Board Game</h1>"
  end

  test "POST /game/start redirects to inject game token", context do
    conn = post(context.conn, @game.start)
    assert redirected_to(conn, 303) == @game.index

    conn =
      conn
      |> recycle()
      |> get(@game.index)

    assert html_response(conn, 200) =~ ~r/gameToken="[\w-\.]+";/
  end

  test "POST /game/start fails without a CSRF token", context do
    conn =
      context.conn
      |> get(@game.index)
      # recycling removes CSRF token
      |> recycle()
      |> put_private(:plug_skip_csrf_protection, false)

    assert_error_sent 403, fn ->
      post(conn, @game.start)
    end
  end
end
