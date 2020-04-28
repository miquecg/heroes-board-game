defmodule Board do
  @moduledoc """
  Utility functions to manipulate `Board.Spec` structs and tiles.
  """

  defmodule Spec do
    @moduledoc false

    @typedoc """
    Walkable cell on the grid
    """
    @type tile :: {non_neg_integer(), non_neg_integer()}

    @typedoc """
    Cell where heroes cannot walk in
    """
    @type wall :: tile

    @typedoc """
    A board is modeled by its:
    - `cols`: number of columns
    - `rows`: number of rows
    - `walls`: list of `t:wall/0`
    """
    @type t :: %__MODULE__{
            cols: pos_integer(),
            rows: pos_integer(),
            walls: list(wall)
          }

    @enforce_keys [:cols, :rows, :walls]
    defstruct @enforce_keys
  end

  @doc """
  Converts a `Board.Spec` struct into a list of tiles.

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
  @spec tiles(Spec.t()) :: list(Spec.tile())
  def tiles(%Spec{cols: cols, rows: rows, walls: walls}) do
    for x <- 0..(cols - 1), y <- 0..(rows - 1), {x, y} not in walls, do: {x, y}
  end

  @spec move(%{from: Spec.tile(), to: Spec.tile()}, Spec.t()) :: Spec.tile()
  def move(%{from: from_tile, to: to_tile}, %Spec{walls: walls}) do
    if to_tile in walls, do: from_tile, else: to_tile
  end
end
