defmodule Game.HeroTest do
  use ExUnit.Case, async: true

  alias Game.{Hero, HeroServer}
  alias GameError.BadCommand

  @board_4x4 GameBoards.Test4x4
  @board_4x4_w1 GameBoards.Test4x4w1
  @board_4x4_w2 GameBoards.Test4x4w2

  setup :create_hero

  describe "A hero can move in four directions one tile at a time:" do
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
    @describetag tile: {2, 1}

    setup do
      [
        commands: [:down, :right, :up, :up, :left, :up, :left, :left, :down, :down]
      ]
    end

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

  describe "A hero can be killed within a radius of one tile: attack from" do
    setup context do
      attack(context.hero, context.from)
      :ok
    end

    @tag from: {0, 0}
    test "{0, 0}", context do
      refute alive?(context.hero)
    end

    @tag from: {0, 2}
    test "{0, 2}", context do
      refute alive?(context.hero)
    end

    @tag from: {1, 1}
    test "{1, 1}", context do
      refute alive?(context.hero)
    end

    @tag from: {1, 3}
    test "{1, 3}", context do
      assert alive?(context.hero)
    end

    @tag from: {2, 1}
    test "{2, 1}", context do
      refute alive?(context.hero)
    end

    @tag from: {3, 1}
    test "{3, 1} to different targets", %{hero: hero, from: from} do
      assert alive?(hero)

      {:ok, {2, 1}} = Hero.control(hero, :right)
      attack(hero, from)

      refute alive?(hero)
    end

    @tag from: {3, 3}
    test "{3, 3} to different targets", %{hero: hero, from: from} do
      assert alive?(hero)

      {:ok, {2, 1}} = Hero.control(hero, :right)
      attack(hero, from)

      assert alive?(hero)

      {:ok, {2, 2}} = Hero.control(hero, :up)
      attack(hero, from)

      refute alive?(hero)
    end
  end

  describe "A dead hero" do
    setup context do
      attack(context.hero, {1, 2})
      :ok
    end

    test "does not come back from the dead", %{hero: hero} do
      refute alive?(hero)

      attack(hero, {3, 0})

      refute alive?(hero)
    end

    test "cannot move or attack other heroes", %{hero: hero} do
      refute alive?(hero)

      assert {:error, :noop} = Hero.control(hero, :right)
      assert {:error, :noop} = Hero.control(hero, :attack)
    end
  end

  describe "A hero returns error when commands are" do
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

  test "Get current hero position", %{hero: hero} do
    {:ok, {1, 2}} = Hero.control(hero, :up)

    assert {1, 2} = Hero.position(hero)

    {:ok, {0, 2}} = Hero.control(hero, :left)
    {:ok, {0, 1}} = Hero.control(hero, :down)

    assert {0, 1} = Hero.position(hero)
  end

  defp create_hero(context) do
    board = Map.get(context, :board, @board_4x4)
    tile = Map.get(context, :tile, {1, 1})

    opts = [board: board, tile: tile]
    [hero: start_supervised!({HeroServer, opts})]
  end

  defp control(pid, commands) do
    unwrap = fn cmd ->
      {:ok, result} = Hero.control(pid, cmd)
      result
    end

    Enum.reduce(commands, :acc, fn cmd, _ -> unwrap.(cmd) end)
  end

  defp attack(hero, from), do: send(hero, {:fire, from})

  defp alive?(hero) do
    state = :sys.get_state(hero)
    state.alive
  end
end

defmodule Game.HeroTestSync do
  use ExUnit.Case

  alias Game.{Hero, HeroServer, HeroSupervisor}

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

  defp create_hero(board, tile) do
    child = {HeroServer, [board: board, tile: tile]}
    {:ok, pid} = DynamicSupervisor.start_child(HeroSupervisor, child)
    pid
  end
end
