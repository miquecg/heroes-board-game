defmodule GameTest do
  use ExUnit.Case

  alias GameError.BadCommand

  @app :heroes_server
  @board GameBoards.Test4x4

  setup do
    Application.stop(@app)
    :ok = Application.start(@app)
  end

  setup :join

  test "Create and remove hero from the game", %{player_id: id} do
    hero = GenServer.whereis({:via, Registry, {Registry.Heroes, id}})
    assert Process.alive?(hero)

    ref = Process.monitor(hero)
    :ok = Game.remove(id)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}
  end

  test "Call Game.remove/1 with non existent hero is safe" do
    :ok = Game.remove("not_a_hero_id")
  end

  test "Move commands", %{player_id: id} do
    assert {1, 2} = play(id, :up)
    assert {2, 2} = play(id, :right)
    assert {2, 1} = play(id, :down)
    assert {1, 1} = play(id, :left)
  end

  test "Release attack and all heroes in range die", %{player_id: attacker} do
    enemy_1 = join({1, 0})
    enemy_2 = join({2, 2})
    enemy_3 = join({3, 0})

    :released = play(attacker, :attack)

    assert {0, 1} = play(attacker, :left)
    assert :dead = play(enemy_1, :up)
    assert :dead = play(enemy_2, :left)
    assert {3, 1} = play(enemy_3, :up)
  end

  test "Game.position/1 returns hero current tile", %{player_id: id} do
    assert {1, 1} = Game.position(id)
    assert {2, 1} = play(id, :right)
    assert {2, 1} = Game.position(id)
  end

  test "Game.position/1 can return an empty tuple" do
    assert {} = Game.position("invalid_player_id")
  end

  describe "Game.play/2 returns {:error, exception} for invalid command" do
    test ":doowap", %{player_id: id} do
      assert %BadCommand{} = play(id, :doowap)
    end

    test ~s("up"), %{player_id: id} do
      assert %BadCommand{} = play(id, "up")
    end

    test "{1, 2}", %{player_id: id} do
      assert %BadCommand{} = play(id, {1, 2})
    end
  end

  defp play(id, cmd) do
    case Game.play(id, cmd) do
      {:ok, result} -> result
      {:error, error} -> error
    end
  end

  defp join({_, _} = tile) do
    {:ok, id} = Game.join(@board, fn _ -> tile end)
    id
  end

  defp join(_context), do: [player_id: join({1, 1})]
end
