defmodule HeroesServer.AcceptanceTest do
  use ExUnit.Case, async: true

  test "When a player joins the game a new hero is placed on a tile" do
    assert active_heroes() == 0

    {_, tile} = HeroesServer.join()

    assert active_heroes() == 1
    assert tile == {0, 1}
  end

  defp active_heroes do
    %{active: heroes} = DynamicSupervisor.count_children(Heroes.Supervisor)
    heroes
  end
end
