defmodule Board.Test do
  @board_spec %Board.Spec{
    cols:  2,
    rows:  1,
    walls: [{0,0}]
  }

  @tiles Board.tiles(@board_spec)

  def tiles(), do: @tiles
end
