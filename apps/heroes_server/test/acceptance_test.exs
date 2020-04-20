defmodule HeroesServer.AcceptanceTest do
  use ExUnit.Case, async: true

  test "When a player joins the game a new hero is placed on a random walkable tile" do
    assert active_heroes() == 0

    Application.put_env(:heroes_server, :board, two_cols_one_row())
    {_, {x_axis, y_axis} = _tile} = HeroesServer.join()

    assert active_heroes() == 1
    assert x_axis == 1
    assert y_axis == 0
  end

  defp active_heroes() do
    %{active: heroes} = DynamicSupervisor.count_children(Heroes.Supervisor)
    heroes
  end

  defp two_cols_one_row() do
    %Board.Spec{
      cols:  2,
      rows:  1,
      walls: [{0,0}]
    }
  end
end
