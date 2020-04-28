defmodule Board.Test2x2 do
  @moduledoc """
  Size: 2x2
  Walls: 1
  """

  @board_spec %Board.Spec{
    cols: 2,
    rows: 2,
    walls: [{0, 0}]
  }

  @tiles Board.tiles(@board_spec)

  @doc """
  ## Example
  +---+---+
  |   |   |
  +---+---+
  | W |   |
  +---+---+
  """
  def tiles, do: @tiles

  def move(tiles), do: Board.move(tiles, @board_spec)
end

defmodule Board.Test4x4 do
  @moduledoc """
  Size: 4x4
  Walls: 0
  """

  @board_spec %Board.Spec{
    cols: 4,
    rows: 4,
    walls: []
  }

  @tiles Board.tiles(@board_spec)

  def tiles, do: @tiles

  def move(tiles), do: Board.move(tiles, @board_spec)
end

defmodule Board.Test4x4w1 do
  @moduledoc """
  Size: 4x4
  Walls: 1
  """

  @board_spec %Board.Spec{
    cols: 4,
    rows: 4,
    walls: [{3, 2}]
  }

  @tiles Board.tiles(@board_spec)

  @doc """
  ## Example
  +---+---+---+---+
  |   | ⠀ |   | ⠀ |
  +---+---+---+---+
  |   | ⠀ |   | W |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  """
  def tiles, do: @tiles

  def move(tiles), do: Board.move(tiles, @board_spec)
end

defmodule Board.Test4x4w2 do
  @moduledoc """
  Size: 4x4
  Walls: 2
  """

  @board_spec %Board.Spec{
    cols: 4,
    rows: 4,
    walls: [{1, 2}, {3, 2}]
  }

  @tiles Board.tiles(@board_spec)

  @doc """
  ## Example
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
  def tiles, do: @tiles

  def move(tiles), do: Board.move(tiles, @board_spec)
end
