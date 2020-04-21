defmodule Board do
  @typedoc """
  A walkable cell on the grid
  """
  @type tile :: {non_neg_integer(), non_neg_integer()}

  @typedoc """
  A cell on the grid where heroes cannot walk in
  """
  @type wall :: tile

  @type board_spec :: %__MODULE__.Spec{
    cols:  pos_integer(),
    rows:  pos_integer(),
    walls: list(wall)
  }

  defmodule Spec do
    @enforce_keys [:cols, :rows, :walls]
    defstruct @enforce_keys
  end

  @doc """
  Converts a `Board.Spec` into a list of tiles.

  ## Example
  +---+---+---+---+
  | w | ⠀ | w | ⠀ |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  | w |   | w | w |
  +---+---+---+---+

      iex> Board.tiles(%Board.Spec{cols: 4, rows: 3, walls: [{0,0},{0,2},{2,0},{2,2},{3,0}]})
      [{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}, {3, 1}, {3, 2}]

  """
  @spec tiles(Spec) :: list(tile)
  def tiles(%Spec{cols: cols, rows: rows, walls: walls}) do
    for x <- 0..cols - 1,
        y <- 0..rows - 1,
        {x, y} not in walls, do: {x, y}
  end
end
