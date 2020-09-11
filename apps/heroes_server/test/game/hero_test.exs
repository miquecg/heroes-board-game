defmodule Game.HeroTest do
  use ExUnit.Case, async: true

  alias Game.{Hero, HeroServer}
  alias GameError.BadCommand

  @board_4x4 GameBoards.Test4x4
  @board_4x4_w1 GameBoards.Test4x4w1
  @board_4x4_w2 GameBoards.Test4x4w2

  setup :create_hero

  describe "Hero can move" do
    test "up", context do
      assert {1, 2} = control(context.hero, :up)
    end

    test "down", context do
      assert {1, 0} = control(context.hero, :down)
    end

    test "right", context do
      assert {2, 1} = control(context.hero, :right)
    end

    test "left", context do
      assert {0, 1} = control(context.hero, :left)
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
      attack(hero, from)
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
  end

  @tag from: {3, 3}
  test "Attacks to different targets from {3, 3}", %{hero: hero, from: from} do
    attack(hero, from)

    assert alive?(hero)

    {2, 1} = control(hero, :right)
    attack(hero, from)

    assert alive?(hero)

    {2, 2} = control(hero, :up)
    attack(hero, from)

    refute alive?(hero)
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

      assert :noop = control(hero, :right)
      assert :noop = control(hero, :attack)
    end
  end

  describe "Hero client returns {:error, exception} for invalid input" do
    test ":doowap", context do
      assert %BadCommand{} = control(context.hero, :doowap)
    end

    test ~s("up"), context do
      assert %BadCommand{} = control(context.hero, "up")
    end

    test "{1, 2}", context do
      assert %BadCommand{} = control(context.hero, {1, 2})
    end
  end

  test "Get current hero position", %{hero: hero} do
    {1, 2} = control(hero, :up)

    assert {1, 2} = Hero.position(hero)

    {0, 2} = control(hero, :left)
    {0, 1} = control(hero, :down)

    assert {0, 1} = Hero.position(hero)
  end

  defp create_hero(context) do
    board = Map.get(context, :board, @board_4x4)
    tile = Map.get(context, :tile, {1, 1})

    opts = [board: board, tile: tile]
    [hero: start_supervised!({HeroServer, opts})]
  end

  defp control(hero, commands) do
    unwrap = fn cmd ->
      case Hero.control(hero, cmd) do
        {:ok, result} -> result
        {:error, error} -> error
      end
    end

    commands
    |> List.wrap()
    |> Enum.reduce(:acc, fn cmd, _ -> unwrap.(cmd) end)
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
