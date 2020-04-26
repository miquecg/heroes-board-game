defmodule HeroesServer.AcceptanceTest do
  use ExUnit.Case, async: true

  test "When a player joins the game a new hero is placed on a tile" do
    start_tile = {0, 1}

    assert active_heroes() == 0
    assert {_, ^start_tile} = HeroesServer.join()
    assert active_heroes() == 1
  end

  test "A player can move the hero to any tile but not crossing walls" do
    start_tile = {2, 1}
    movements = [:down, :right, :up, :up, :left, :up, :left, :left, :down, :down]

    hero = start_supervised!({Hero, tile: start_tile, board: Board.Test4x4})
    final_tile = move_hero(hero, movements)

    assert final_tile == {0, 1}
  end

  defp active_heroes do
    %{active: heroes} = DynamicSupervisor.count_children(Heroes.Supervisor)
    heroes
  end

  defp move_hero(pid, movements) do
    Enum.reduce(movements, fn cmd, _ -> Hero.move(pid, cmd) end)
  end
end
