defmodule Game.HeroTest do
  use ExUnit.Case, async: true

  alias Game.Hero

  @board_4x4 GameBoards.Test4x4
  @board_4x4_w1 GameBoards.Test4x4w1
  @board_4x4_w2 GameBoards.Test4x4w2

  setup :create_hero

  describe "Hero can move" do
    test "up", %{hero: hero} do
      assert {1, 2} = control(hero, :up)
    end

    test "down", %{hero: hero} do
      assert {1, 0} = control(hero, :down)
    end

    test "right", %{hero: hero} do
      assert {2, 1} = control(hero, :right)
    end

    test "left", %{hero: hero} do
      assert {0, 1} = control(hero, :left)
    end
  end

  describe "A series of movements on a map" do
    @describetag tile: {2, 1}

    setup do
      [
        route: [:down, :right, :up, :up, :left, :up, :left, :left, :down, :down]
      ]
    end

    test "without walls", %{hero: hero, route: commands} do
      assert {0, 1} = control(hero, commands)
    end

    @tag board: @board_4x4_w1
    test "with one wall", %{hero: hero, route: commands} do
      assert {0, 0} = control(hero, commands)
    end

    @tag board: @board_4x4_w2
    test "with two walls", %{hero: hero, route: commands} do
      assert {2, 0} = control(hero, commands)
    end
  end

  describe "Hero in {1, 1} being attacked from" do
    setup %{hero: hero, from: from} do
      ref = Process.monitor(hero)
      attack(hero, from)

      [monitor_ref: ref]
    end

    @tag from: {0, 0}
    test "{0, 0}", %{monitor_ref: ref} do
      assert_receive {:DOWN, ^ref, :process, _pid, _reason}
    end

    @tag from: {0, 2}
    test "{0, 2}", %{monitor_ref: ref} do
      assert_receive {:DOWN, ^ref, :process, _pid, _reason}
    end

    @tag from: {1, 1}
    test "{1, 1}", %{monitor_ref: ref} do
      assert_receive {:DOWN, ^ref, :process, _pid, _reason}
    end

    @tag from: {1, 3}
    test "{1, 3}", %{hero: hero} do
      assert {0, 1} = control(hero, :left)
    end

    @tag from: {2, 1}
    test "{2, 1}", %{monitor_ref: ref} do
      assert_receive {:DOWN, ^ref, :process, _pid, _reason}
    end
  end

  @tag from: {3, 3}
  test "Attacks to different targets from {3, 3}", %{hero: hero, from: from} do
    attack(hero, from)
    {2, 1} = control(hero, :right)

    attack(hero, from)
    {2, 2} = control(hero, :up)

    attack(hero, from)
    catch_exit(control(hero, :up))
  end

  test "Restart strategy is :transient so heroes can be stopped" do
    assert %{restart: :transient} = Hero.child_spec([])
  end

  defp control(hero, commands) do
    attack = fn _, _ -> :ok end
    update = fn _ -> :ok end

    commands
    |> List.wrap()
    |> Enum.reduce(:acc, fn
      :attack, _ -> GenServer.call(hero, {:attack, attack})
      move, _ -> GenServer.call(hero, {move, update})
    end)
  end

  defp attack(hero, from), do: send(hero, {:fire, from})

  defp create_hero(context) do
    board = Map.get(context, :board, @board_4x4)
    tile = Map.get(context, :tile, {1, 1})
    opts = [board: board, tile: tile]

    [hero: start_supervised!({Hero, opts})]
  end
end
