defmodule Game.BoardRangeTest do
  use ExUnit.Case, async: true

  alias Game.BoardRange

  @board_4x4 GameBoards.Test4x4

  describe "Attack range from tile" do
    setup %{tile: tile} do
      range = @board_4x4.attack_range(tile)
      [member_fn: &BoardRange.member?(range, &1)]
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
