defmodule Game.BoardTest do
  use ExUnit.Case, async: true
  doctest Game.Board

  @board_3x2 GameBoards.Test3x2
  @board_4x4 GameBoards.Test4x4
  @board_4x4_w2 GameBoards.Test4x4w2

  describe "Rules for movements:" do
    setup %{board: board}, do: [move_fn: &board.play/2]
    setup :set_tile

    @tag tile: {2, 1}
    @tag board: @board_4x4
    test "up, down, left and right move one tile", %{move_fn: move} do
      assert {2, 2} = move.(:up)
      assert {2, 0} = move.(:down)
      assert {1, 1} = move.(:left)
      assert {3, 1} = move.(:right)
    end

    @doc """
    +---+---+---+---+
    |   | ⠀ |   | ⠀ |
    +---+---+---+---+
    |   | W |   | W |
    +---+---+---+---+
    |   |   |   |   |
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
      |   | ⠀ | ✓ | ⠀ |
      +---+---+---+---+
      |   | ⠀ |   |   |
      +---+---+---+---+
      |   |   |   | ✓ | X
      +---+---+---+---+
    X | ✓ |   |   |   |
      +---+---+---+---+
        X
    """
    @tag board: @board_4x4
    test "board limits cannot be crossed", %{move_fn: move} do
      assert {0, 0} = move.({0, 0}, :left)
      assert {0, 0} = move.({0, 0}, :down)

      assert {2, 3} = move.({2, 3}, :up)

      assert {3, 1} = move.({3, 1}, :right)
    end

    @doc """
          X
    +---+---+---+
    |   | ✓ | ✓ |
    +---+---+---+
    |   |   |   |
    +---+---+---+
    """
    @tag board: @board_3x2
    test "board dimensions are interpreted correctly", %{move_fn: move} do
      assert {1, 1} = move.({1, 1}, :up)
      assert {2, 1} = move.({1, 1}, :right)
    end
  end

  defp set_tile(%{tile: tile, move_fn: move}), do: [move_fn: &move.(tile, &1)]
  defp set_tile(_), do: :ok
end
