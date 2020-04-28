defmodule Board do
  @moduledoc """
  Group of types and a `Board.Spec` struct to define game boards.
  """

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
  - `cols`: columns
  - `rows`
  - `walls`: list of `Board.wall`
  """
  @type board_spec :: %__MODULE__.Spec{
          cols: pos_integer(),
          rows: pos_integer(),
          walls: list(wall)
        }

  defmodule Spec do
    @moduledoc false

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
  @spec tiles(board_spec) :: list(tile)
  def tiles(%Spec{cols: cols, rows: rows, walls: walls}) do
    for x <- 0..(cols - 1), y <- 0..(rows - 1), {x, y} not in walls, do: {x, y}
  end

  @spec move(%{from: tile, to: tile}, board_spec) :: tile
  def move(%{from: from_tile, to: to_tile}, %Spec{walls: walls}) do
    if to_tile in walls, do: from_tile, else: to_tile
  end
end
