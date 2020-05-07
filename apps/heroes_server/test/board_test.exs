defmodule Game.BoardTest do
  use ExUnit.Case, async: true
  doctest Game.Board

  alias Game.BoardRange

  @board_3x2 GameBoards.Test3x2
  @board_4x4 GameBoards.Test4x4

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
end
