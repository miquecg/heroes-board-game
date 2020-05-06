defmodule Game.BoardTest do
  use ExUnit.Case, async: true
  doctest Game.Board

  alias Game.BoardRange

  @board GameBoards.Test4x4

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
  test "Board limits are respected" do
    refute valid?({-1, 0})
    refute valid?({0, -1})
    refute valid?({2, 4})
    refute valid?({4, 1})

    assert valid?({0, 0})
    assert valid?({2, 3})
    assert valid?({3, 1})
  end

  test "Anything other than a t:Game.Board.tile/0 is invalid" do
    refute valid?({0.5, 1})
    refute valid?({:an_atom, "a string"})
  end

  describe "Attack range from tile" do
    setup %{tile: tile} do
      range = @board.attack_range(tile)
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
  end

  defp valid?(point) do
    @board.valid?(point)
  end
end
