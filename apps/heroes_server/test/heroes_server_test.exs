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

    @tag tiles: [{1, 0}, {1, 1}, {2, 2}, {3, 0}]
    test "can attack all enemies at once", %{{1, 1} => hero} = context do
      assert {:ok, :launched} = Hero.control(hero, :attack)
      :timer.sleep(50)
      assert {:ok, {0, 1}} = Hero.control(hero, :left)

      dead_enemy = Map.get(context, {1, 0})
      assert {:error, :noop} = Hero.control(dead_enemy, :up)

      dead_enemy = Map.get(context, {2, 2})
      assert {:error, :noop} = Hero.control(dead_enemy, :left)

      live_enemy = Map.get(context, {3, 0})
      assert {:ok, {3, 1}} = Hero.control(live_enemy, :up)
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
