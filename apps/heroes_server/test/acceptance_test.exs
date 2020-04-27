defmodule HeroesServer.AcceptanceTest do
  use ExUnit.Case, async: true

  test "When a player joins the game a new hero is placed on a tile" do
    start_tile = {0, 1}

    assert active_heroes() == 0
    assert {_, ^start_tile} = HeroesServer.join()
    assert active_heroes() == 1
  end

  test "A player can move the hero to any tile but not crossing walls" do
    opts = [tile: {2, 1}]
    movements = [:down, :right, :up, :up, :left, :up, :left, :left, :down, :down]

    hero_1 = create_hero(:hero_1, opts ++ [board: Board.Test4x4])
    hero_2 = create_hero(:hero_2, opts ++ [board: Board.Test4x4w1])
    hero_3 = create_hero(:hero_3, opts ++ [board: Board.Test4x4w2])

    assert {0, 1} = control(hero_1, movements)
    assert {0, 0} = control(hero_2, movements)
    assert {2, 0} = control(hero_3, movements)
  end

  defp active_heroes do
    %{active: heroes} = DynamicSupervisor.count_children(Heroes.Supervisor)
    heroes
  end

  defp create_hero(id, opts), do: start_supervised!({Hero, opts}, id: id)

  defp control(pid, commands) do
    Enum.reduce(commands, fn cmd, _ -> Hero.control(pid, cmd) end)
  end
end
