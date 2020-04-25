defmodule HeroesServer.AcceptanceTest do
  use ExUnit.Case, async: true

  @start_tile {0, 1}

  test "When a player joins the game a new hero is placed on a tile" do
    assert active_heroes() == 0

    assert {_, @start_tile} = HeroesServer.join()

    assert active_heroes() == 1
  end

  defp active_heroes do
    %{active: heroes} = DynamicSupervisor.count_children(Heroes.Supervisor)
    heroes
  end
end
