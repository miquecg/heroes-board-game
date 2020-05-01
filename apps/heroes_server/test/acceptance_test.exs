defmodule HeroesServer.AcceptanceTest do
  use ExUnit.Case, async: true

  @board_4x4 Board.Test4x4
  @board_4x4_w1 Board.Test4x4w1
  @board_4x4_w2 Board.Test4x4w2

  test "When a player joins the game a new hero is placed on a tile" do
    start_tile = {0, 1}

    assert count() == 0
    assert {_, ^start_tile} = HeroesServer.join()
    assert count() == 1
  end

  test "A player can move the hero to any tile but not crossing walls" do
    opts = [tile: {2, 1}]
    movements = [:down, :right, :up, :up, :left, :up, :left, :left, :down, :down]

    hero_1 = create(:hero_1, opts ++ [board: @board_4x4])
    hero_2 = create(:hero_2, opts ++ [board: @board_4x4_w1])
    hero_3 = create(:hero_3, opts ++ [board: @board_4x4_w2])

    assert {0, 1} = control(hero_1, movements)
    assert {0, 0} = control(hero_2, movements)
    assert {2, 0} = control(hero_3, movements)
  end

  test "Heroes are temporary workers" do
    assert Supervisor.child_spec(Hero, []).restart == :temporary
  end

  defp count do
    %{active: heroes} = DynamicSupervisor.count_children(Heroes.Supervisor)
    heroes
  end

  defp create(id, opts), do: start_supervised!({Hero, opts}, id: id)

  defp control(pid, commands) do
    unwrap = fn cmd ->
      {:ok, result} = Hero.control(pid, cmd)
      result
    end

    Enum.reduce(commands, :acc, fn cmd, _ -> unwrap.(cmd) end)
  end
end
