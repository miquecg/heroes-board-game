defmodule Game.BoardTest do
  use ExUnit.Case, async: true
  doctest Game.Board

  alias Game.BoardRange

  @board_3x2 GameBoards.Test3x2
  @board_4x4 GameBoards.Test4x4
  @board_4x4_w2 GameBoards.Test4x4w2

  describe "Rules for movements:" do
    setup %{board: board}, do: [move_fn: &board.move/2]
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

  describe "Tiles on edges when board is" do
    setup %{board: board} do
      [check_fn: &board.valid?/1]
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
    test "symmetric", %{check_fn: valid?} do
      refute valid?.({-1, 0})
      refute valid?.({0, -1})
      refute valid?.({2, 4})
      refute valid?.({4, 1})

      assert valid?.({0, 0})
      assert valid?.({2, 3})
      assert valid?.({3, 1})
    end

    @doc """
      X
    +---+---+---+
    | ✓ |   |   |
    +---+---+---+
    |   |   | ✓ | X
    +---+---+---+
    """
    @tag board: @board_3x2
    test "asymmetric", %{check_fn: valid?} do
      assert valid?.({0, 1})
      refute valid?.({0, 2})

      assert valid?.({2, 0})
      refute valid?.({3, 0})
    end
  end

  describe "Attack range from tile" do
    setup %{tile: tile} do
      range = @board_4x4.attack_range(tile)
      [member_fn: fn point -> BoardRange.member?(range, point) end]
    end

    @doc """
    +---+---+---+---+
    | X | ⠀ | ⠀ | X |
    +---+---+---+---+
    | ✓ | ⠀ | ✓ |   |
    +---+---+---+---+
    |   | ✓ | ✓ | X |
    +---+---+---+---+
    | ✓ |   |   |   |
    +---+---+---+---+
    """
    @tag tile: {1, 1}
    test "{1, 1}", %{member_fn: in_range?} do
      assert in_range?.({0, 0})
      assert in_range?.({1, 1})
      assert in_range?.({2, 2})
      refute in_range?.({3, 3})

      assert in_range?.({2, 1})
      refute in_range?.({3, 1})

      assert in_range?.({0, 2})
      refute in_range?.({0, 3})
    end

    @doc """
                  X
    +---+---+---+---+
    | ⠀ | X | ✓ | ✓ |
    +---+---+---+---+
    | ⠀ | ⠀ | ✓ | ✓ |
    +---+---+---+---+
    |   |   |   | X |
    +---+---+---+---+
    |   |   |   |   |
    +---+---+---+---+
    """
    @tag tile: {3, 3}
    test "{3, 3}", %{member_fn: in_range?} do
      assert in_range?.({2, 2})
      assert in_range?.({2, 3})
      assert in_range?.({3, 2})
      assert in_range?.({3, 3})

      refute in_range?.({1, 3})
      refute in_range?.({3, 1})
      refute in_range?.({3, 4})
    end
  end

  defp set_tile(%{tile: tile, move_fn: move}), do: [move_fn: &move.(tile, &1)]
  defp set_tile(_), do: :ok
end
