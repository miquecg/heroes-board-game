defmodule HeroesServerTest do
  use ExUnit.Case, async: true

  @start_tile {0, 1}

  test "HeroesServer.join/0 puts a new Hero on a tile" do
    assert count() == 0
    assert {_, @start_tile} = HeroesServer.join()
    assert count() == 1
  end

  defp count do
    %{active: heroes} = DynamicSupervisor.count_children(Game.Supervisor)
    heroes
  end
end
