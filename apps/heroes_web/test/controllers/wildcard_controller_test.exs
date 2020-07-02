defmodule Web.WildcardControllerTest do
  use HeroesWeb.ConnCase, async: true

  @game Routes.game_path(@endpoint, :index)

  test "Web root redirects to game", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn) == @game
  end

  test "Unknown route raises 404 error", %{conn: conn} do
    assert_error_sent 404, fn ->
      get(conn, "/not-found")
    end
  end
end
