defmodule Game.HeroTest do
  use ExUnit.Case, async: true

  alias Game.Hero
  alias GameError.BadCommand

  @board_4x4 GameBoards.Test4x4
  @board_4x4_w1 GameBoards.Test4x4w1
  @board_4x4_w2 GameBoards.Test4x4w2

  describe "A hero can move in four directions one tile at a time:" do
    setup :create_hero

    test "go up", %{hero: pid} do
      assert {:ok, {1, 2}} = Hero.control(pid, :up)
    end

    test "go down", %{hero: pid} do
      assert {:ok, {1, 0}} = Hero.control(pid, :down)
    end

    test "go right", %{hero: pid} do
      assert {:ok, {2, 1}} = Hero.control(pid, :right)
    end

    test "go left", %{hero: pid} do
      assert {:ok, {0, 1}} = Hero.control(pid, :left)
    end
  end

  describe "A hero can go anywhere on the board but not crossing walls:" do
    setup do
      [
        tile: {2, 1},
        commands: [:down, :right, :up, :up, :left, :up, :left, :left, :down, :down]
      ]
    end

    setup :create_hero

    test "route without walls", %{hero: pid} = context do
      assert {0, 1} = control(pid, context.commands)
    end

    @tag board: @board_4x4_w1
    test "same route with one wall", %{hero: pid} = context do
      assert {0, 0} = control(pid, context.commands)
    end

    @tag board: @board_4x4_w2
    test "same route with two walls", %{hero: pid} = context do
      assert {2, 0} = control(pid, context.commands)
    end
  end

  describe "A hero can attack all other heroes at the same time." do
    setup :create_hero

    test "Hero kills one of two enemies", %{hero: pid, board: board} do
      opts = [board: board]
      enemy_within_reach = start_supervised!({Hero, [tile: {2, 2}] ++ opts}, id: :enemy_in)
      enemy_out_of_reach = start_supervised!({Hero, [tile: {3, 0}] ++ opts}, id: :enemy_out)

      assert {:ok, :launched} = Hero.control(pid, :attack)
      :timer.sleep(20)

      assert {:error, :noop} = Hero.control(enemy_within_reach, :right)
      assert {:ok, {3, 1}} = Hero.control(enemy_out_of_reach, :up)
    end
  end

  describe "A hero can be killed by an enemy attack within a radius of one tile:" do
    setup :create_hero

    @tag enemy: {0, 0}
    test "attack from {0, 0}", %{hero: pid} = context do
      assert :dead = GenServer.call(pid, {:attack, context.enemy})
    end

    @tag enemy: {0, 2}
    test "attack from {0, 2}", %{hero: pid} = context do
      assert :dead = GenServer.call(pid, {:attack, context.enemy})
    end

    @tag enemy: {1, 1}
    test "attack from {1, 1}", %{hero: pid} = context do
      assert :dead = GenServer.call(pid, {:attack, context.enemy})
    end

    @tag enemy: {1, 3}
    test "attack from {1, 3}", %{hero: pid} = context do
      assert :alive = GenServer.call(pid, {:attack, context.enemy})
    end

    @tag enemy: {2, 1}
    test "attack from {2, 1}", %{hero: pid} = context do
      assert :dead = GenServer.call(pid, {:attack, context.enemy})
    end

    @tag enemy: {3, 1}
    test "two attacks from {3, 1}, hero moving in between", %{hero: pid} = context do
      assert :alive = GenServer.call(pid, {:attack, context.enemy})

      {:ok, {2, 1}} = Hero.control(pid, :right)

      assert :dead = GenServer.call(pid, {:attack, context.enemy})
    end

    @tag enemy: {3, 3}
    test "three attacks from {3, 3}, hero moving in between", %{hero: pid} = context do
      assert :alive = GenServer.call(pid, {:attack, context.enemy})

      {:ok, {2, 1}} = Hero.control(pid, :right)

      assert :alive = GenServer.call(pid, {:attack, context.enemy})

      {:ok, {2, 2}} = Hero.control(pid, :up)

      assert :dead = GenServer.call(pid, {:attack, context.enemy})
    end
  end

  describe "A dead hero" do
    setup :create_hero

    test "remains dead", %{hero: pid} do
      assert :alive = GenServer.call(pid, {:attack, {3, 1}})
      assert :dead = GenServer.call(pid, {:attack, {1, 2}})

      assert :dead = GenServer.call(pid, {:attack, {2, 0}})
    end

    test "cannot perform any action", %{hero: pid} do
      assert :alive = GenServer.call(pid, {:attack, {3, 1}})
      assert :dead = GenServer.call(pid, {:attack, {1, 2}})

      assert {:error, :noop} = Hero.control(pid, :right)
      assert {:error, :noop} = Hero.control(pid, :attack)
    end
  end

  describe "A hero returns error when commands are" do
    setup :create_hero

    test "invalid atoms", %{hero: pid} do
      assert {:error, %BadCommand{}} = Hero.control(pid, :doowap)
    end

    test "converted to strings", %{hero: pid} do
      assert {:error, %BadCommand{}} = Hero.control(pid, "up")
    end

    test "{x, y} points", %{hero: pid} do
      assert {:error, %BadCommand{}} = Hero.control(pid, {1, 2})
    end
  end

  test "Heroes are temporary workers" do
    assert Supervisor.child_spec(Hero, []).restart == :temporary
  end

  defp create_hero(context) do
    board = Map.get(context, :board, @board_4x4)
    tile = Map.get(context, :tile, {1, 1})

    opts = [board: board, tile: tile]
    [hero: start_supervised!({Hero, opts})] ++ opts
  end

  defp control(pid, commands) do
    unwrap = fn cmd ->
      {:ok, result} = Hero.control(pid, cmd)
      result
    end

    Enum.reduce(commands, :acc, fn cmd, _ -> unwrap.(cmd) end)
  end
end
