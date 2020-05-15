defmodule Game.HeroIntegrationTest do
  use ExUnit.Case

  @moduletag :capture_log

  alias Game.{Hero, HeroSupervisor}

  setup do
    Application.stop(:heroes_server)
    :ok = Application.start(:heroes_server)
  end

  test "A hero can attack all enemies at the same time" do
    new_hero = &create_hero(GameBoards.Test4x4, &1)

    hero = new_hero.({1, 1})
    enemy_within_reach = new_hero.({2, 2})
    enemy_out_of_reach = new_hero.({3, 0})

    assert {:ok, :launched} = Hero.control(hero, :attack)
    :timer.sleep(10)

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
