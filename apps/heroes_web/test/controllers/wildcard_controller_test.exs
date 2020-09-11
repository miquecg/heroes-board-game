defmodule Web.WildcardControllerTest do
  use HeroesWeb.ConnCase, async: true

  test "/ redirects to /game", context do
    conn = get(context.conn, "/")
    assert redirected_to(conn) == @game
  end

  test "Unknown route raises 404 error", context do
    assert_error_sent 404, fn ->
      get(context.conn, "/not-found")
    end
  end
end
