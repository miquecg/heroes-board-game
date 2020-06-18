defmodule HeroesServerTest do
  use ExUnit.Case
  @moduletag :capture_log

  alias Game.{Hero, HeroSupervisor}

  @start_tile {0, 1}

  setup do
    Application.stop(:heroes_server)
    :ok = Application.start(:heroes_server)
  end

  test "HeroesServer.join/0 puts a new Hero on a tile" do
    assert count() == 0
    assert {_, @start_tile} = HeroesServer.join()
    assert count() == 1
  end

  describe "A player controlling a Hero" do
    setup context do
      for tile <- context.tiles, into: %{} do
        hero = create_hero(GameBoards.Test4x4, tile)
        {tile, hero}
      end
    end

    @tag tiles: [{1, 1}, {2, 2}, {3, 0}]
    test "can attack all enemies at once", context do
      hero = Map.get(context, {1, 1})
      enemy_within_reach = Map.get(context, {2, 2})
      enemy_out_of_reach = Map.get(context, {3, 0})

      assert {:ok, :launched} = Hero.control(hero, :attack)
      :timer.sleep(50)

      assert {:error, :noop} = Hero.control(enemy_within_reach, :right)
      assert {:ok, {3, 1}} = Hero.control(enemy_out_of_reach, :up)
      assert {:ok, {0, 1}} = Hero.control(hero, :left)
    end
  end

  defp count do
    %{active: heroes} = DynamicSupervisor.count_children(HeroSupervisor)
    heroes
  end

  defp create_hero(board, tile) do
    child = {Hero, [board: board, tile: tile]}
    {:ok, pid} = DynamicSupervisor.start_child(HeroSupervisor, child)
    pid
  end
end
