defmodule BoardTest do
  use ExUnit.Case, async: true
  doctest Board

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

  test "Anything other than a t:Board.tile/0 is invalid" do
    refute valid?({0.5, 1})
    refute valid?({:an_atom, "a string"})
  end

  defp valid?(point) do
    Board.Test4x4.valid?(point)
  end
end
