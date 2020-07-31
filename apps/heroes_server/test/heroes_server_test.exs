defmodule HeroesServerTest do
  use ExUnit.Case

  alias Game.{Hero, HeroSupervisor}

  @app :heroes_server

  setup do
    Application.stop(@app)
    :ok = Application.start(@app)
  end

  test "When a player joins the server a hero is created and registered" do
    opts = [board_mod: GameBoards.Test2x2w1, player_start: :first_tile]
    server = start_supervised!({HeroesServer, [name: :test_server] ++ opts})

    assert count_heroes() == 0

    id = GenServer.call(server, :join)
    server = {:via, Registry, {HeroesServer.Registry, id}}

    assert count_heroes() == 1
    assert {0, 1} = Hero.position(server)
  end

  describe "A player controlling a hero" do
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

  defp count_heroes, do: Registry.count(HeroesServer.Registry)

  defp create_hero(board, tile) do
    child = {Hero, [board: board, tile: tile]}
    {:ok, pid} = DynamicSupervisor.start_child(HeroSupervisor, child)
    pid
  end
end
