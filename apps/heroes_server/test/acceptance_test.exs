defmodule HeroesServer.AcceptanceTest do
  use ExUnit.Case, async: true

  test "When a player joins the game a new hero is placed on a random tile" do
    assert active_heroes() == 0

    Application.put_env(:heroes_server, :board, Board.Test)
    {_, {_x_axis, _y_axis} = tile} = HeroesServer.join()

    assert active_heroes() == 1
    assert tile != {0, 0}
  end

  defp active_heroes() do
    %{active: heroes} = DynamicSupervisor.count_children(Heroes.Supervisor)
    heroes
  end
end
