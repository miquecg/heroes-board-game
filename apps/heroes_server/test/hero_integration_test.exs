defmodule Game.HeroIntegrationTest do
  use ExUnit.Case

  @moduletag :capture_log

  alias Game.{Hero, HeroSupervisor}

  setup do
    Application.stop(:heroes_server)
    :ok = Application.start(:heroes_server)
  end

  setup context do
    for tile <- context.tiles, into: %{} do
      hero = create_hero(GameBoards.Test4x4, tile)
      {tile, hero}
    end
  end

  @tag tiles: [{1, 1}, {2, 2}, {3, 0}]
  test "A hero can attack all enemies at the same time", context do
    hero = Map.get(context, {1, 1})
    enemy_within_reach = Map.get(context, {2, 2})
    enemy_out_of_reach = Map.get(context, {3, 0})

    assert {:ok, :launched} = Hero.control(hero, :attack)
    :timer.sleep(50)

    assert {:error, :noop} = Hero.control(enemy_within_reach, :right)
    assert {:ok, {3, 1}} = Hero.control(enemy_out_of_reach, :up)
    assert {:ok, {0, 1}} = Hero.control(hero, :left)
  end

  defp create_hero(board, tile) do
    child = {Hero, [board: board, tile: tile]}
    {:ok, pid} = DynamicSupervisor.start_child(HeroSupervisor, child)
    pid
  end
end
