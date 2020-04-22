defmodule Board.Test do
  @moduledoc false

  @board_spec %Board.Spec{
    cols: 2,
    rows: 2,
    walls: [{0, 0}]
  }

  @tiles Board.tiles(@board_spec)

  def tiles, do: @tiles
end
