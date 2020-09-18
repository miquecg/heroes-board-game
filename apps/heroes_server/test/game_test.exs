defmodule GameTest do
  use ExUnit.Case

  alias Game.Hero

  @app :heroes_server

  setup do
    Application.stop(@app)
    :ok = Application.start(@app)
  end

  setup :join

  test "Create and remove hero from the game", %{player_id: id} do
    hero = whereis(id)
    assert Process.alive?(hero)

    ref = monitor_hero(id)
    :ok = Game.remove(id)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}
  end

  test "Game.position/1 returns hero current tile", %{player_id: id} do
    assert {0, 0} = Game.position(id)

    Hero.control({:via, Registry, {Game.Registry, id}}, :up)

    assert {0, 1} = Game.position(id)
  end

  defp monitor_hero(id) do
    id
    |> whereis()
    |> Process.monitor()
  end

  defp whereis(id), do: GenServer.whereis({:via, Registry, {Game.Registry, id}})

  defp join(_context) do
    dice = fn _ -> {0, 0} end
    [player_id: Game.join(GameBoards.Test4x4, dice)]
  end
end
