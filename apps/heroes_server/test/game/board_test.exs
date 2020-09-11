defmodule Game.BoardTest do
  use ExUnit.Case, async: true

  alias Game.Board
  alias GameError.BadSize

  @board_3x2 GameBoards.Test3x2
  @board_4x3_w5 GameBoards.Test4x3w5
  @board_4x4 GameBoards.Test4x4
  @board_4x4_w2 GameBoards.Test4x4w2

  test "Board struct creation with required and optional parameters" do
    board_2x5_blank = Board.new(cols: 2, rows: 5)
    board_2x5_walls = Board.new(cols: 2, rows: 5, walls: [{0, 0}, {1, 4}])

    assert %Board{} = board_2x5_blank
    assert %Board{} = board_2x5_walls

    refute board_2x5_blank == board_2x5_walls
  end

  test "Board struct without required options raises KeyError" do
    assert_raise KeyError, fn ->
      Board.new(rows: 3)
    end

    assert_raise KeyError, fn ->
      Board.new(cols: 1, walls: [])
    end
  end

  test "Board struct with invalid dimensions raises BadSize" do
    assert_raise BadSize, fn ->
      Board.new(cols: 3, rows: -1)
    end

    assert_raise BadSize, fn ->
      Board.new(cols: 0, rows: 2)
    end

    assert_raise BadSize, fn ->
      Board.new(cols: 4, rows: 5.0)
    end
  end

  test "Tile generation on a 3x2 board without walls" do
    assert_tiles(@board_3x2, [{0, 0}, {0, 1}, {1, 0}, {1, 1}, {2, 0}, {2, 1}])
  end

  test "Tile generation on a 4x3 board with 5 walls" do
    assert_tiles(@board_4x3_w5, [{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}, {3, 1}, {3, 2}])
  end

  describe "Board rules:" do
    setup %{board: board} do
      [move_fn: &board.play/2]
    end

    @tag board: @board_4x4
    test "up, down, left and right move one tile", %{move_fn: move} do
      assert {2, 2} = move.({2, 1}, :up)
      assert {2, 0} = move.({2, 1}, :down)
      assert {1, 1} = move.({2, 1}, :left)
      assert {3, 1} = move.({2, 1}, :right)
    end

    @doc """
    +---+---+---+---+
    |   | H |   | ⠀ |
    +---+---+---+---+
    |   | W | H | W |
    +---+---+---+---+
    |   | H |   |   |
    +---+---+---+---+
    |   |   |   |   |
    +---+---+---+---+
    """
    @tag board: @board_4x4_w2
    test "a wall cannot be crossed from any side", %{move_fn: move} do
      assert {1, 1} = move.({1, 1}, :up)
      assert {1, 3} = move.({1, 3}, :down)
      assert {2, 2} = move.({2, 2}, :left)
      assert {2, 2} = move.({2, 2}, :right)
    end

    @doc """
                X
      +---+---+---+---+
      |   | ⠀ | H | ⠀ |
      +---+---+---+---+
      |   | ⠀ |   |   |
      +---+---+---+---+
      |   |   |   | H | X
      +---+---+---+---+
    X | H |   |   |   |
      +---+---+---+---+
        X
    """
    @tag board: @board_4x4
    test "limits cannot be crossed", %{move_fn: move} do
      assert {0, 0} = move.({0, 0}, :left)
      assert {0, 0} = move.({0, 0}, :down)

      assert {2, 3} = move.({2, 3}, :up)

      assert {3, 1} = move.({3, 1}, :right)
    end
  end

  @doc """
  +---+---+---+---+
  |   | X | ⠀ | X |
  +---+---+---+---+
  | ✓ | ✓ |   |   |
  +---+---+---+---+
  |   | H | ✓ | X |
  +---+---+---+---+
  | ✓ |   |   |   |
  +---+---+---+---+
  """
  test "Attack distance spans one tile on every direction" do
    attack_distance? = &Board.attack_distance?({1, 1}, &1)

    assert attack_distance?.({0, 0})
    assert attack_distance?.({0, 2})
    assert attack_distance?.({1, 1})
    assert attack_distance?.({1, 2})
    assert attack_distance?.({2, 1})

    refute attack_distance?.({1, 3})
    refute attack_distance?.({3, 1})
    refute attack_distance?.({3, 3})
  end

  defp assert_tiles(board, expected) do
    tiles = board.tiles()
    assert Enum.sort(tiles) == Enum.sort(expected)
  end
end
